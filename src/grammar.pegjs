///////////////////////////////////////////////////////////////////////////////
// WACC Compiler Group 27
// ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
// Author: lmj112 amv12 skd212 ot612
// File: grammer.pegjs
// Desc: pegjs file that describes the syntax for the WACC language.
///////////////////////////////////////////////////////////////////////////////

{
  var Nodes = require('./nodes'),
      Helpers = require('./nodeHelpers');
}

///////////////////////////////////////////////////////////////////////////////
// Lexical Grammer
///////////////////////////////////////////////////////////////////////////////

/*
   Match for a program, defined as a block of code, scoped by the terminals
   `begin` and `end` which contain a final statement to be returned and
   zero or more functions.
*/
Start
  = Comment* main:ProgramBlock? Ws* (Ws+ Comment*)?{ 
      if (main == '') return {};
      return main;
}

ProgramBlock
  = ('begin' Ws+ body:ProgramBody Ws* 'end'){ return body; }

ProgramBody
  = fs:(Function/Comment)* ss:Statement{ return new Nodes.Program((fs || []), ss); }

///////////////////////////////////////////////////////////////////////////////
// Functions and Parameters
///////////////////////////////////////////////////////////////////////////////

/*
   A function is defined by the return type, the function name, a parameter
   list surrounded by parentheses, followed by the terminals `is` and `end`
   which encapsulate statements.
*/
Function
  = fsig:FunctionDeclaration (Ws* 'is' Ws+) ss:FunctionBody Ws+ 'end' Ws*{
    return new Nodes.Function(ss, fsig.ident, fsig.returnType, fsig.paramList);
  }

FunctionBody
  = ReturnStatement

FunctionDeclaration
  = t:Type Ws+ i:Label Ws* ts:TypeSignature{
    if (ts == '') ts = null;
    return {'ident': i, 'returnType':t, 'paramList':ts};
  }

TypeSignature
  = '(' Ws* pl:ParamList? Ws* ')'{
    return pl;
}

/*
   Defines a list of parameter declarations with their respective types for
   defining a function type signature.
*/
ParamList
  = p1:Param t:ParamListTail*{
    var tail = t || [];
    return [p1].concat(tail);
  } 

ParamListTail
  = ',' Ws* p:Param{
    return p;
  }

/*
   Defines a single parameter token.
*/
Param
  = t:Type Ws+ i:Label{ return new Nodes.Param(i,t); }

///////////////////////////////////////////////////////////////////////////////
// WACC Statements
///////////////////////////////////////////////////////////////////////////////

/*
   The various different forms that a statement can take in the wacc
   specification. This is broken into types, tail and an overall statement
   type to avoid left recursive issues.
*/
Statement
  = a:StatementType b:StatementTail? {
      if (b == '') b = null;
      return new Nodes.Statement(a,b);
    }

StatementType
  = a:'skip'{ 
      return Helpers.constructStatement(Nodes, a, null);
    }
  / key:('println' / 'print' / 'free' / 'read' / 'exit') Ws+ e:Expr{
      return Helpers.constructStatement(Nodes, key, e);
    }
  / Scope / Conditional / While / Assignment

Scope
  = 'begin' Ws+ s:Statement* Ws* 'end' {
      return new Nodes.Scope(s);
    }
       
ReturnStatement
  = a:(Statement Ws* ';' Ws+)? 'return' Ws+ e:Expr{
      var ret = new Nodes.Statement(new Nodes.Return(e));
      if (a != '') {
        return a.right = ret;
      } return ret;
    }

Assignment
  = p1:ArrayType Ws+ Label Ws* '=' Ws* p2:ArrayLiteral{
      return new Nodes.AssignEqOp(p1, p2);
    }
  / p1:Param Ws* '=' Ws* p2:AssignRhs{
      return new Nodes.AssignEqOp(p1, p2);
    }
  / p1:AssignLhs Ws* '=' Ws* p2:AssignRhs{
      return new Nodes.AssignEqOp(p1, p2);
    }

Conditional
  = 'if' Ws+ cond:Expr Ws* 'then' Ws+ trueBody:IfBody Ws* 'else' Ws+ falseBody:IfBody Ws* 'fi'{
    return new Nodes.Conditional(cond, trueBody, falseBody);
  }

IfBody
  = ss:(Statement / ReturnStatement)?{
    if (ss = '') ss = {};
    return ss;
}

While
  = 'while' Ws+ cond:Expr Ws* 'do' Ws+ body:Statement Ws* 'done'{
    return new Nodes.While(cond, body);
  }

StatementTail
  = Ws* ';' Comment* Ws* s:Statement{
    return s;
  }

///////////////////////////////////////////////////////////////////////////////
// Assignment
///////////////////////////////////////////////////////////////////////////////

/*
   Assign Left Hand Side. Defines the possible elements to appear on the
   left of the assignment operator.
*/
AssignLhs
  = ArrayElem
  / PairElem
  / Ident

/*
   Assign Right Hand Side. Defines what is allowed to appear on the right
   of an assignment operator.
*/
AssignRhs
  = 'call' Ws+ label:Ident '(' Ws* args:ArgList? Ws* ')'{
    return new Nodes.FunctionApplication(label, args);
  }
  / 'newpair' Ws* '(' Ws* Expr Ws* ',' Ws* Expr Ws* ')' Ws*
  / PairElem
  / ArrayLiteral
  / Expr

///////////////////////////////////////////////////////////////////////////////
// Function Invokation
///////////////////////////////////////////////////////////////////////////////

/*
   Defines a list of arguments to be fed to a function call. Similar to
   a parameter list but without the type declaration.
*/
ArgList
  = e:Expr t:ArgListTail*{
    var tail = t || [];
    return [e].concat(tail);
  }
    

ArgListTail
  = Ws* ',' Ws+ e:Expr{
    return e;
  }

///////////////////////////////////////////////////////////////////////////////
// Operators
///////////////////////////////////////////////////////////////////////////////

/*
   Defines all unary operators.
*/
UnaryOp = key:(NotOp / SignOp / Builtin){
  return key;
}

NotOp
  = '!'

SignOp
  = '-'

Builtin
  = 'len'
  / 'ord'
  / 'toInt'

/*
   Defines all binary operators.
*/
BinOp = key:(ArithmeticOp/ComparisonOp){ return key; }

ArithmeticOp
  = key:('*' / '/' / '%' / '+' / '-'){ return key; }

ComparisonOp
  = key:('>=' / '>' / '<=' / '<' / '==' / '!=' / '&&' / '||'){ return key; }

///////////////////////////////////////////////////////////////////////////////
// Types and Expressions
///////////////////////////////////////////////////////////////////////////////

/*
   Selection of available types within the wacc static typing system.
*/
Type
  = ArrayType
  / PairType
  / BaseType

/*
   The barest type classes for use in wacc.
   TODO - Fill out details on each type
*/
BaseType
  = 'int'
  / 'bool'
  / 'char'
  / 'string'

/*
   Defines the expression token. All wacc expressions are side-effect free,
   and therefore do not modify program state.
   Split between the true expr, tail and types, this is to avoid left
   recursion issues.
*/
Expr
  = left:ExprType tail:ExprTail?{
    if (tail != '')
    {
      return new Helpers.constructBinary(Nodes, tail.op, left, tail.operand);
    }
    return left;
  }

ExprTail
  = (Ws* op:BinOp Ws* right:Expr){ return {'op': op, 'operand': right}; }

ExprType
  = '(' Ws* e:Expr Ws* ')'{
    return e;
  }
  / ArrayElem / PairElem
  / lit:(CharLiteral / StrLiteral / PairLiteral / IntLiteral / BoolLiteral){
    return Helpers.constructLiteral(Nodes, lit[0], lit[1]);
  }
  / op:UnaryOp Ws* value:Expr{
    return Helpers.constructUnary(Nodes, op, value);
  }
  / i:Ident { return i; }


///////////////////////////////////////////////////////////////////////////////
// Arrays
///////////////////////////////////////////////////////////////////////////////

/*
   Defines array type declarations. Matches to patterns like `int[]` for
   specifying the array content type.
   TODO - Clarify that array types are only of base type
*/
ArrayType
  = t:BaseType bs:('[' ']')+{
    throw new Error("Create node for array lhs");
  }

/*
   Defines elements within wacc arrays.
*/
ArrayElem
  = i:Ident accessors:('[' Ws* Expr Ws* ']')+{
    return new Nodes.ArrayLookup(i, accessors);
  }

///////////////////////////////////////////////////////////////////////////////
// Pairs
///////////////////////////////////////////////////////////////////////////////

/*
   Defines the declaration behaviour for use of typed pairs.
*/
PairType
  = 'pair' '(' Ws* t1:PairElemType Ws* ',' Ws* t2:PairElemType Ws* ')'{
    return new Nodes.PairType(t1, t2);
  }

/*=====================================////////////////========================
   Defines what is possible for an element of a pair.
*/
PairElem
  = a:PairAccessor Ws+ e:Expr{
    throw new Error("Add PairElem (fst/snd) to Nodes");
  }

PairAccessor
  = 'fst' / 'snd'

/*
   Covers what variable types may be used inside a wacc pair.
*/
PairElemType
  = BaseType
  / ArrayType
  / 'pair'

///////////////////////////////////////////////////////////////////////////////
// Variables and Literals
///////////////////////////////////////////////////////////////////////////////

/*
   Defines all idents, where these tokens will represent variable names.
   The rule states that the name must begin with an underscore or letter
   (case insensitive) followed by zero or more alphanumerical characters
   or underscores.
*/
Ident
  = i:Label { return new Nodes.Ident(i); }
Label
  = a:[_a-zA-Z] b:[_a-zA-Z0-9]* { return a + b; }

/*
   Defines all the reserved words of the language, including keywords
   such as 'begin', types such as 'int', etc.
*/
ReservedWord
  = 'begin'       // program
  / 'end'
  / 'is'          // function
  / 'skip'        // statements
  / 'read'
  / 'free'
  / 'return'
  / 'exit'
  / 'print'
  / 'println'
  / 'if'          // if
  / 'then'
  / 'else'
  / 'fi'
  / 'while'       // while
  / 'do'
  / 'done'
  / 'newpair'     // builtins
  / 'call'
  / 'len'
  / 'ord'
  / 'toInt'
  / 'int'         // types
  / 'bool'
  / 'char'
  / 'string'
  / 'pair'
  / 'fst'         // pair accessors
  / 'snd'

/*
   Int literal is represented by an optionally signed list of digits,
   to be interpreted by wacc as decimal integers.
*/
IntLiteral
  = sign:IntSign? digits:Digit+{
  var a = parseInt(digits.join(''),10);
  if (sign == '-') a = -a;
  if ((a > Math.pow(2, 31) - 1) || (a < -Math.pow(2,31)))
    throw new SyntaxError();
  else return new Nodes.IntLiteral(a);
}

/*
   Defines the integer signage for positive or negative notation.
*/
IntSign
  = ('+' / '-')

/*
   Defines the true and false string representation of the boolean
   literal token.
*/
BoolLiteral
  = bool:('true' / 'false'){
    return new Nodes.BoolLiteral(bool);
  }

/*
   Describes the literal representation of a character, specifically
   that it is a character surrounded by single quotes.
*/
CharLiteral
  = c:("#"/ "'" (Character/[#]) "'"){
    return new Nodes.CharLiteral(c);
  }

/*
   Very much similar to the character pattern but with double quotations
   and zero or more characters in length.
*/
StrLiteral
  = '"' chars:Character* '"'{
    return new Nodes.StringLiteral(chars);
  }

/*
   Defines the options for a character. Includes the possibility of
   escaping characters with a backslash.
*/
Character
  = [^\\\'\"]
  / '\\' EscapedChar

/*
   Defines the array literal notation. Zero or more elements demarkated
   by commas and represented by an expression token.
*/
ArrayLiteral
  = '[' Ws* elems:ArrayLiteralList? Ws* ']'{
    return new Nodes.ArrayLitera;(elems);
  }

ArrayLiteralList
  = e:Expr es:ArrayLiteralListTail?{
    return [e].concat(es);
  }

ArrayLiteralListTail
  = Ws* ',' Ws* e:Expr es:ArrayLiteralListTail?{
    if (es = '') return e;
    return [e].concat(es);
  }

/*
   Pairs are actually pointers, and so the literal representation is
   the null value. New pairs are created via the `newpair` call.
*/
PairLiteral
  = 'null'{ return new Nodes.PairLiteral('null'); }

///////////////////////////////////////////////////////////////////////////////
// Fundamentals
///////////////////////////////////////////////////////////////////////////////

/*
   Comments begin with a #, follow with a string consisting of any
   characters, followed by the end of line (EOL) terminator.
*/
Comment
  = Ws* '#' [^\n\r]* [\n\r] Ws*

/*
   Description of a digit, limited to the numbers from 0 to 9.
*/
Digit
  = [0-9]

/*
   Defines the characters that can represent a unicode symbol when
   used in conjunction with a backslash.
*/
EscapedChar
  = '0'/ 'b'/ 't' / 'n' / 'f' / 'r' / '"' / "'" / '\\'

/*
   Defines the different characters that may represent whitespace.
*/
Ws
  = [ \t\r\n]


