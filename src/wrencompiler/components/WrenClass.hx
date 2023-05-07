package wrencompiler.components;

#if (macro || wren_runtime)

import haxe.macro.Type;
using haxe.macro.ExprTools;

import reflaxe.BaseCompiler;
using reflaxe.helpers.NameMetaHelper;
using reflaxe.helpers.SyntaxHelper;

using StringTools;
import wrencompiler.WrenCompiler;

final compiler = WrenCompiler.instance;

inline function compile(classType: ClassType, varFields: ClassFieldVars, funcFields: ClassFieldFuncs) {
    var decl = classType.getNameOrNativeName();

    var varString = varFields.map(vf -> {
        final field = vf.field;
        final variableDeclaration = (vf.isStatic)
            ? 'static ${field.getNameOrNative()}'
            : field.getNameOrNative();
        final wrenVal = (field.expr() != null)
            ? '${compiler.compileClassVarExpr(field.expr())}'
            : '_${field.getNameOrNativeName()}';

        trace(field.expr());
        // trace(field.getNameOrNativeName());
        // trace(compiler.compileClassVarExpr(field.expr()));
        trace(variableDeclaration);
        return '$variableDeclaration { $wrenVal }';
    }).join("\n");

    var funcString = funcFields.map(ff -> {
        final field = ff.field;
		final data = ff.data;
		final funcSig = '${field.getNameOrNative()}(${data.args.map(a -> a.name).join(", ")})';
        final staticModifier = (ff.isStatic)
            ? "static "
            : "";
		final funcContent = (data.expr != null)
            ? compiler.compileClassFuncExpr(data.expr)
            : "";

        if (field.name == 'new') {
            trace(data.expr);
        }

		return '$staticModifier$funcSig {\n${funcContent.tab()}\n}';
        // trace(f.field.name);
    }).join("\n");
    return 'class $decl {\n${varString.tab()}\n\n${funcString.tab()}\n}';
}

#end
