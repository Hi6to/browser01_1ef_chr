import java.util.ArrayList;
import java.util.Collections;
import java.util.Iterator;

public class ArrayListTest {
	public static void main(String[] args) {
		ArrayList<String> countries = new ArrayList<>();
		countries.add("Japan");
		countries.add("Costa Rica");
		countries.add("Antigua and Barbuda");
		countries.add("El Salvador");

		if (countries.contains("Japan")) {
			System.out.println("contains Japan!");
		}

		// for文
		for(int i = 0; i < countries.size(); i++) { // ArrayListのようなCollectionと呼ばれるデータ構造では，sizeメソッドによって要素数を得ることができる
			System.out.println(countries.get(i)); // countriesのi番目の要素
		}
		System.out.println("---");

		// イテレータ
		Iterator<String> it = countries.iterator();
		while (it.hasNext()) {
			System.out.println(it.next());
		}
		System.out.println("---");

		// 拡張for文
		for (String c : countries) {
			System.out.println(c);
		}
		System.out.println("---");

		// ランダムシャッフル
		Collections.shuffle(countries);
		for (String c : countries) {
			System.out.println(c);
		}
		System.out.println("---");

		// ソート
		Collections.sort(countries);
		for (String c : countries) {
			System.out.println(c);
		}
	}
}
