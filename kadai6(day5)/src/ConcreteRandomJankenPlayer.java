import java.util.Random;

public class ConcreteRandomJankenPlayer extends JankenPlayer{
	public Random random;

	public ConcreteRandomJankenPlayer(String name) {
		super(name);
		random = new Random();
	}

	public ConcreteRandomJankenPlayer(String name, long seed) { 
		super(name);
		random = new Random(seed);
	}
	
	@Override
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
}
