import java.util.Random;

public class RandomTest2 {
    public static void main(String[] args) {
		Random random = new Random(18760814L);
		int x = random.nextInt(100);
		double y = random.nextDouble();
		System.out.println(x + " " + y);
	}
}
