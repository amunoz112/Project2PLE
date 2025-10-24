module Generator

import AST;
import Parser;
import IO;
import Map;
import List;
import String;

// ============================================================================
// ENVIRONMENT - Storage for variables and functions
// ============================================================================

// Type for values in our interpreter
data Value = intVal(int n)
           | realVal(real r)
           | boolVal(bool b)
           | charVal(str c)
           | funcVal(Function f)
           | structVal(str name, map[str, Value] fields)
           | noneVal();

// Environment for variable bindings
alias Env = map[str, Value];

// Global environment to store functions and data definitions
Env globalEnv = ();

// Current local environment (for function parameters and local vars)
Env localEnv = ();

// ============================================================================
// MAIN EXECUTION FUNCTIONS
// ============================================================================

// Main entry point - Execute a module
void execute(AST::Module m) {
    println("=== Starting ALU Program Execution ===\n");
    
    // Initialize environments
    globalEnv = ();
    localEnv = ();
    
    // Declare global variables
    for (varName <- m.vars) {
        globalEnv[varName] = noneVal();
        println("Declared global variable: <varName>");
    }
    
    println();
    
    // Process all elements (functions and data definitions)
    for (elem <- m.elements) {
        executeElement(elem);
    }
    
    println("\n=== Program Execution Complete ===");
}

// Execute an element (function or data definition)
void executeElement(Element elem) {
    switch(elem) {
        case functionElement(f): {
            executeFunctionDefinition(f);
        }
        case dataElement(d): {
            executeDataDefinition(d);
        }
    }
}

// Store function definition in global environment
void executeFunctionDefinition(Function f) {
    str name = f.name;
    
    // Handle assignment if present
    if (size(f.assign) > 0) {
        str assignName = f.assign[0].id;
        globalEnv[assignName] = funcVal(f);
        println("Function \'<name>\' assigned to variable \'<assignName>\'");
    } else {
        globalEnv[name] = funcVal(f);
        println("Function \'<name>\' defined");
    }
    
    // Auto-execute functions without parameters for demonstration
    if (size(f.params) == 0) {
        println("  Executing \'<name>()\'...");
        Value result = executeFunction(f, []);
        println("  Result: <valueToString(result)>\n");
    } else {
        println("  (function with parameters, call manually)\n");
    }
}

// Store data definition in global environment
void executeDataDefinition(Data d) {
    str name = d.name;
    
    // Handle assignment if present
    if (size(d.assign) > 0) {
        str assignName = d.assign[0].id;
        println("Data structure \'<name>\' assigned to \'<assignName>\'");
    } else {
        println("Data structure \'<name>\' defined");
    }
    
    // Process data body (constructor or function)
    switch(d.dataBody) {
        case constructorBody(c): {
            println("  Constructor: <c.id>(<intercalate(", ", c.vars)>)\n");
        }
        case functionBody(f): {
            println("  With function: <f.name>\n");
        }
    }
}

// Execute a function with given arguments
Value executeFunction(Function f, list[Value] args) {
    // Create new local environment
    Env savedLocalEnv = localEnv;
    localEnv = ();
    
    // Bind parameters to arguments
    if (size(f.params) != size(args)) {
        throw "Function <f.name> expects <size(f.params)> arguments but got <size(args)>";
    }
    
    for (int i <- [0..size(f.params)]) {
        localEnv[f.params[i]] = args[i];
    }
    
    // Execute function body
    Value result = executeBody(f.body);
    
    // Restore previous local environment
    localEnv = savedLocalEnv;
    
    return result;
}

// ============================================================================
// STATEMENT EXECUTION
// ============================================================================

// Execute a body (list of statements)
Value executeBody(Body b) {
    Value lastResult = noneVal();
    
    for (stmt <- b.statements) {
        lastResult = executeStatement(stmt);
    }
    
    return lastResult;
}

// Execute a single statement
Value executeStatement(Statement stmt) {
    switch(stmt) {
        case expressionStmt(expr): {
            return evaluateExpression(expr);
        }
        case variablesStmt(vars): {
            for (v <- vars) {
                localEnv[v] = noneVal();
            }
            return noneVal();
        }
        case rangeStmt(r): {
            return executeRange(r);
        }
        case iteratorStmt(it): {
            println("  Iterator statement (not fully implemented)");
            return noneVal();
        }
        case loopStmt(l): {
            return executeLoop(l);
        }
        case ifStmt(condition, thenBody, elseBody): {
            Value condResult = evaluateExpression(condition);
            if (isTruthy(condResult)) {
                return executeBody(thenBody);
            } else {
                return executeBody(elseBody);
            }
        }
        case condStmt(expr, patterns): {
            Value exprResult = evaluateExpression(expr);
            for (pattern <- patterns) {
                // Evaluate pattern condition
                Value patternCond = evaluateExpression(pattern.condition);
                if (isTruthy(patternCond)) {
                    return evaluateExpression(pattern.result);
                }
            }
            return noneVal();
        }
        case invocationStmt(inv): {
            return executeInvocation(inv);
        }
    }
    return noneVal();
}

// Execute a range statement
Value executeRange(Range r) {
    Value fromVal = evaluatePrincipal(r.from);
    Value toVal = evaluatePrincipal(r.to);
    
    if (fromVal is intVal && toVal is intVal) {
        list[int] rangeList = [fromVal.n..toVal.n + 1];
        println("  Range: <rangeList>");
        return intVal(size(rangeList));
    }
    
    return noneVal();
}

// Execute a loop
Value executeLoop(Loop l) {
    Value lastResult = noneVal();
    
    // Get range
    Value fromVal = evaluatePrincipal(l.range.from);
    Value toVal = evaluatePrincipal(l.range.to);
    
    if (fromVal is intVal && toVal is intVal) {
        for (int i <- [fromVal.n..toVal.n + 1]) {
            localEnv[l.id] = intVal(i);
            lastResult = executeBody(l.body);
        }
    }
    
    return lastResult;
}

// ============================================================================
// EXPRESSION EVALUATION
// ============================================================================

// Evaluate an expression
Value evaluateExpression(Expression expr) {
    switch(expr) {
        case principal(p): {
            return evaluatePrincipal(p);
        }
        case invocation(inv): {
            return executeInvocation(inv);
        }
        case bracket(e): {
            return evaluateExpression(e);
        }
        case squareBracket(e): {
            return evaluateExpression(e);
        }
        case negation(e): {
            Value v = evaluateExpression(e);
            if (v is intVal) return intVal(-v.n);
            if (v is realVal) return realVal(-v.r);
            throw "Cannot negate <v>";
        }
        case power(lhs, rhs): {
            return applyBinaryOp(lhs, rhs, "**");
        }
        case multiplication(lhs, rhs): {
            return applyBinaryOp(lhs, rhs, "*");
        }
        case division(lhs, rhs): {
            return applyBinaryOp(lhs, rhs, "/");
        }
        case modulo(lhs, rhs): {
            return applyBinaryOp(lhs, rhs, "%");
        }
        case addition(lhs, rhs): {
            return applyBinaryOp(lhs, rhs, "+");
        }
        case subtraction(lhs, rhs): {
            return applyBinaryOp(lhs, rhs, "-");
        }
        case lessThan(lhs, rhs): {
            return applyComparison(lhs, rhs, "\<");
        }
        case greaterThan(lhs, rhs): {
            return applyComparison(lhs, rhs, "\>");
        }
        case lessOrEqual(lhs, rhs): {
            return applyComparison(lhs, rhs, "\<=");
        }
        case greaterOrEqual(lhs, rhs): {
            return applyComparison(lhs, rhs, "\>=");
        }
        case notEqual(lhs, rhs): {
            return applyComparison(lhs, rhs, "\<\>");
        }
        case equal(lhs, rhs): {
            return applyComparison(lhs, rhs, "=");
        }
        case and(lhs, rhs): {
            Value l = evaluateExpression(lhs);
            Value r = evaluateExpression(rhs);
            return boolVal(isTruthy(l) && isTruthy(r));
        }
        case or(lhs, rhs): {
            Value l = evaluateExpression(lhs);
            Value r = evaluateExpression(rhs);
            return boolVal(isTruthy(l) || isTruthy(r));
        }
        case arrow(lhs, rhs): {
            println("  Arrow operator (not fully implemented)");
            return noneVal();
        }
        case colon(lhs, rhs): {
            println("  Colon operator (not fully implemented)");
            return noneVal();
        }
    }
    return noneVal();
}

// Evaluate a principal (atomic value)
Value evaluatePrincipal(Principal p) {
    switch(p) {
        case boolTrue(): return boolVal(true);
        case boolFalse(): return boolVal(false);
        case charLit(c): return charVal(c);
        case intLit(n): return intVal(n);
        case floatLit(f): return realVal(f);
        case identifier(id): {
            // Look up variable in local environment first, then global
            if (id in localEnv) {
                return localEnv[id];
            } else if (id in globalEnv) {
                return globalEnv[id];
            } else {
                throw "Undefined variable: <id>";
            }
        }
    }
    return noneVal();
}

// Execute an invocation
Value executeInvocation(Invocation inv) {
    switch(inv) {
        case dollarInvoke(id, args): {
            // Look up function
            if (id notin globalEnv) {
                throw "Undefined function: <id>";
            }
            
            Value funcValue = globalEnv[id];
            if (funcValue is funcVal) {
                // Evaluate arguments
                list[Value] argValues = [];
                for (arg <- args) {
                    if (arg in localEnv) {
                        argValues += localEnv[arg];
                    } else if (arg in globalEnv) {
                        argValues += globalEnv[arg];
                    } else {
                        throw "Undefined argument: <arg>";
                    }
                }
                
                return executeFunction(funcValue.f, argValues);
            } else {
                throw "<id> is not a function";
            }
        }
        case dotInvoke(object, method, args): {
            println("  Method invocation (not fully implemented)");
            return noneVal();
        }
    }
    return noneVal();
}

// ============================================================================
// HELPER FUNCTIONS
// ============================================================================

// Apply binary arithmetic operation
Value applyBinaryOp(Expression lhs, Expression rhs, str op) {
    Value l = evaluateExpression(lhs);
    Value r = evaluateExpression(rhs);
    
    // Integer operations
    if (l is intVal && r is intVal) {
        switch(op) {
            case "+": return intVal(l.n + r.n);
            case "-": return intVal(l.n - r.n);
            case "*": return intVal(l.n * r.n);
            case "/": return intVal(l.n / r.n);
            case "%": return intVal(l.n % r.n);
            case "**": return intVal(round(pow(toReal(l.n), toReal(r.n))));
        }
    }
    
    // Real operations
    if ((l is realVal || l is intVal) && (r is realVal || r is intVal)) {
        real lv = (l is realVal) ? l.r : toReal(l.n);
        real rv = (r is realVal) ? r.r : toReal(r.n);
        
        switch(op) {
            case "+": return realVal(lv + rv);
            case "-": return realVal(lv - rv);
            case "*": return realVal(lv * rv);
            case "/": return realVal(lv / rv);
            case "**": return realVal(pow(lv, rv));
        }
    }
    
    throw "Type error in operation <op>";
}

// Apply comparison operation
Value applyComparison(Expression lhs, Expression rhs, str op) {
    Value l = evaluateExpression(lhs);
    Value r = evaluateExpression(rhs);
    
    if (l is intVal && r is intVal) {
        switch(op) {
            case "\<": return boolVal(l.n < r.n);
            case "\>": return boolVal(l.n > r.n);
            case "\<=": return boolVal(l.n <= r.n);
            case "\>=": return boolVal(l.n >= r.n);
            case "=": return boolVal(l.n == r.n);
            case "\<\>": return boolVal(l.n != r.n);
        }
    }
    
    if ((l is realVal || l is intVal) && (r is realVal || r is intVal)) {
        real lv = (l is realVal) ? l.r : toReal(l.n);
        real rv = (r is realVal) ? r.r : toReal(r.n);
        
        switch(op) {
            case "\<": return boolVal(lv < rv);
            case "\>": return boolVal(lv > rv);
            case "\<=": return boolVal(lv <= rv);
            case "\>=": return boolVal(lv >= rv);
            case "=": return boolVal(lv == rv);
            case "\<\>": return boolVal(lv != rv);
        }
    }
    
    if (l is boolVal && r is boolVal) {
        switch(op) {
            case "=": return boolVal(l.b == r.b);
            case "\<\>": return boolVal(l.b != r.b);
        }
    }
    
    throw "Type error in comparison <op>";
}

// Check if a value is truthy
bool isTruthy(Value v) {
    switch(v) {
        case boolVal(b): return b;
        case intVal(n): return n != 0;
        case realVal(r): return r != 0.0;
        case noneVal(): return false;
        default: return true;
    }
}

// Convert value to string for printing
str valueToString(Value v) {
    switch(v) {
        case intVal(n): return "<n>";
        case realVal(r): return "<r>";
        case boolVal(b): return "<b>";
        case charVal(c): return "\'<c>\'";
        case funcVal(f): return "\<function <f.name>\>";
        case noneVal(): return "none";
        default: return "<v>";
    }
}

// ============================================================================
// MAIN FUNCTION FOR TESTING
// ============================================================================

void main() {
    println("Testing ALU Interpreter...\n");
    
}    loc exampleFile = |project://projecto2/instance/test.alu|;
    
    try {
        println("Parsing <exampleFile>...");
        AST::Module ast = parseModuleToAST(exampleFile);
        println("✓ Parse successful!\n");
        
        execute(ast);
    } catch ParseError(loc l): {
        println("Parse error at <l>");
    } catch e: {
        println("Error: <e>");
    }
}