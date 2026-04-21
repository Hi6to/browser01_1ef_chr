public class ArrayArithmeticEx{
	
		public static int getSum(int[] array) {
			if (array.length == 0) {
				return 0;
			}
			int sum = 0;
			for (int value: array) {
				sum += value;
			}
			return sum;
		}

		public static int getNonZeroProduct(int[] array) {
			if (array.length == 0) {
				return 0;
			}
			int flag = 0;
			int product = 1;
			for (int value: array) {
				if(value != 0) {
					product *= value;
					flag++;
				}
			}
			if(flag == 0) {
				return 0;
			}
			return product;
		}
		
		public static int[] getNegations(int[] array) {
			int [] temp_array = new int[array.length];
			for(int i = 0 ; i < array.length; i++) {
				temp_array[i] = array[i];
			}
			for(int i = 0; i < array.length; i++) {
				if(temp_array[i] < 0) {
					temp_array[i] *= -1;
				}
			}

			return temp_array;
		}
		
		public static void main(String[] args) {
			int [] array1 = {2, -3, 0};
			System.out.printf("%d\n", getSum(array1));
			if(getNonZeroProduct(array1) == 0) {
				System.out.println("all zero");
			}else {
				System.out.printf("%d\n", getNonZeroProduct(array1));
			}
			for(int value : getNegations(array1)) {
				System.out.printf("%d, ", value);
			}

	}
}