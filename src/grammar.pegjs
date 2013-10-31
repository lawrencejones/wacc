///////////////////////////////////////////////////////////////////////////////
// WACC Compiler Group 27
// ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
// Author: lmj112
// File: grammer.pegjs
// Desc: pegjs file that describes the syntax for the WACC language.
///////////////////////////////////////////////////////////////////////////////

/* Dummy target for production of final parsed script*/
main
  = program:Program

///////////////////////////////////////////////////////////////////////////////
// Lexical Grammer
///////////////////////////////////////////////////////////////////////////////

/*
   Match for a program, defined as a block of code, scoped by the terminals
   `begin` and `end` which contain a final statement to be returned and
   zero or more functions.
*/
Program
  = Comment* Body? Ws* (Ws+ Comment*)?

Body
  = ('begin' Ws+ (Function/Comment)* Statement Ws* 'end')

///////////////////////////////////////////////////////////////////////////////
// Functions and Parameters
///////////////////////////////////////////////////////////////////////////////

/*
   A function is defined by the return type, the function name, a parameter
   list surrounded by parentheses, followed by the terminals `is` and `end`
   which encapsulate statements.
*/
Function
  = Type Ws+ Ident Ws* TypeSignature Ws* 'is' Ws+ Statement Ws+ 'end' Ws*

TypeSignature
  = '(' Ws* ParamList? Ws* ')'

/*
   Defines a list of parameter declarations with their respective types for
   defining a function type signature.
*/
ParamList
  = Param (',' Ws* Param)*

/*
   Defines a single parameter token.
*/
Param
  = Type Ws+ Ident

///////////////////////////////////////////////////////////////////////////////
// WACC Statements
///////////////////////////////////////////////////////////////////////////////

/*
   The various different forms that a statement can take in the wacc
   specification. This is broken into types, tail and an overall statement
   type to avoid left recursive issues.
*/
Statement
  = StatementType StatementTail?

StatementType
  = 'skip'
  / 'println' Ws+ Expr
  / 'read' Ws+ AssignLhs
  / 'free' Ws+ Expr
  / 'return' Ws+ Expr
  / 'exit' Ws+ Expr
  / 'print' Ws+ Expr
  / 'if' Ws+ Expr Ws* 'then' Ws+ Statement Ws* 'else' Ws+ Statement Ws* 'fi'
  / 'while' Ws+ Expr Ws* 'do' Ws+ Statement Ws* 'done'
  / 'begin' Ws+ Statement Ws+ 'end'
  / ArrayType Ws+ Ident Ws* '=' Ws* ArrayLiteral
  / Param Ws* '=' Ws* AssignRhs
  / AssignLhs Ws* '=' Ws* AssignRhs

StatementTail
  = Ws* ';' Comment* Ws* Statement
  / Ws* Statement

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
  = 'call' Ws+ Ident '(' Ws* ArgList? Ws* ')'
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
  = Expr (Ws* ',' Ws+ Expr)*

///////////////////////////////////////////////////////////////////////////////
// Operators
///////////////////////////////////////////////////////////////////////////////

/*
   Defines all unary operators.
*/
UnaryOp
  = '!'
  / '-'
  / 'len'
  / 'ord'
  / 'toInt'

/*
   Defines all binary operators.
*/
BinOp
  = '*'
  / '/'
  / '%'
  / '+'
  / '-'
  / '>='
  / '>'
  / '<='
  / '<'
  / '=='
  / '!='
  / '&&'
  / '||'

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
  = ExprType ExprTail?

ExprType
  = '(' Ws* Expr Ws* ')'
  / CharLiteral
  / StrLiteral
  / ArrayElem
  / PairLiteral
  / UnaryOp Ws* Expr
  / IntLiteral
  / BoolLiteral
  / Ident

ExprTail
  = Ws* BinOp Ws* Expr

///////////////////////////////////////////////////////////////////////////////
// Arrays
///////////////////////////////////////////////////////////////////////////////

/*
   Defines array type declarations. Matches to patterns like `int[]` for
   specifying the array content type.
   TODO - Clarify that array types are only of base type
*/
ArrayType
  = BaseType ('[' ']')+

/*
   Defines elements within wacc arrays.
*/
ArrayElem
  = Ident ('[' Ws* Expr Ws* ']')+

///////////////////////////////////////////////////////////////////////////////
// Pairs
///////////////////////////////////////////////////////////////////////////////

/*
   Defines the declaration behaviour for use of typed pairs.
*/
PairType
  = 'pair' '(' Ws* PairElemType Ws* ',' Ws* PairElemType Ws* ')'

/*
   Defines what is possible for an element of a pair.
   TODO - lookup exact usage.
*/
PairElem
  = PairAccessor Ws+ Expr

PairAccessor
  = 'fst'
  / 'snd'

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
  = [_a-zA-Z] [_a-zA-Z0-9]*

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
  = IntSign? Digit+

/*
   Defines the integer signage for positive or negative notation.
*/
IntSign
  = '+'
  / '-'

/*
   Defines the true and false string representation of the boolean
   literal token.
*/
BoolLiteral
  = 'true'
  / 'false'

/*
   Describes the literal representation of a character, specifically
   that it is a character surrounded by single quotes.
*/
CharLiteral
  = "#"
  / "'" (Character/[#])  "'"

/*
   Very much similar to the character pattern but with double quotations
   and zero or more characters in length.
*/
StrLiteral
  = '"' Character* '"'

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
  = '[' Ws* (Expr ( Ws* ',' Ws* Expr)*)* Ws* ']'

/*
   Pairs are actually pointers, and so the literal representation is
   the null value. New pairs are created via the `newpair` call.
*/
PairLiteral
  = 'null'

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
  = '0'
  / 'b'
  / 't'
  / 'n'
  / 'f'
  / 'r'
  / '"'
  / "'"
  / '\\'

/*
   Defines the different characters that may represent whitespace.
*/
Ws
  = [ \t\r\n]


