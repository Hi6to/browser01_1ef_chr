import java.util.Random;


public class RandomTest3 {
	
	public static int generate_random() {
		Random random = new Random();
		int x = 1;
		while(x % 2 != 0) {
			x = random.nextInt(1001);
		}
		int k = random.nextInt(2);
		if(k == 0) {
			x *= -1;
		}
		
		return x;
	}

    public static void main(String[] args) {
		
		System.out.printf("%d", generate_random());
	}
}
