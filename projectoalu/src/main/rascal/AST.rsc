module AST

data Module = aluModule(list[str] vars, list[Element] elements);

data Element = functionElement(Function func)
             | dataElement(Data aluData);

data Function = function(
    list[Assignment] assign,      
    list[str] params,              
    Body body,
    str name
);

data Data = aluData(
    list[Assignment] assign,      
    list[str] vars,
    DataBody dataBody,
    str name
);

// Assignment
data Assignment = assignment(str id);

// Body
data Body = body(list[Statement] statements);

// Statement types
data Statement = expressionStmt(Expression expr)
               | variablesStmt(list[str] vars)
               | rangeStmt(Range range)
               | iteratorStmt(Iterator iterator)
               | loopStmt(Loop loop)
               | ifStmt(Expression condition, Body thenBody, Body elseBody)
               | condStmt(Expression expr, list[Pattern] patterns)
               | invocationStmt(Invocation invocation);

// Range
data Range = range(list[Assignment] assign, Principal from, Principal to);

// Iterator
data Iterator = iterator(Assignment assign, list[str] inputVars, list[str] outputVars);

// Loop
data Loop = loop(str id, Range range, Body body);

// DataBody
data DataBody = constructorBody(Constructor constructor)
              | functionBody(Function function);

// Constructor
data Constructor = constructor(str id, list[str] vars);

// Pattern for cond statement
data Pattern = pattern(Expression condition, Expression result);

// Expression types
data Expression = principal(Principal principal)
                | invocation(Invocation invocation)
                | aluBracket(Expression expr)
                | squareBracket(Expression expr)
                | negation(Expression expr)
                | power(Expression lhs, Expression rhs)
                | multiplication(Expression lhs, Expression rhs)
                | division(Expression lhs, Expression rhs)
                | modulo(Expression lhs, Expression rhs)
                | addition(Expression lhs, Expression rhs)
                | subtraction(Expression lhs, Expression rhs)
                | lessThan(Expression lhs, Expression rhs)
                | greaterThan(Expression lhs, Expression rhs)
                | lessOrEqual(Expression lhs, Expression rhs)
                | greaterOrEqual(Expression lhs, Expression rhs)
                | notEqual(Expression lhs, Expression rhs)
                | equal(Expression lhs, Expression rhs)
                | and(Expression lhs, Expression rhs)
                | or(Expression lhs, Expression rhs)
                | arrow(Expression lhs, Expression rhs)
                | colon(Expression lhs, Expression rhs);

// Invocation types
data Invocation = dollarInvoke(str id, list[str] args)
                | dotInvoke(str object, str method, list[str] args);

// Principal (atomic values)
data Principal = boolTrue()
               | boolFalse()
               | charLit(str char)
               | intLit(int integer)
               | floatLit(real float)
               | identifier(str id);