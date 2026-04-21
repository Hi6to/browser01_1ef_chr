
public class StrategyLearningPlayer extends RandomJankenPlayer {
	private int round;
	public StrategyLearningPlayer(String name){
		super(name);
		round = 0;
	}
	
	public Hand showHand() {
		if(round == 0) {
			round++;
			return super.showHand();
		}else if(winCnt > loseCnt && winCnt > drawCnt) {
			return super.showHand();
		}
		return super.showHand();
	}
}
