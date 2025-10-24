module Plugin

import IO;
import ParseTree;
import util::Reflective;
import util::IDEServices;
import util::LanguageServer;
import Syntax;

// Configure the project path - CHANGE THIS to your actual project path
PathConfig pcfg = getProjectPathConfig(|project://projectoalu|);

// Define the ALU language
Language aluLang = language(pcfg, "ALU", "alu", "Plugin", "contribs");

// Language contributions (parser for syntax highlighting)
set[LanguageService] contribs() = {
    parser(start[Module] (str program, loc src) {
        return parse(#start[Module], program, src);
    })
};

// Main function to register the language
void main() {
    registerLanguage(aluLang);
    println("ALU Language registered successfully!");
    println("You can now open .alu files with syntax highlighting.");
}