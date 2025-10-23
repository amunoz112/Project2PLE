module Plugin

import IO;
import ParseTree;
import util::Reflective;
import util::IDEServices;
import util::LanguageServer;
import Relation;
import Syntax; 

PathConfig pcfg = getProjectPathConfig(|project://projecto2|);

Language aluLang = language(pcfg, "ALU", "alu", "Plugin", "contribs");

set[LanguageService] contribs() = {
  parser(start[Module] (str program, loc src) {
    return parse(#start[Module], program, src);
  })
};

// Registra el lenguaje en VS Code
void main() {
  registerLanguage(aluLang);
}
