
public class RandomTest1 {
    public static void main(String[] args) {
    	java.util.Random random = new java.util.Random();
    	int x = random.nextInt(100);
    	double y = random.nextDouble();
    	
    	System.out.println(x + " " + y);
    }
}
