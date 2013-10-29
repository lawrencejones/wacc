///////////////////////////////////////////////////////////////////////////////
// WACC Compiler Group 27
// ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
// Author: lmj112
// File: grammer.pegjs
// Desc: pegjs file that describes the syntax for the WACC language.
///////////////////////////////////////////////////////////////////////////////

/* Require the wacc node descriptions */
WACC = require './nodes'

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
  = 'begin' Function* Statement 'end'


///////////////////////////////////////////////////////////////////////////////
// Functions and Parameters
///////////////////////////////////////////////////////////////////////////////

/*
   A function is defined by the return type, the function name, a parameter
   list surrounded by parentheses, followed by the terminals `is` and `end`
   which encapsulate statements.
*/
Function
  = Type Ident '(' ParamList? ')' 'is' Statement 'end'

/*
   Defines a list of parameter declarations with their respective types for
   defining a function type signature.
*/
ParamList
  = Param (',' Param)*

/*
   Defines a single parameter token.
*/
Param
  = Type Ident

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
  / Type Ident '=' AssignRhs
  / AssignLhs '=' AssignRhs
  / 'read' AssignLhs
  / 'free' Expr
  / 'return' Expr
  / 'exit' Expr
  / 'print' Expr
  / 'println' Expr
  / 'if' Expr 'then' Statement 'else' Statement 'fi'
  / 'while' Expr 'do' Statement 'done'
  / 'begin' Statement 'end'

StatementTail
  = ';' StatementTail

///////////////////////////////////////////////////////////////////////////////
// Assignment
///////////////////////////////////////////////////////////////////////////////

/*
   Assign Left Hand Side. Defines the possible elements to appear on the
   left of the assignment operator.
*/
AssignLhs
  = Ident
  / ArrayElem
  / PairElem

/*
   Assign Right Hand Side. Defines what is allowed to appear on the right
   of an assignment operator.
*/
AssignRhs
  = Expr
  / ArrayLiteral
  / 'newpair' '(' Expr ',' Expr ')'
  / PairElem
  / 'call' Ident '(' ArgList? ')'

///////////////////////////////////////////////////////////////////////////////
// Function Invokation
///////////////////////////////////////////////////////////////////////////////

/*
   Defines a list of arguments to be fed to a function call. Similar to
   a parameter list but without the type declaration.
*/
ArgList
  = Expr (',' Expr)*

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
  / '>'
  / '>='
  / '<'
  / '<='
  / '=='
  / '!-'
  / '&&'
  / '||'

///////////////////////////////////////////////////////////////////////////////
// Types and Expressions
///////////////////////////////////////////////////////////////////////////////

/*
   Selection of available types within the wacc static typing system.
*/
Type
  = BaseType
  / ArrayType
  / PairType

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
  = IntLiteral
  / BoolLiteral
  / CharLiteral
  / StrLiteral
  / PairLiteral
  / Ident
  / ArrayElem
  / UnaryOp Expr
  / '(' Expr ')'

ExprTail
  = BinOp Expr

///////////////////////////////////////////////////////////////////////////////
// Arrays
///////////////////////////////////////////////////////////////////////////////

/*
   Defines array type declarations. Matches to patterns like `int[]` for
   specifying the array content type.
   TODO - Clarify that array types are only of base type
*/
ArrayType
  = BaseType '[' ']'

/*
   Defines elements within wacc arrays.
*/
ArrayElem
  = Ident '[' Expr ']'

///////////////////////////////////////////////////////////////////////////////
// Pairs
///////////////////////////////////////////////////////////////////////////////

/*
   Defines the declaration behaviour for use of typed pairs.
*/
PairType
  = 'pair' '(' PairElemType ',' PairElemType ')'

/*
   Defines what is possible for an element of a pair.
   TODO - lookup exact usage.
*/
PairElem
  = 'fst' Expr
  / 'snd' Expr

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
  = "'" Character "'"

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
  = [^(\\\'\")]
  / '\\' EscapedChar

/*
   Defines the array literal notation. Zero or more elements demarkated
   by commas and represented by an expression token.
*/
ArrayLiteral
  = '[' (Expr (',' Expr)*)* ']'

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
  = '#' [^(EOL)] 'EOL'

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

