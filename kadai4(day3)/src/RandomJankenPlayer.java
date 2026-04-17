import java.util.Random;

public class RandomJankenPlayer {
	private String name;
	private Random random;
	private int winCnt;
	private int loseCnt;
	private int drawCnt;
	public RandomJankenPlayer(String name) {
		this.name = name;
		random = new Random();
	}

	public RandomJankenPlayer(String name, long seed) { 		
		this.name = name;
		random = new Random(seed);
	}
	
	public void init() {
		winCnt = 0;
		loseCnt = 0;
		drawCnt = 0;
	}
	
	public int getWin() {
		return this.winCnt;
	}
	
	public int getLose() {
		return this.loseCnt;
	}
	
	public int getDraw() {
		return this.drawCnt;
	}
	
	public void receiveResult(Result result) {
		if(result == Result.WIN) this.winCnt++;
		if(result == Result.LOSE) this.loseCnt++;
		if(result == Result.DRAW) this.drawCnt++;
	}
	
	public void report() {
		System.out.printf("%s %d win, %d lose, %d draw\n", this.name, winCnt, loseCnt, drawCnt);
	}

	public String getName() {
		return this.name;
	}
	public Hand showHand() {
		Hand play;
		int num = random.nextInt(3); // 0 ~ 2の間の整数をランダムに生成
		if (num == 0) {
			play = Hand.ROCK;
		} else if (num == 1) {
			play = Hand.PAPER;
		} else {
			play = Hand.SCISSORS;
		}
		return play;
	}

	// main
	public static void main(String[] args) {
		RandomJankenPlayer player1 = new RandomJankenPlayer("Yamada");
		RandomJankenPlayer player2 = new RandomJankenPlayer("Suzuki");
		RandomJankenPlayer player3 = new RandomJankenPlayer("Tanaka");
		RandomJankenPlayer [] players = new RandomJankenPlayer[4];
		players[1] = player1;
		players[2] = player2;
		players[3] = player3;
		for (int i = 1; i < 3; i++) {
			
			System.out.printf("[%s] win, %d lose, %d draw, %d\n", players[i].name, players[i].winCnt, players[i].loseCnt, players[i].drawCnt);
		}
	}
}
