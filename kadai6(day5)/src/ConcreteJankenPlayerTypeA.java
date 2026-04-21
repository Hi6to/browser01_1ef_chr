import java.util.Random;
public class ConcreteJankenPlayerTypeA extends JankenPlayer{

	private Hand showRandom() {
		Hand play;
		Random random = new Random();
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
	
	public ConcreteJankenPlayerTypeA(String name){
		super(name);
	}
	
	public Hand showHand() {
		if(myHands.size() != 0 && myHands.getLast() != opponentHands.getLast().defeating()) {
			return showRandom();
		}else {
			if(myHands.size() == 0) return showRandom();
			return getopponentHands().getLast();
		}
	}
	
}