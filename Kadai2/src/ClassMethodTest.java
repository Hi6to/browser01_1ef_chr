public class ClassMethodTest {

	public static double getMean(double[] array) {
		if (array.length == 0) {
			return 0.0;
		}
		double ret = 0.0;
		for (double value: array) {
			ret += value;
		}
		return ret / array.length;
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
		System.out.printf("mean: %1.3f\n", getMean(array1));
		double[] a2 = incArray(array1);
		for (double value: a2) {
			System.out.printf("%1.3f ", value);
		}
		System.out.println();
		System.out.printf("mean: %1.3f\n", getMean(a2));
	}
}
