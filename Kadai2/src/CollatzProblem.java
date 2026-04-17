import java.util.ArrayList;
public class CollatzProblem {

	 public static ArrayList<Integer> verify(int n){
		 ArrayList<Integer> array = new ArrayList<>();
		 array.add(n);
		 int i = 0;
		 while(array.get(i) <= Integer.MAX_VALUE ) {
			 if(array.get(i) % 2 == 0) {
				 array.add(array.get(i)/2);
			 }else {
				 array.add(3*array.get(i) + 1);
			 }
			 i++;
		 }
		 
		 return array;
	 }
	
	 public static void main(String[] args) {
		 int n = Integer.parseInt(args[0]);
		 ArrayList<Integer> seq = verify(n);

		 for(int value : seq) {
			 System.out.printf("%d", value);
		 	}
		 }
	 
}
