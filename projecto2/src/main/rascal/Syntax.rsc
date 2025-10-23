module Syntax

layout Layout = WhitespaceAndComment* !>> [\ \t\n\r#];
lexical WhitespaceAndComment = [\ \t\n\r] | @category="Comment" "#" ![\n]* $;

start syntax Module = aluModule: Variables? vars (Function | Data)* defs;

syntax Variables = vars: Identifier ("," Identifier)*;

syntax Function =
  functionDef:
    Assignment? "function" ("(" Variables ")")? "do" Body "end" Identifier name;

syntax Data =
  dataDef:
    Assignment? "data" "with" Variables DataBody "end" Identifier name;

syntax Assignment = assign: Identifier name "=";

syntax Body = body: Statement*;

syntax Statement
  = sExpr: Expression
  | sVars: Variables
  | sRange: Range
  | sIter: Iterator
  | sLoop: Loop
  | sIf: "if" Expression "then" Body "else" Body "end"
  | sCond: "cond" Expression "do" PatternBody "end"
  | sInvoke: Invocation
  ;

syntax Range =
  range: Assignment? "from" Principal from "to" Principal to;

syntax Iterator =
  iteratorDef:
    Assignment "iterator" "(" Variables ")" "yielding" "(" Variables ")";

syntax Loop =
  loopFor: "for" Identifier name Range "do" Body;

syntax DataBody = dataBody: Constructor | Function;

syntax Constructor =
  ctor: Identifier name "=" "struct" "(" Variables ")";

syntax PatternBody = pbody: Expression "-\>" Expression;

syntax Expression
  = principal: Principal
  > call: Invocation
  > parens: "(" Expression ")"
  | alulist: "[" Expression "]"
  | unaryMinus: "-" Expression
  > pow: Expression "**" Expression
  > mul: Expression "*" Expression  
  | div: Expression "/" Expression  
  | alumod: Expression "%" Expression
  > add: Expression "+" Expression
  | sub: Expression "-" Expression
  > rel1: Expression "\<=" Expression
  | rel2: Expression "\>=" Expression
  | rel3: Expression "\<" Expression
  | rel4: Expression "\>" Expression
  | rel5: Expression "\<\>" Expression
  | rel6: Expression "=" Expression
  > andE: Expression "and" Expression
  | orE:  Expression "or"  Expression
  > arrow: Expression "-\>" Expression
  | colon: Expression ":" Expression
  ;

syntax Invocation
  = invDollar: Identifier "$" "(" Variables ")"
  | invDot:    Identifier "." Identifier "(" Variables ")";

syntax Principal
  = pTrue: "true"
  | pFalse: "false"
  | pChar: CharLiteral
  | pInt: IntLiteral
  | pFloat: FloatLiteral
  | pId: Identifier
  ;

lexical Identifier = [A-Za-z][A-Za-z0-9]*;
lexical CharLiteral = [a-zA-Z];
lexical IntLiteral = [0-9]+;
lexical FloatLiteral = IntLiteral "." IntLiteral;

keyword Reserved =
  "cond" | "do" | "data" | "end" | "for" | "from" | "then" | "function" | "else" | "if" | "in" |
  "iterator" | "sequence" | "struct" | "to" | "tuple" | "type" | "with" | "yielding" |
  "true" | "false" |
  "*" | "/" | "-" | "+" | "**" | "%" | "\<" | "\>" | "\<=" | "\>=" | "\<\>" | "=" | "and" | "or" | "neg" |
  "-\>" | ":" | "$" | "." | "(" | ")" | "[" | "]";




