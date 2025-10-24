module Parser

import Syntax;
import AST;
import ParseTree;
import Implode;
import IO;

public start[Module] parseModule(loc file) {
    return parse(#start[Module], file);
}

public start[Module] parseModule(str input, loc source) {
    return parse(#start[Module], input, source);
}

public start[Module] parseModule(str input) {
    return parse(#start[Module], input);
}

public AST::Module parseModuleToAST(loc file) {
    start[Module] cst = parseModule(file);
    return implode(cst);
}

public AST::Module parseModuleToAST(str input, loc source) {
    start[Module] cst = parseModule(input, source);
    return implode(cst);
}

public AST::Module parseModuleToAST(str input) {
    start[Module] cst = parseModule(input);
    return implode(cst);
}

public void testParse(loc file) {
    println("Parsing file: <file>");
    try {
        start[Module] cst = parseModule(file);
        println("Concrete syntax tree created successfully!");
        
        AST::Module ast = implode(cst);
        println("Abstract syntax tree created successfully!");
        println("\nAST:");
        println(ast);
    } catch ParseError(loc l): {
        println("Parse error at <l>");
    } catch e: {
        println("Error: <e>");
    }
}

public void testParseString(str input) {
    println("Parsing input...");
    try {
        start[Module] cst = parseModule(input);
        println("✓ Concrete syntax tree created successfully!");
        
        AST::Module ast = implode(cst);
        println("✓ Abstract syntax tree created successfully!");
        println("\nAST:");
        println(ast);
    } catch ParseError(loc l): {
        println("Parse error at <l>");
    } catch e: {
        println("Error: <e>");
    }
}