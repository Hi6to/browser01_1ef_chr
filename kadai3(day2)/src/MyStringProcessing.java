
public class MyStringProcessing {
	
	
	/*自作メソッド:文字列と文字を入力し、その文字列内に文字が含まれる
	　場合trueを返し、そうでない場合はfalseを返す。大文字と小文字の区別はつけない
	　indexOf(int ch)とtoLowerCase()を使った。
	*/
	public static boolean search_letter(String string, char letter) {
		String lowerString = string.toLowerCase();
		char lowerletter = Character.toLowerCase(letter);
		
		return lowerString.indexOf(lowerletter) != -1;
		
	}

	public static void main(String args[]) {
		char c = args[1].charAt(0);
		if(search_letter(args[0], c)) {
			System.out.printf("included");
		}else {
			System.out.printf("No");
		}
	}
}
