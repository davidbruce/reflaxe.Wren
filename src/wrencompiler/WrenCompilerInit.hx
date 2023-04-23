package wrencompiler;

#if (macro || cs_runtime)

import haxe.macro.Context;

import reflaxe.ReflectCompiler;
import reflaxe.input.ClassModifier;

using reflaxe.helpers.ExprHelper;

class WrenCompilerInit {
	public static function Start() {
		#if !eval
		Sys.println("WrenCompilerInit.Start can only be called from a macro context.");
		return;
		#end

		#if (haxe_ver < "4.3.0")
		Sys.println("Reflaxe/Wren requires Haxe version 4.3.0 or greater.");
		return;
		#end

		ReflectCompiler.AddCompiler(new WrenCompiler(), {
			fileOutputExtension: ".wren",
			outputDirDefineName: "wren-output",
			fileOutputType: FilePerClass,
			reservedVarNames: reservedNames(),
			targetCodeInjectionName: "__wren__",
			smartDCE: true,
		});
	}

	// https://wren.io/syntax.html#reserved-words
	static function reservedNames() {
		return [
            "as", "break", "class", "construct", "continue", "else", "false", "for", "foreign", "if", "import",
            "in", "is", "null", "return", "static", "super", "this", "true", "var", "while"
        ];
	}
}

#end
