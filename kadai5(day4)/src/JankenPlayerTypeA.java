public class JankenPlayerTypeA extends RandomJankenPlayer{

	public JankenPlayerTypeA(String name){
		super(name);
	}
	
	public Hand showHand() {
		if(myHands.size() != 0 && myHands.getLast() != opponentHands.getLast().defeating()) {
			return super.showHand();
		}else {
			if(myHands.size() == 0) return super.showHand();
			return getopponentHands().getLast();
		}
	}
	
}