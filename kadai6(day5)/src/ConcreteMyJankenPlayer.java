import java.util.Random;

public class ConcreteMyJankenPlayer extends JankenPlayer {
	
	public ConcreteMyJankenPlayer(String name){
		super(name);
	}
	
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
	
	//負けるまで同じ手を出す。負けたら別の手をだす。
	public Hand showHand() {
		if(myHands.size() != 0 && myHands.getLast() != opponentHands.getLast().defeating()) {
			return myHands.getLast();
		}else {
			Hand hand = showRandom();
			if(myHands.size() == 0) return hand;
			while(hand == myHands.getLast()) hand = showRandom();
			return hand;
		}
	}
}
