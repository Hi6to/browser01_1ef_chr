public class JudgeEx2 {
	
	private int M;
	private RandomJankenPlayer players [];
	
	public JudgeEx2(RandomJankenPlayer [] mPlayers, int m) {
		M = m;
		players = mPlayers;
		/*for(int i = 1; i <= M; i++) {
			System.out.printf("%s\n", players[i].getName());
		}*/
		//System.out.printf("%d", M);
	}
	
	private void play(int n) {

		for(int i = 1; i <= M - 1; i++) {
			for(int j = i + 1; j <= M; j++) {
				players[i].init();
				players[j].init();
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
						continue;
					}
					count++;
				}
				System.out.printf(players[i].getName() + " vs " + players[j].getName() + ": ");
				players[i].report();
			}
		}
	}
	
	public static void main(String[] args) {
		
		int num = Integer.parseInt(args[0]); // ラウンド数
		int m = Integer.parseInt(args[1]);
		RandomJankenPlayer player1 = new RandomJankenPlayer("Yamada");
		RandomJankenPlayer player2 = new RandomJankenPlayer("Suzuki");
		RandomJankenPlayer player3 = new RandomJankenPlayer("Tanaka");
		RandomJankenPlayer player4 = new RandomJankenPlayer("Morinaga");
		RandomJankenPlayer player5 = new RandomJankenPlayer("Meiji");
		RandomJankenPlayer [] Players = new RandomJankenPlayer[m + 1];
		Players[1] = player1;
		Players[2] = player2;
		Players[3] = player3;
		Players[4] = player4;
		Players[5] = player5;
		JudgeEx2 judgeEx2 = new JudgeEx2(Players, m);
		judgeEx2.play(num);
	}
}

