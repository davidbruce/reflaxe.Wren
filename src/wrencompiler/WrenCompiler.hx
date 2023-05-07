package wrencompiler;

#if ( macro || wren_runtime)

// Import relevant Haxe macro types.
import haxe.macro.Expr;
import haxe.macro.Type;

// Required Reflaxe types.
import reflaxe.BaseCompiler;
import reflaxe.PluginCompiler;

// Wren Compiler components
import wrencompiler.components.*;

/**
    The class that manages the generation of the Wren code.
    Its "impl" functions are called from Reflaxe.
**/
class WrenCompiler extends BaseCompiler {
    /**
        Singleton instance of compiler shared accross the project.
    **/
    public static final instance: WrenCompiler = new WrenCompiler();
    /**
        Constructor.
	**/
    private function new() {
	    super();
    }

    /**
        Generate the Wren output given the Haxe class information.
    **/
    public function compileClassImpl(classType: ClassType, varFields: ClassFieldVars, funcFields: ClassFieldFuncs): Null<String> {
        return WrenClass.compile(classType, varFields, funcFields);
    }

    /**
        Generate the Wren output given the Haxe enum information.
    **/
    public function compileEnumImpl(enumType: EnumType, options: EnumOptions): Null<String> {
        return WrenEnum.compile(enumType, options);
    }

    /**
        Generate the Wren output given the Haxe typed expression (`TypedExpr`).
    **/
    public function compileExpressionImpl(expr: TypedExpr): Null<String> {
        // trace("hit");
        return WrenExpr.compile(expr);
    }
}

#end
