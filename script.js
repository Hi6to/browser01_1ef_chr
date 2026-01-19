import { initializeApp } from "https://www.gstatic.com/firebasejs/9.22.0/firebase-app.js";
import { getFirestore, collection, addDoc, onSnapshot, deleteDoc, doc, orderBy, query } from "https://www.gstatic.com/firebasejs/9.22.0/firebase-firestore.js";
import { getAuth, signInWithEmailAndPassword, signOut, onAuthStateChanged } from "https://www.gstatic.com/firebasejs/9.22.0/firebase-auth.js";

// Firebase設定
const firebaseConfig = {
  apiKey: "AIzaSyCPu2xi_tQmBHOl9FZxu_q3sLoSfJj7Voc",
  authDomain: "project01-1e217.firebaseapp.com",
  projectId: "project01-1e217",
  storageBucket: "project01-1e217.firebasestorage.app",
  messagingSenderId: "438455079136",
  appId: "1:438455079136:web:4865d0ec3ed299de0bc085"
};

const app = initializeApp(firebaseConfig);
const db = getFirestore(app);
const auth = getAuth(app);

// 要素の取得（存在しないページもあるのでnullチェックが必要）
const memoList = document.getElementById('memoList');

// --- 管理画面専用の要素 ---
const loginArea = document.getElementById('loginArea');
const adminArea = document.getElementById('adminArea');
const loginBtn = document.getElementById('loginBtn');
const logoutBtn = document.getElementById('logoutBtn');
const addBtn = document.getElementById('addBtn');

// ===============================================
// 1. 認証機能（admin.htmlでのみ動作）
// ===============================================
if (loginBtn) { // ログインボタンがあるページ(=admin.html)の場合だけ実行
    
    // ログイン状態の監視
    onAuthStateChanged(auth, (user) => {
        if (user) {
            loginArea.style.display = 'none';
            adminArea.style.display = 'flex'; // 入力欄を表示
            document.getElementById('userEmail').textContent = user.email;
        } else {
            loginArea.style.display = 'block';
            adminArea.style.display = 'none';
        }
    });

    // ログインボタン処理
    loginBtn.addEventListener('click', async () => {
        const email = document.getElementById('emailInput').value;
        const pass = document.getElementById('passInput').value;
        try {
            await signInWithEmailAndPassword(auth, email, pass);
        } catch (e) {
            alert("ログイン失敗: " + e.message);
        }
    });

    // ログアウトボタン処理
    logoutBtn.addEventListener('click', async () => {
        await signOut(auth);
    });

    // 投稿ボタン処理
    addBtn.addEventListener('click', async function() {
        const category = document.getElementById('categorySelect').value;
        const title = document.getElementById('titleInput').value;
        const content = document.getElementById('contentInput').value;

        if (title === '' && content === '') return;

        try {
            await addDoc(collection(db, "memos"), {
                category: category,
                title: title,
                content: content,
                createdAt: new Date()
            });
            document.getElementById('titleInput').value = '';
            document.getElementById('contentInput').value = '';
        } catch (e) {
            console.error(e);
            alert("投稿エラー（権限がありません）");
        }
    });
}

// ===============================================
// 2. データ表示機能（全ページ共通）
// ===============================================
const q = query(collection(db, "memos"), orderBy("createdAt", "desc"));

onSnapshot(q, (snapshot) => {
    memoList.innerHTML = '';
    snapshot.forEach((document) => {
        const data = document.data();
        const id = document.id;
        renderMemo(id, data);
    });
});

function renderMemo(id, data) {
    let categoryLabel = "その他";
    if (data.category === "music") categoryLabel = "🎵 作曲";
    if (data.category === "art") categoryLabel = "🎨 イラスト";

    const div = document.createElement('div');
    div.classList.add('memo-card', `category-${data.category}`);

    div.innerHTML = `
        <div class="memo-header">
            <span class="memo-category">${categoryLabel}</span>
            <span class="memo-title">${escapeHTML(data.title)}</span>
        </div>
        <div class="memo-content">${escapeHTML(data.content)}</div>
    `;

    // 削除ボタンは管理者としてログインしている時だけ追加
    if (auth.currentUser) {
        const deleteBtn = document.createElement('button');
        deleteBtn.textContent = '削除';
        deleteBtn.classList.add('delete-btn');
        deleteBtn.addEventListener('click', async function() {
            if(confirm("削除しますか？")) {
                await deleteDoc(doc(db, "memos", id));
            }
        });
        div.appendChild(deleteBtn);
    }

    memoList.appendChild(div);
}

function escapeHTML(str) {
    if (!str) return "";
    return str.replace(/[&<>"']/g, function(match) {
        const escape = {'&': '&amp;','<': '&lt;','>': '&gt;','"': '&quot;',"'": '&#39;'};
        return escape[match];
    });
}