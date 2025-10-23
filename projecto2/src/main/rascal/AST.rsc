module AST

data Module = aluModule(
  value vars,               
  list[value] defs          
);

data Variables = variables(list[str] ids);     
data Assignment = assignment(str name);

data Function = function(
  value preAssign,         
  value params,             
  Body body,
  str name                  
);

data Data = aluData(
  value preAssign,         
  Variables vars,
  DataBody body,
  str name
);

data DataBody
  = constructorData(Constructor c)
  | functionData(Function f)
  ;

data Constructor = constructor(str name, Variables vars);

data Body = body(list[Statement] stmts);

data Statement
  = exprStmt(Expression expr)
  | varStmt(Variables vars)
  | rangeStmt(Range range)
  | iteratorStmt(Iterator iter)
  | loopStmt(Loop loop)
  | ifStmt(Expression cond, Body thenBody, Body elseBody)
  | condStmt(Expression expr, PatternBody pat)
  | invocationStmt(Invocation inv)
  ;

data Range = range(value preAssign, Principal from, Principal to);
data Iterator = iterator(Assignment assign, Variables inVars, Variables outVars);
data Loop = loop(str id, Range range, Body body);
data PatternBody = pattern(Expression left, Expression right);

data Expression
  = principal(Principal p)
  | invocationExpr(Invocation i)
  | parenExpr(Expression e)
  | bracketExpr(Expression e)
  | negExpr(Expression e)
  | divExpr(Expression l, Expression r)
  | modExpr(Expression l, Expression r)
  | mulExpr(Expression l, Expression r)
  | addExpr(Expression l, Expression r)
  | subExpr(Expression l, Expression r)
  | powExpr(Expression l, Expression r)
  | ltExpr(Expression l, Expression r)
  | gtExpr(Expression l, Expression r)
  | leqExpr(Expression l, Expression r)
  | geqExpr(Expression l, Expression r)
  | neqExpr(Expression l, Expression r)
  | eqExpr(Expression l, Expression r)
  | andExpr(Expression l, Expression r)
  | orExpr(Expression l, Expression r)
  | arrowExpr(Expression l, Expression r)
  | colonExpr(Expression l, Expression r)
  ;

data Invocation
  = simpleInvocation(str name, Variables args)
  | memberInvocation(str obj, str method, Variables args)
  ;

data Principal
  = boolTrue()
  | boolFalse()
  | char(str c)
  | integer(int n)
  | float(real x)
  | id(str name)
  ;
