public class Judge {
	private RandomJankenPlayer player1, player2;

	// ここを埋める
	// Judgeクラスのフィールドplayer1とplayer2に
	// 引数のプレイヤーを設定するコンストラクタ

	public Judge(RandomJankenPlayer Player1, RandomJankenPlayer Player2) {
		player1 = Player1;
		player2 = Player2;
	}
	
	private void play(int n) {
		player1.init();
		player2.init();

		System.out.println("Player1 : " + player1.getName());
		System.out.println("Player2 : " + player2.getName());
		System.out.println();
		System.out.printf("Results: %d games\n", n);
		System.out.println(player1.getName() + ":");
		
		int count = 0;
		while(count != n) {
			Hand hand1 = player1.showHand();
			Hand hand2 = player2.showHand();
			player1.getmyHands().add(hand1);
			player1.getopponentHands().add(hand2);
			player2.getmyHands().add(hand2);
			player2.getopponentHands().add(hand1);
			System.out.println((count+1) + ") " + hand1 + " vs " + hand2 + "(opponent)");
			if(hand1 == hand2.defeating()) {
				player1.receiveResult(Result.WIN);
				player2.receiveResult(Result.LOSE);
			}else if(hand1 == hand2.defeatedBy()){
				player1.receiveResult(Result.LOSE);
				player2.receiveResult(Result.WIN);
			}else {
				player1.receiveResult(Result.DRAW);
				player2.receiveResult(Result.DRAW);
			}
			count++;
		}	

		System.out.printf("%s %d win, %d lose, %d draw\n", player1.getName(), player1.getWin(), player1.getLose(), player1.getDraw());
		System.out.printf("%s %d win, %d lose, %d draw\n", player2.getName(), player2.getWin(), player2.getLose(), player2.getDraw());
	}
	
	public static void main(String[] args) {
		try {
			int num = Integer.parseInt(args[0]); // ラウンド数
			RandomJankenPlayer player1 = new RandomJankenPlayer("Yamada");
			RandomJankenPlayer player2 = new MyJankenPlayer ("Suzuki");
			Judge judge = new Judge(player1, player2);
			judge.play(num);
		} catch(Exception e) {
			System.out.println("this requires an integer argument.");
		}
		
	}
}
