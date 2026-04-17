public enum Hand {
	ROCK,
	PAPER,
	SCISSORS;

	// 現在のインスタンスが勝つ手を返すメソッド
	public Hand defeating() {
		if (this == ROCK) return SCISSORS;
		if (this == PAPER) return ROCK;
		return PAPER;
	}
	
	// 現在のインスタンスが負ける手を返すメソッド
	public Hand defeatedBy() {
		if (this == ROCK) return PAPER;
		if (this == PAPER) return SCISSORS;
		return ROCK;
	}
}
