module Parser

import Syntax;
import AST;
import ParseTree;
import IO;

public Module parseALU(loc file) {
  value tree = parse(#start[Module], readFile(file));
  println("Parseo exitoso");

  Module ast = implode(tree);
  println("AST generado correctamente");

  return ast;
}

public void main() {
  loc src = |project://projecto2/instance/test.alu|;
  Module ast = parseALU(src);
  println(ast);
}
