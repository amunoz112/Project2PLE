module Implode

import Syntax;
import Parser;
import AST;
import ParseTree;
import Node;

public AST::Module implode(Tree pt) = implode(#AST::Module, pt);

public AST::Module load(loc l) = implode(#AST::Module, parseModule(l));