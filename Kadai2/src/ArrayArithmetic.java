public class ArrayArithmetic{
		
		public static double getSum(double[] array) {
			if (array.length == 0) {
				return 0.0;
			}
			double ret = 0.0;
			for (double value: array) {
				ret += value;
			}
			return ret;
		}

		public static double getProduct(double[] array) {
			if (array.length == 0) {
				return 0.0;
			}
			double ret = 1.0;
			for (double value: array) {
				ret *= value;
			}
			return ret;
		}
		
		public static double[] incArray(double[] array) {
			double[] ret = new double[array.length];
			for (int i = 0; i < array.length; i++) {
				ret[i] = array[i] + 1;
			}
			return ret;
		}

		public static void main(String[] args) {
			double[] array1 = {1.012, -2.599, 3.421};
			System.out.printf("内容: ");
			for(double value : array1) {
				System.out.printf("%1.3f, ", value);
			}
			System.out.printf("\n");
			double sum = getSum(array1);
			System.out.printf("総和：%1.3f\n", sum);
			double product = getProduct(array1);
			System.out.printf("積：%1.3f\n", product);
			double[] array2 = incArray(array1);
			System.out.printf("内容: ");
			for(double value : array2) {
				System.out.printf("%1.3f, ", value);
			}
			System.out.printf("\n");
			sum = getSum(array2);
			System.out.printf("総和：%1.3f\n", sum);
			product = getProduct(array2);
			System.out.printf("積：%1.3f", product);

	}
}