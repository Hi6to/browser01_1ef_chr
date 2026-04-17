import java.util.ArrayList;

public abstract class JankenPlayer {
	protected String name;
	protected int winCnt;
	protected int loseCnt;
	protected int drawCnt;
	protected ArrayList<Hand> myHands;
	protected ArrayList<Hand> opponentHands;
	
	protected JankenPlayer(String name) {
		this.name = name;
		myHands = new ArrayList<>();
		opponentHands = new ArrayList<>();
	}
	
	public abstract Hand showHand();
	
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
	
	public ArrayList<Hand> getmyHands(){
		return myHands;
	}
	
	public ArrayList<Hand> getopponentHands(){
		return opponentHands;
	}
	
	public void receiveResult(Result result) {
		if(result == Result.WIN) this.winCnt++;
		if(result == Result.LOSE) this.loseCnt++;
		if(result == Result.DRAW) this.drawCnt++;
	}
	
	public String getName() {
		return name;
	}
	
}
