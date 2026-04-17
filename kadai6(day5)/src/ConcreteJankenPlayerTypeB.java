public class ConcreteJankenPlayerTypeB extends JankenPlayer {
	

	public ConcreteJankenPlayerTypeB(String name){
		super(name);
	}
	
	public Hand showHand() {
		return Hand.ROCK;
	}
	
}
