module Syntax

layout Layout = WhitespaceAndComment* !>> [\ \t\n\r#];
lexical WhitespaceAndComment = [\ \t\n\r] | @category="Comment" "#" ![\n]* $;

start syntax Module = aluModule: Variables? vars (Function | Data)* elements;

syntax Variables = variables: Identifier head ("," Identifier tail)* ;

syntax Function = function: Assignment? assign "function" ("(" Variables params ")")? "do" Body body "end" Identifier name;

syntax Data = aluData: Assignment? assign "data" "with" Variables vars DataBody dataBody "end" Identifier name;

syntax Assignment = assignment: Identifier id "=";

syntax Body = body: Statement* statements;

syntax Statement = expressionStmt: Expression expr
                 | variablesStmt: Variables vars
                 | rangeStmt: Range range
                 | iteratorStmt: Iterator iterator
                 | loopStmt: Loop loop
                 | ifStmt: "if" Expression condition "then" Body thenBody "else" Body elseBody "end"
                 | condStmt: "cond" Expression expr "do" PatternBody patterns "end"
                 | invocationStmt: Invocation invocation;

syntax Range = range: Assignment? assign "from" Principal from "to" Principal to;

syntax Iterator = iterator: Assignment assign "iterator" "(" Variables inputVars ")" "yielding" "(" Variables outputVars ")";

syntax Loop = loop: "for" Identifier id Range range "do" Body body;

syntax DataBody = constructorBody: Constructor constructor
                | functionBody: Function function;

syntax Constructor = constructor: Identifier id "=" "struct" "(" Variables vars ")";

syntax PatternBody = pattern: Expression condition "-\>" Expression result;

syntax Expression = bracket "(" Expression ")"
                  | bracket "[" Expression "]"
                  > principal: Principal principal
                  | invocation: Invocation invocation
                  > negation: "-" Expression expr
                  > left power: Expression lhs "**" Expression rhs
                  > left ( multiplication: Expression lhs "*" Expression rhs
                         | division: Expression lhs "/" Expression rhs
                         | modulo: Expression lhs "%" Expression rhs
                         )
                  > left ( addition: Expression lhs "+" Expression rhs
                         | subtraction: Expression lhs "-" Expression rhs
                         )
                  > non-assoc ( lessThan: Expression lhs "\<" Expression rhs
                              | greaterThan: Expression lhs "\>" Expression rhs
                              | lessOrEqual: Expression lhs "\<=" Expression rhs
                              | greaterOrEqual: Expression lhs "\>=" Expression rhs
                              | notEqual: Expression lhs "\<\>" Expression rhs
                              | equal: Expression lhs "=" Expression rhs
                              )
                  > left and: Expression lhs "and" Expression rhs
                  > left or: Expression lhs "or" Expression rhs
                  > right arrow: Expression lhs "-\>" Expression rhs
                  > right colon: Expression lhs ":" Expression rhs;

syntax Invocation = dollarInvoke: Identifier id "$" "(" Variables args ")"
                  | dotInvoke: Identifier object "." Identifier method "(" Variables args ")";

syntax Principal = boolTrue: "true"
                 | boolFalse: "false"
                 | charLit: CharLiteral char
                 | intLit: IntLiteral integer
                 | floatLit: FloatLiteral float
                 | identifier: Identifier id;

lexical Identifier = ([a-z][a-z]*) ;
lexical CharLiteral = "\'" [a-z] "\'";
lexical IntLiteral = [0-9]+;
lexical FloatLiteral = [0-9]+ "." [0-9]+;

keyword Reserved = "true" | "false" | "and" | "or" | "neg" 
                 | "cond" | "do" | "data" | "end" | "for" | "from" | "then"
                 | "function" | "else" | "if" | "in" | "iterator" | "sequence"
                 | "struct" | "to" | "tuple" | "type" | "with" | "yielding";