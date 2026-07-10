import os
import warnings
from pathlib import Path

import numpy as np
import pandas as pd
from sklearn.ensemble import ExtraTreesRegressor
from sklearn.metrics import mean_squared_error
from sklearn.model_selection import KFold


warnings.filterwarnings("ignore")

TARGET = "popularity"
SEED = 42
N_SPLITS = 3

FEATURE_COLS = [
    "duration_ms", "danceability", "energy", "key", "loudness", "mode",
    "speechiness", "acousticness", "instrumentalness", "liveness",
    "valence", "tempo", "time_signature", "explicit", "track_genre",
]
TEXT_COLS = ["track_id", "artists", "album_name", "track_name", "track_genre"]
TARGET_ENCODE_COLS = [
    "track_genre", "artist_first", "artists", "album_name",
    "track_name", "artist_track_key",
]
ONEHOT_COLS = ["track_genre", "key", "mode", "time_signature"]


def find_files(root="/kaggle/input"):
    train_path = test_path = sample_path = None

    for path in Path(root).rglob("*.csv"):
        cols = pd.read_csv(path, nrows=3).columns.tolist()
        feature_count = sum(col in cols for col in FEATURE_COLS)

        if TARGET in cols and feature_count >= 5:
            train_path = str(path)
        elif TARGET not in cols and feature_count >= 5:
            test_path = str(path)
        else:
            sample_path = str(path)

    if train_path is None or test_path is None:
        raise FileNotFoundError("Train or test CSV was not found.")

    print("train:", train_path)
    print("test :", test_path)
    print("sample:", sample_path)
    return train_path, test_path, sample_path


def clean_text(series):
    return (
        series.fillna("__missing__")
        .astype(str)
        .str.lower()
        .str.strip()
        .str.replace(r"\s+", " ", regex=True)
    )


def fill_text_from_track_id(train, test):
    """Use the same track's metadata before falling back to __missing__."""
    train = train.copy()
    test = test.copy()

    for col in TEXT_COLS:
        if col not in train.columns or col not in test.columns:
            continue

        if col != "track_id" and "track_id" in train.columns:
            lookup = (
                train.dropna(subset=["track_id", col])
                .drop_duplicates("track_id")
                .set_index("track_id")[col]
            )
            test[col] = test[col].fillna(test["track_id"].map(lookup))

        train[col] = clean_text(train[col])
        test[col] = clean_text(test[col])

    return train, test


def normalize_explicit(df):
    if "explicit" not in df.columns:
        return df

    values = df["explicit"].astype(str).str.lower()
    mapped = values.map({"true": 1, "false": 0, "1": 1, "0": 0})
    df["explicit"] = mapped.fillna(
        pd.to_numeric(df["explicit"], errors="coerce")
    ).fillna(0).astype(int)
    return df


def add_features(df):
    df = normalize_explicit(df.copy())

    artists = df["artists"]
    track = df["track_name"]
    album = df["album_name"]

    df["artist_first"] = artists.str.split(";").str[0]
    df["artist_count"] = artists.str.count(";") + 1
    df["artists_len"] = artists.str.len()
    df["track_name_len"] = track.str.len()
    df["track_word_count"] = track.str.split().str.len()
    df["album_name_len"] = album.str.len()
    df["album_word_count"] = album.str.split().str.len()

    for word in ["remix", "live", "acoustic", "remaster"]:
        df[f"track_has_{word}"] = track.str.contains(
            word, regex=False
        ).astype(np.uint8)

    duration = pd.to_numeric(df["duration_ms"], errors="coerce")
    tempo = pd.to_numeric(df["tempo"], errors="coerce")
    df["duration_min"] = duration / 60000
    df["log_duration"] = np.log1p(duration.clip(lower=0))
    df["duration_short"] = (duration < 120000).astype(np.uint8)
    df["duration_long"] = (duration > 360000).astype(np.uint8)
    df["tempo_log"] = np.log1p(tempo.clip(lower=0))
    df["tempo_slow"] = (tempo < 90).astype(np.uint8)
    df["tempo_fast"] = (tempo > 140).astype(np.uint8)

    df["danceability_x_energy"] = df["danceability"] * df["energy"]
    df["danceability_x_valence"] = df["danceability"] * df["valence"]
    df["energy_x_loudness"] = df["energy"] * df["loudness"]
    df["energy_x_acousticness"] = df["energy"] * df["acousticness"]

    df["artist_track_key"] = df["artist_first"] + "||" + track
    return df


def add_frequency_features(train, test):
    train = train.copy()
    test = test.copy()
    columns = [
        "artists", "artist_first", "album_name",
        "track_name", "artist_track_key",
    ]

    for col in columns:
        counts = pd.concat([train[col], test[col]]).value_counts(dropna=False)
        train[f"{col}_log_count"] = np.log1p(train[col].map(counts))
        test[f"{col}_log_count"] = np.log1p(test[col].map(counts))

    return train, test


def fill_numeric_by_genre(train, test):
    """Fill numeric missing values with train genre medians, then global medians."""
    train = train.copy()
    test = test.copy()

    for col in train.columns:
        if col == TARGET or col not in test.columns:
            continue
        if not pd.api.types.is_numeric_dtype(train[col]):
            continue

        genre_median = train.groupby("track_genre")[col].median()
        global_median = train[col].median()
        if pd.isna(global_median):
            global_median = 0

        train[col] = train[col].fillna(train["track_genre"].map(genre_median))
        test[col] = test[col].fillna(test["track_genre"].map(genre_median))
        train[col] = train[col].fillna(global_median)
        test[col] = test[col].fillna(global_median)

    return train, test


def add_genre_audio_features(train, test):
    """Express how each song differs from the typical song in its genre."""
    train = train.copy()
    test = test.copy()
    audio_cols = [
        "duration_ms", "danceability", "energy", "loudness",
        "speechiness", "acousticness", "instrumentalness",
        "liveness", "valence", "tempo",
    ]

    for col in audio_cols:
        genre_mean = train.groupby("track_genre")[col].mean()
        train_mean = train["track_genre"].map(genre_mean)
        test_mean = test["track_genre"].map(genre_mean)
        train[f"genre_{col}_mean"] = train_mean
        test[f"genre_{col}_mean"] = test_mean
        train[f"genre_{col}_diff"] = train[col] - train_mean
        test[f"genre_{col}_diff"] = test[col] - test_mean

    return train, test


def add_oof_target_means(train, test, y, smoothing=30.0):
    """Add leakage-reduced mean popularity features."""
    train = train.copy()
    test = test.copy()
    global_mean = float(np.mean(y))
    folds = KFold(n_splits=N_SPLITS, shuffle=True, random_state=SEED)

    for col in TARGET_ENCODE_COLS:
        oof = np.full(len(train), global_mean)
        test_mean = np.zeros(len(test))

        for train_idx, valid_idx in folds.split(train):
            keys = train[col].iloc[train_idx]
            values = pd.Series(y[train_idx], index=keys.index)
            stats = values.groupby(keys).agg(["mean", "count"])
            encoded = (
                stats["mean"] * stats["count"] + global_mean * smoothing
            ) / (stats["count"] + smoothing)

            oof[valid_idx] = (
                train[col].iloc[valid_idx].map(encoded).fillna(global_mean)
            )
            test_mean += (
                test[col].map(encoded).fillna(global_mean).to_numpy() / N_SPLITS
            )

        train[f"{col}_target_mean"] = oof
        test[f"{col}_target_mean"] = test_mean

    return train, test


def make_matrix(train, test):
    y = train[TARGET].astype(float).to_numpy()

    # 実質的な欠損値(0.0)をプログラム上の欠損値(NaN)に置き換える
    # 0になるのが不自然（欠損の可能性が高い）な特徴量を指定
    zero_as_missing_cols = [
        "tempo", 
        "duration_ms", 
        "danceability", 
        "energy", 
        "valence"
    ]
    
    for col in zero_as_missing_cols:
        if col in train.columns:
            train[col] = train[col].replace(0.0, np.nan)
        if col in test.columns:
            test[col] = test[col].replace(0.0, np.nan)
            
    train, test = fill_text_from_track_id(train, test)
    train = add_features(train)
    test = add_features(test)
    train, test = add_frequency_features(train, test)
    train, test = fill_numeric_by_genre(train, test)
    train, test = add_genre_audio_features(train, test)
    train, test = add_oof_target_means(train, test, y)

    lookup_train = train[
        ["track_id", "artists", "album_name", "track_name", "artist_first"]
    ].copy()
    lookup_test = test[
        ["track_id", "artists", "album_name", "track_name", "artist_first"]
    ].copy()

    full = pd.concat(
        [train.drop(columns=[TARGET]), test],
        ignore_index=True,
    )

    for col in ONEHOT_COLS:
        full[col] = full[col].fillna("__missing__").astype(str)

    high_cardinality = [
        "Unnamed: 0", "track_id", "artists", "album_name",
        "track_name", "artist_first", "artist_track_key",
    ]
    full = full.drop(columns=high_cardinality, errors="ignore")
    full = pd.get_dummies(
        full, columns=ONEHOT_COLS, dummy_na=True, dtype=np.uint8
    )

    for col in full.columns:
        full[col] = pd.to_numeric(full[col], errors="coerce")
    full = full.replace([np.inf, -np.inf], np.nan)
    full = full.fillna(full.median(numeric_only=True)).fillna(0)

    X = full.iloc[:len(train)].astype(np.float32)
    X_test = full.iloc[len(train):].astype(np.float32)
    print("feature matrix:", X.shape, X_test.shape)
    return X, X_test, y, lookup_train, lookup_test


def train_single_model(X, X_test, y):
    folds = KFold(n_splits=N_SPLITS, shuffle=True, random_state=SEED)
    oof = np.zeros(len(X))
    test_pred = np.zeros(len(X_test))

    for fold, (train_idx, valid_idx) in enumerate(folds.split(X), start=1):
        model = ExtraTreesRegressor(
            n_estimators=350,
            max_depth=46,                        # 追加（木の深さ）
            min_samples_split=7,                 # 追加（分岐に必要な最小データ数）
            min_samples_leaf=1,                  # 2 から 1 に変更
            max_features=0.8776513667040592,     # 0.75 から 変更
            random_state=SEED + fold,
            n_jobs=-1,
        )
        model.fit(X.iloc[train_idx], y[train_idx])
        oof[valid_idx] = model.predict(X.iloc[valid_idx])
        test_pred += model.predict(X_test) / N_SPLITS

        score = mean_squared_error(y[valid_idx], oof[valid_idx])
        print(f"fold {fold} MSE: {score:.6f}")

    print("Extra Trees OOF MSE:", mean_squared_error(y, oof))
    return np.clip(oof, 0, 100), np.clip(test_pred, 0, 100)


def apply_track_id_lookup(train_keys, test_keys, y, oof, test_pred):
    """Replace predictions only when exactly the same track_id is known."""
    folds = KFold(n_splits=N_SPLITS, shuffle=True, random_state=SEED)
    adjusted_oof = oof.copy()

    for train_idx, valid_idx in folds.split(train_keys):
        table = pd.Series(y[train_idx]).groupby(
            train_keys["track_id"].iloc[train_idx].to_numpy()
        ).mean()
        mapped = train_keys["track_id"].iloc[valid_idx].map(table)
        hit = mapped.notna().to_numpy()
        adjusted_oof[valid_idx[hit]] = mapped[hit].to_numpy()

    full_table = pd.Series(y).groupby(
        train_keys["track_id"].to_numpy()
    ).mean()
    mapped_test = test_keys["track_id"].map(full_table)
    test_hit = mapped_test.notna().to_numpy()
    final_pred = test_pred.copy()
    final_pred[test_hit] = mapped_test[test_hit].to_numpy()

    print("track_id adjusted OOF MSE:", mean_squared_error(y, adjusted_oof))
    print("adjusted test rows:", int(test_hit.sum()), "/", len(test_keys))
    return np.clip(final_pred, 0, 100)


def save_submission(pred):
    output = Path("./submission.csv")
    output.parent.mkdir(parents=True, exist_ok=True)
    pd.DataFrame(pred).to_csv(output, index=False, header=False)

    print("saved:", output)
    print("prediction count:", len(pred))
    print(pd.read_csv(output, header=None).head())

    try:
        from IPython.display import FileLink, display

        os.chdir(output.parent)
        display(FileLink(output.name))
    except ImportError:
        pass


def main():
    train_path, test_path, _ = find_files(root="./")
    train = pd.read_csv(train_path)
    test = pd.read_csv(test_path)

    print("train shape:", train.shape)
    print("test shape :", test.shape)

    X, X_test, y, train_keys, test_keys = make_matrix(train, test)
    oof, test_pred = train_single_model(X, X_test, y)
    final_pred = apply_track_id_lookup(
        train_keys, test_keys, y, oof, test_pred
    )
    save_submission(final_pred)


if __name__ == "__main__":
    main()
