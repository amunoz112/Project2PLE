module Plugin

import IO;
import ParseTree;
import util::Reflective;
import Syntax;

PathConfig pcfg = getProjectPathConfig(|project://projecto2|);

void main() {
    println("========================================");
    println("Registering ALU Language...");
    println("========================================");
    
    registerLanguage(
        language(
            pcfg,
            "ALU",
            "alu",
            "Plugin",
            "aluParser"
        )
    );
    
    println("✓ ALU Language registered successfully!");
    println("✓ You can now open .alu files");
    println("✓ Syntax highlighting should work");
    println("========================================");
}

Tree aluParser(str input, loc origin) {
    return parse(#start[Module], input, origin);
}