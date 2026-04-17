import java.util.ArrayList;

public class JudgeForGroup {

	ArrayList<JankenPlayer> Players = new ArrayList<>();
	
	public JudgeForGroup(ArrayList<JankenPlayer> players) {
		Players = players;
	}
	
	public void simulate(int n) {
		int drawNum = 0;
		int rockCnt;
		int scissorsCnt;
		int paperCnt;
		for(int i = 0 ; i < n; i++) {
			rockCnt = 0;
			scissorsCnt = 0;
			paperCnt = 0;
			for(JankenPlayer player : Players) {
				if(player.showHand() == Hand.ROCK) {
					rockCnt++;
				}else if(player.showHand() == Hand.SCISSORS) {
					scissorsCnt++;
				}else {
					paperCnt++;
				}
			}
			if(rockCnt == Players.size() || scissorsCnt == Players.size() || paperCnt == Players.size()) {
				drawNum++;
			}else if(rockCnt >= 1 && scissorsCnt >= 1 && paperCnt >= 1) {
				drawNum++;
			}
		}
		System.out.println(drawNum);
	}
	
	public static void main(String[] args) {
		int m = 10;
		ArrayList<JankenPlayer> Players = new ArrayList<>();
		for (int i = 0; i < m/2; i++) {
			JankenPlayer playerR = new ConcreteRandomJankenPlayer("Yamada");
			Players.add(playerR);
			JankenPlayer playerA = new ConcreteJankenPlayerTypeA("Suzuki");
			Players.add(playerA);
		}
		JudgeForGroup judge = new JudgeForGroup(Players);
		judge.simulate(1000); 
	}
}
