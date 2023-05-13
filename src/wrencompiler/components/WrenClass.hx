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

    var staticFieldsToInit = new Map<String, String>();
    final fieldStrings = varFields.map(vf -> {
        final field = vf.field;
        //In Wren non-public instance variables are created in the constructor
        if (!field.isPublic) { return ''; }

        var varName = '';
        var wrenVal = '';

        if (vf.isStatic) {
            varName = 'static ${field.getNameOrNative()}';
            wrenVal = '__${field.getNameOrNativeName()}';
            staticFieldsToInit.set('${field.getNameOrNative()}', '${compiler.compileClassVarExpr(field.expr())}');
        } else {
            varName = '${field.getNameOrNative()}';
            wrenVal = '_${field.getNameOrNativeName()}';
        }
        // final varName = (vf.isStatic)
        //     ? 'static ${field.getNameOrNative()}'
        //     : field.getNameOrNative();
        // final wrenVal = (field.expr() != null)
        //     ? '${compiler.compileClassVarExpr(field.expr())}'
        //     : '_${field.getNameOrNativeName()}';

        return '$varName { $wrenVal }\n$varName=(value) { $wrenVal = value }';
    }).filter(str -> str != '');

    //Add empty string that effectively gets replaced by the newline join
    if (fieldStrings.length > 0) {
        fieldStrings.push('');
    }

    var hasMainMethod = false;
    final funcStrings = funcFields.map(ff -> {
        final field = ff.field;
        if (field.name == 'main' && ff.isStatic) {
            hasMainMethod = true;
        }
		final data = ff.data;
		final funcSig = '${field.getNameOrNative()}(${data.args.map(a -> a.name).join(", ")})';
        final constructor = field.name == 'new'
            ? "construct "
            : "";
        final staticModifier = (ff.isStatic)
            ? "static "
            : "";
		final funcContent = (data.expr != null)
            ? compiler.compileClassFuncExpr(data.expr)
            : "";

		return '$staticModifier$constructor$funcSig {\n${funcContent.tab()}\n}';
    });

    final body = fieldStrings.concat(funcStrings).join('\n').tab();
    var result = 'class $decl {\n${body}\n}';
    for (k => v in staticFieldsToInit) {
        result = '$result\n$decl.$k = $v';
    }
    if (hasMainMethod) {
        result = '$result\n\n$decl.main()';
    }
    return result;
}

#end
