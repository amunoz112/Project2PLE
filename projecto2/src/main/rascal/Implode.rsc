module Implode

import Syntax;
import Parser;
import AST;
import ParseTree;
import Node;

// Implode a parse tree to AST
public AST::Module implode(Tree pt) = implode(#AST::Module, pt);

// Load and implode from file location
public AST::Module load(loc l) = implode(#AST::Module, parseModule(l));