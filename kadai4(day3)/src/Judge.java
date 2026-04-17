public class Judge {
	private RandomJankenPlayer player1, player2;

	// ここを埋める
	// Judgeクラスのフィールドplayer1とplayer2に
	// 引数のプレイヤーを設定するコンストラクタ

	public Judge(RandomJankenPlayer Player1,  RandomJankenPlayer Player2) {
		player1 = Player1;
		player2 = Player2;
	}
	
	private void simulate(int n) {
		int win1 = 0, win2 = 0;
		int lose1 = 0, lose2 = 0;
		int draw1 = 0, draw2 = 0;

		// ここを埋める
		int count = 0;
		while(count != 100) {
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
		
		

		System.out.println("Player1 : " + player1.getName());
		System.out.println("Player2 : " + player2.getName());
		System.out.println();
		System.out.printf("Results: %d games\n", n);
		System.out.printf("%s %d win, %d lose, %d draw\n", player1.getName(), win1, lose1, draw1);
		System.out.printf("%s %d win, %d lose, %d draw\n", player2.getName(), win2, lose2, draw2);
	}
	
	public static void main(String[] args) {
		try {
			int num = Integer.parseInt(args[0]); // ラウンド数
			RandomJankenPlayer player1 = new RandomJankenPlayer("Yamada");
			RandomJankenPlayer player2 = new RandomJankenPlayer("Suzuki");
			Judge judge = new Judge(player1, player2);
			judge.simulate(num);
		} catch(Exception e) {
			System.out.println("this requires an integer argument.");
		}
	}
}
