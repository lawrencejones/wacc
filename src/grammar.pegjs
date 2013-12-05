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
      if (main != '')
        main.verify();
      return main;
  }

ProgramBlock
  = ('begin' Ws+ body:ProgramBody Ws* 'end'){ return body; }

ProgramBody
  = fs:(Function/Comment)* s:Statement{
      return new Nodes.Program({ statement: s, functions:(fs || [])});
  }

///////////////////////////////////////////////////////////////////////////////
// Functions and Parameters
///////////////////////////////////////////////////////////////////////////////

/*
   A function is defined by the return type, the function name, a parameter
   list surrounded by parentheses, followed by the terminals `is` and `end`
   which encapsulate statements.
*/
Function
  = fsig:FunctionDeclaration (Ws* 'is' Ws+) s:FunctionBody Ws+ 'end' Ws*{
    fsig.statement = s;
    return new Nodes.FunctionDeclaration(fsig);
  }

FunctionBody
  = s:ReturnStatement { return s; }

FunctionDeclaration
  = t:Type Ws+ i:Label Ws* ts:TypeSignature{
    return {rtype: t, ident: i, paramList: ts};
  }

TypeSignature
  = '(' Ws* pl:ParamList? Ws* ')'{
    if (pl == '') return [];
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
  = t:Type Ws+ i:Label{
    return new Nodes.Param( {ident: i, typeSig: t} );
  }

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
    return new Nodes.Statement({left: a, right: b});
  }

StatementType
  = a:'skip' { 
    return new Nodes.Skip();
  }
  / key:('println' / 'print' / 'free' / 'read' / 'exit') Ws+ e:Expr{
    return Helpers.constructStatement(Nodes, key, {rhs: e});
  }
  / item:(Scope / Conditional / While / Assignment){
    return item;
  }

Scope
  = 'begin' Ws+ s:Statement* Ws* 'end' {
    return new Nodes.Scope(s);
  }
       
ReturnStatement
  = a:(Statement Ws* ';' Ws+)? 'return' Ws+ e:Expr{
    var ret = new Nodes.Return({rhs: e});
    if (a == '')
    {
      return new Nodes.Statement({left: ret, right: null});
    }
    return new Nodes.Statement({left: a, right: ret});
  }

Assignment
    // int[] label ...
  = p1:ArrayType Ws+ i:Label Ws* '=' Ws* rhs:ArrayLiteral{
      var lhs = new Nodes.ArrayType({ident: i, typeSig: p1});
      return new Nodes.Declaration({lhs: lhs, rhs: rhs});
    }
  / lhs:AssignLhs Ws* '=' Ws* rhs:AssignRhs{
      return new Nodes.Assignment({lhs: lhs, rhs: rhs});
    }
  / lhs:Param Ws* '=' Ws* rhs:AssignRhs{
       return new Nodes.Declaration({lhs: lhs, rhs: rhs});
    }

Conditional
  = 'if' Ws+ cond:Expr Ws* 'then' Ws+ trueBody:IfBody Ws* 'else' Ws+ elseBody:IfBody Ws* 'fi'{
    return new Nodes.Conditional({
      condition: cond,
      body: trueBody,
      elseBody: elseBody
    });
  }

IfBody
  = s:(Statement / ReturnStatement)?{
    if (s = '') return new Nodes.Skip({rhs: null});
    return s;
}

While
  = 'while' Ws+ cond:Expr Ws* 'do' Ws+ body:Statement Ws* 'done'{
    return new Nodes.While({
      condition: cond,
      body:body
    });
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
  = lhs:(ArrayElem / PairElem / Ident){
    return lhs;
  }

/*
   Assign Right Hand Side. Defines what is allowed to appear on the right
   of an assignment operator.
*/
AssignRhs
  = 'call' Ws+ label:Ident '(' Ws* args:ArgList? Ws* ')'{
    return new Nodes.FunctionApplication({
      args: args, ident:label
    });
  }
  / 'newpair' Ws* '(' Ws* fst:Expr Ws* ',' Ws* snd:Expr Ws* ')' Ws*{
    return new Nodes.PairLiteral({
      value: { fst: fst, snd: snd }
    });
  }
  / rhs:(PairElem / ArrayLiteral / Expr){
    return rhs;
  }

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
  = (ArrayType / PairType / BaseType)

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
  = lhs:ExprType rhs:ExprTail?{
    if (rhs != '')
    {
      return new Helpers.constructBinary(Nodes, rhs.op, {lhs: lhs, rhs: rhs.exp});
    }
    return lhs;
  }

ExprTail
  = (Ws* op:BinOp Ws* exp:Expr){
    return {op: op, exp: exp};
  }

// TODO - Form correct precedence
ExprType
  = '(' Ws* e:Expr Ws* ')'{
    return e;
  }
  / e:(ArrayElem / PairElem / CharLiteral / StrLiteral / 
        PairLiteral / IntLiteral / BoolLiteral){
    return e;
  }
  / op:UnaryOp Ws* value:Expr{
    return Helpers.constructUnary(Nodes, op, {rhs: value});
  }
  / e:Ident { return e; }


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
    return {base: t, depth: bs.length};
  }

/*
   Defines elements within wacc arrays.
*/
ArrayElem
  = i:Ident accessors:ArrayAccessor+{
    return new Nodes.ArrayLookup({ident: i, index:accessors});
  }

ArrayAccessor
  = '[' Ws* e:Expr Ws* ']'{ return e; }

///////////////////////////////////////////////////////////////////////////////
// Pairs
///////////////////////////////////////////////////////////////////////////////

/*
   Defines the declaration behaviour for use of typed pairs.
*/
PairType
  = 'pair' '(' Ws* t1:PairElemType Ws* ',' Ws* t2:PairElemType Ws* ')'{
    return [t1,t2];
  }

/*
   Defines what is possible for an element of a pair.
*/
PairElem
  = a:PairAccessor Ws+ e:Expr{
    return new {fst: Nodes.FstOp, snd: Nodes.SndOp}[a](e);
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
  = i:Label { return new Nodes.Ident({label: i}); }
Label
  = a:[_a-zA-Z] b:[_a-zA-Z0-9]* { return [a].concat(b); }

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
  if ((a > (Math.pow(2, 31) - 1)) || (a < -Math.pow(2,31)))
  {
    e = new SyntaxError('Integer between ±2^31', a);
    pos = computeErrorPosition();
    e.line = pos.line; e.column = pos.column;
    e.name = 'SyntaxError';
    throw e;
  }
  else return new Nodes.IntLiteral({value: a});
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
    return new Nodes.BoolLiteral({value: bool == 'true'});
  }

/*
   Describes the literal representation of a character, specifically
   that it is a character surrounded by single quotes.
*/
CharLiteral
  = c:("#"/ "'" (Character/[#]) "'"){
    return new Nodes.CharLiteral({value: c});
  }

/*
   Very much similar to the character pattern but with double quotations
   and zero or more characters in length.
*/
StrLiteral
  = '"' chars:Character* '"'{
    return new Nodes.StringLiteral({value: chars.join('')});
  }

/*
   Defines the options for a character. Includes the possibility of
   escaping characters with a backslash.
*/
Character
  = [^\\\'\"]
  / EscapedChar

/*
   Defines the array literal notation. Zero or more elements demarkated
   by commas and represented by an expression token.
*/
ArrayLiteral
  = '[' Ws* elems:ArrayLiteralList? Ws* ']'{
    return new Nodes.ArrayLiteral({value: elems});
  }

ArrayLiteralList
  = e:Expr es:ArrayLiteralListTail?{
    return [e].concat(es);
  }

ArrayLiteralListTail
  = Ws* ',' Ws* e:Expr es:ArrayLiteralListTail?{
    if (es = '') return [e];
    return [e].concat(es);
  }

/*
   Pairs are actually pointers, and so the literal representation is
   the null value. New pairs are created via the `newpair` call.
*/
PairLiteral
  = 'null'{ return new Nodes.PairLiteral({value: 'null'}); }

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
  = '\\' c:[0btnfr"'\\] { return '\\' + c; }

/*
   Defines the different characters that may represent whitespace.
*/
Ws
  = [ \t\r\n]


