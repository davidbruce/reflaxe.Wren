package;

class Test {
    final finalTestField = 123;
    public var varTestField = 987;
    public static var staticVarTestField = 5;

    public function new() {}
	public static function main() {
		// trace("Hello world.");
		var x = new Test();

		// var strLen = "string object".length;
		// trace(strLen);

		// untyped __testscript__("{} *** {}", 2 + 2, "Hello");
	}

	// public static function testMod(): Int {
	// 	return 0;
	// }
}
