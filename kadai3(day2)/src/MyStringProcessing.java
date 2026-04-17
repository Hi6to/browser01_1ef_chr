
public class MyStringProcessing {
	
	
	/*自作メソッド:文字列と文字を入力し、その文字列内に文字が含まれる
	　場合trueを返し、そうでない場合はfalseを返す。大文字と小文字の区別はつけない
	　indexOf(int ch)とtoUpperCase()とtoLowerCase()を使った。
	*/
	public static boolean search_letter(String string, int letter) {
		if(string.indexOf(letter) != -1) {
			if('A' <= letter && letter <= 'Z') {
				string.toLowerCase();
				if(string.indexOf(letter) != -1) {
					return true;
				}
			}else if('a' <= letter && letter <= 'z') {
				string.toUpperCase();
				if(string.indexOf(letter) != -1) {
					return true;
				}
			}
			return false;
		}else {
			return true;
		}
	}

	public static void main(String args[]) {
		int n = Integer.parseInt(args[1]);
		if(search_letter(args[0], n)) {
			System.out.printf("included");
		}else {
			System.out.printf("No");
		}
	}
}
