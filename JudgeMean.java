public class JudgeMean {
	private RandomJankenPlayer player1, player2;

	// ここを埋める
	// Judgeクラスのフィールドplayer1とplayer2に
	// 引数のプレイヤーを設定するコンストラクタ

	public JudgeMean(RandomJankenPlayer Player1,  RandomJankenPlayer Player2) {
		player1 = Player1;
		player2 = Player2;
	}
	
	private void simulateMean(int m) {
		
		int win1 = 0, win2 = 0;
		int lose1 = 0, lose2 = 0;
		int draw1 = 0, draw2 = 0;

		// ここを埋める
		int count = 0;
		while(count != 10*m) {
			Hand hand1 = player1.showHand();
			Hand hand2 = player2.showHand();
			if(hand1 == hand2.defeating()) {
				win1++;
				lose2++;
			}else if(hand1 == hand2.defeatedBy()){
				lose1++;
				win2++;
			}else {
				draw1++;
				draw2++;
			}
			count++;
		}
		double div = 10*m;
		System.out.printf("Results: %d*%d games\n", 10, m);
		System.out.printf("%s %1.3f win, %1.3f lose, %1.3f draw\n", player1.getName(), win1/div, lose1/div, draw1/div);
		System.out.printf("%s %1.3f win, %1.3f lose, %1.3f draw\n", player2.getName(), win2/div, lose2/div, draw2/div);
	}
	
	public static void main(String[] args) {
		try {
			int num = Integer.parseInt(args[0]); // ラウンド数
			RandomJankenPlayer player1 = new RandomJankenPlayer("Yamada");
			RandomJankenPlayer player2 = new RandomJankenPlayer("Suzuki");
			JudgeMean judge = new JudgeMean(player1, player2);
			judge.simulateMean(num);
		} catch(Exception e) {
			System.out.println("this requires an integer argument.");
		}
	}
}
