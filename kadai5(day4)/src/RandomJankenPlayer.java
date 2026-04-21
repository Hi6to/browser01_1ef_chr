import java.util.ArrayList;
import java.util.Random;

public class RandomJankenPlayer {
	protected String name;
	public Random random;
	protected int winCnt;
	protected int loseCnt;
	protected int drawCnt;
	protected ArrayList<Hand> myHands;
	protected ArrayList<Hand> opponentHands;
	public RandomJankenPlayer(String name) {
		this.name = name;
		random = new Random();
		myHands = new ArrayList<>();
		opponentHands = new ArrayList<>();

	}

	public RandomJankenPlayer(String name, long seed) { 		
		this.name = name;
		random = new Random(seed);
		myHands = new ArrayList<>();
		opponentHands = new ArrayList<>();
	}
	
	public void init() {
		winCnt = 0;
		loseCnt = 0;
		drawCnt = 0;
		myHands.clear();
		opponentHands.clear(); 
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
	
	public String getName() {
		return this.name;
	}
	
	public void receiveResult(Result result) {
		if(result == Result.WIN) this.winCnt++;
		if(result == Result.LOSE) this.loseCnt++;
		if(result == Result.DRAW) this.drawCnt++;
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
	
	public ArrayList<Hand> getmyHands(){
		return myHands;
	}
	
	public ArrayList<Hand> getopponentHands(){
		return opponentHands;
	}

	// main
	public static void main(String[] args) {
		RandomJankenPlayer player1 = new RandomJankenPlayer("Yamada");
		RandomJankenPlayer player2 = new JankenPlayerTypeA("Suzuki");
		for (int i = 0; i < 10; i++) {
			Hand hand1 = player1.showHand();
			Hand hand2 = player2.showHand();
			System.out.printf("%d) [%s] %s vs [%s] %s\n", i, player1.name, hand1, player2.name, hand2);
		}
	}
}
