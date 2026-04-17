public class JudgeEx {
	private RandomJankenPlayer player1, player2, player3;

	// ここを埋める
	// Judgeクラスのフィールドplayer1とplayer2に
	// 引数のプレイヤーを設定するコンストラクタ

	public JudgeEx(RandomJankenPlayer Player1,  RandomJankenPlayer Player2, RandomJankenPlayer Player3) {
		player1 = Player1;
		player2 = Player2;
		player3 = Player3;
	}
	
	private void play(int n) {
		player1.init();
		player2.init();
		player3.init();
		RandomJankenPlayer [] players = new RandomJankenPlayer [4];
		players[1] = player1;
		players[2] = player2;
		players[3] = player3;
		for(int i = 1; i <= 2; i++) {
			for(int j = i + 1; j <= 3; j++) {
				int count = 0;
				while(count != n) {
					Hand hand1 = players[i].showHand();
					Hand hand2 = players[j].showHand();
					if(hand1 == hand2.defeating()) {
						players[i].receiveResult(Result.WIN);
						players[j].receiveResult(Result.LOSE);
					}else if(hand1 == hand2.defeatedBy()){
						players[i].receiveResult(Result.LOSE);
						players[j].receiveResult(Result.WIN);
					}else {
						players[i].receiveResult(Result.DRAW);
						players[j].receiveResult(Result.DRAW);
					}
					count++;
				}
			}
		}
	}
	
	public static void main(String[] args) {
		
		int num = Integer.parseInt(args[0]); // ラウンド数
		RandomJankenPlayer player1 = new RandomJankenPlayer("Yamada");
		RandomJankenPlayer player2 = new RandomJankenPlayer("Suzuki");
		RandomJankenPlayer player3 = new RandomJankenPlayer("Tanaka");
		JudgeEx judgeEx = new JudgeEx(player1, player2, player3);
		judgeEx.play(num);
	
		player1.report();
		player2.report();
		player3.report();
	}
}

