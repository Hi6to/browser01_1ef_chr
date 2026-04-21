public class MyJankenPlayer extends RandomJankenPlayer {
	
	public MyJankenPlayer(String name){
		super(name);
	}
	//負けるまで同じ手を出す。負けたら別の手をだす。
	public Hand showHand() {
		if(myHands.size() != 0 && myHands.getLast() != opponentHands.getLast().defeating()) {
			return myHands.getLast();
		}else {
			Hand hand = super.showHand();
			if(myHands.size() == 0) return hand;
			while(hand == myHands.getLast()) hand = super.showHand();
			return hand;
		}
	}
}
