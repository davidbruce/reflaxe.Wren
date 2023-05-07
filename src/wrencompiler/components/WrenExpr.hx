package wrencompiler.components;

#if (macro || wren_runtime)

import haxe.macro.Type;

import reflaxe.helpers.OperatorHelper;

using reflaxe.helpers.NameMetaHelper;
using reflaxe.helpers.ModuleTypeHelper;

import wrencompiler.WrenCompiler;

final compiler = WrenCompiler.instance;

inline function compile(expr: TypedExpr): String {
    return switch(expr.expr) {
        case TConst(c): constantToWren(c);
        case TLocal(v): v.getNameOrNative();
        case TArray(e1, e2): '${compiler.compileExpression(e1)}[${compiler.compileExpression(e2)}]';
        case TBinop(op, e1, e2): '${compiler.compileExpression(e1)} ${OperatorHelper.binopToString(op)} ${compiler.compileExpression(e2)}';
        case TField(e, fa): fieldAccessToWren(e, fa);
        case TTypeExpr(m): m.getNameOrNative();
        case TParenthesis(e): '($compiler.compiledExpression(e))';
        case TObjectDecl(fields): "TODO objectdecl";
        case TArrayDecl(el): '[${el.map(e -> compiler.compileExpression(e)).join(", "))}]';
        case TCall(e, el): '$compiler.compileExpression(e)(${el.map(e -> compiler.compileExpression(e)).join(",")})';
        case TNew(classTypeRef, _, el): '${classTypeRef.get().getNameOrNative()}.new(${el.map(e -> compiler.compileExpression(e)).join(", "))})';
        case TUnop(op, isPostfix, e):
            isPostfix ? (compiler.compileExpression(e) + OperatorHelper.unopToString(op))
                      : (OperatorHelper.unopToString(op) + compiler.compileExpression(e));
        case TFunction(tfunc): "TODO tfunction";
        case TVar(tvar, expr): "TODO tvar";
        case TBlock(el): "TODO tblock";
        case TFor(tvar, iterExpr, blockExpr): "TODO TFor";
        case TIf(econd, ifExpr, elseExpr): "TODO TIf";
        case TWhile(econd, blockExpr, normalWhile): "Todo TWhile";
        case TSwitch(e, cases, edef): "TODO TSwitch";
        case TTry(e, catches): "TODO TTry";
        case TReturn(maybeExpr): "TODO TReturn";
        case TBreak: "TODO TReturn";
        case TContinue: "TODO TContinue";
        case TThrow(expr): "TODO TThrow";
        case TCast(expr, maybeModuleType): "TODO TCast";
        case TMeta(metadataEntry, expr): "TODO TMeta";
        case TEnumParameter(expr, enumField, index): "TODO TEnumParameter";
        case TEnumIndex(e): "TODO TEnumIndex";
        case _: "";
    };
}

function constantToWren(constant: TConstant): String
    return switch(constant) {
        case TInt(i):    Std.string(i);
        case TFloat(s):  Std.string(s);
        case TString(s): "\"" + s + "\"";
        case TBool(b):   b ? "true" : "false";
        case TNull:      "null";
        case TThis:      "this";
        case TSuper:     "super";
        case _:          "";
    }


function fieldAccessToWren(e: TypedExpr, fa: FieldAccess): String {
    final nameMeta: NameAndMeta = switch(fa) {
        case FInstance(_, _, classFieldRef): classFieldRef.get();
        case FStatic(_, classFieldRef): classFieldRef.get();
        case FAnon(classFieldRef): classFieldRef.get();
        case FClosure(_, classFieldRef): classFieldRef.get();
        case FEnum(_, enumField): enumField;
        case FDynamic(s): { name: s, meta: null };
	}

    return '_${nameMeta.name}';
}


#end
