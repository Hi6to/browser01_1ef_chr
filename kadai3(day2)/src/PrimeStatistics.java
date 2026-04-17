import java.util.Random;

public class PrimeStatistics {
	
	public static boolean is_prime(int n) {
		
		if(n == 1) {
			return false;
		}else if(n == 2) {
			return true;
		}else if(n == 3){
			return true;
		}else {
			
			for(int i = 2; i <= n/2; i++) {
				if(n % i == 0) {
					return false;
				}
			}
		}
		return true;
	}
	
	public static int count_prime(int n) {
		int count = 0;
		for(int i = 0; i < 1000; i++) {
			Random random = new Random();
			int x = random.nextInt((int)Math.pow(2, n));
			if(is_prime(x)) {
				count++;
			}
		}
		
		return count;
	}
	
	public static void main(String[] args) {
		System.out.printf("%1.3f, %1.3f", 1000 / (double)count_prime(25), Math.log(Math.pow(2,  25)));
	}
}
