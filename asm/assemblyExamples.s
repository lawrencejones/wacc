###############################################################################
# WACC Compiler Group 27
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
# Author: lmj112 amv12 skd212 ot612
# File: assemblyExamples.s
# Desc: assembly for different nodes
#       
###############################################################################


#----------------------------------GENERAL ASSEMBLY---------------------------------------

##########################################################################################
##########################################################################################


#main: 
#1.	 PUSH {lr}          --- always


#2.	 SUB sp, sp, #<number of bytes used by program variable declarations>  (no.)
#	                    --- unless there are no declarations
#                        (use symbol table)


#---------------------------------------

#3.   MOV/LDR  r0, #/=<first declared value>
#4.   STR  r0, [sp, #<no. - number of bytes the value takes>]

#---------------------------------------
#steps 3 + 4 repeated in order down the statements filling up the stack 
#with all of the declared variables in the program body, not including anything
#inside a function body.


#FUNCTION CALLS IN MAIN:


#f_anyFunctions:

#1.	           PUSH {lr}              ---always
               
#2...           (stuff in function body)

#last -1.       POP {PC}               ---always

#last.          POP {PC}               ---always    


#---------------------------------------

#1.   LDR r0, #<firstarg>    
#2.   STR r0, #[sp, #-<bytes that arg takes>]

#---------------------------------------
#repeat until all the args for the function are on the stack

#then.    BL f_<functionName>

#then..   ADD sp, sp #<total bytes for function args>

#then..   Assign return value to r0

############################################################################################
############################################################################################




#  16 GENERAL PURPOSE REGISTERS: r0 - r15
#  r13 = SP
#  r14 = LR
#  r15 = PC

#------------------------BasicVariables--------------------------------------

type = MOV r0, {value}
       STR r0, [sp, {combinedProgramVariableSize - sizeof(value)}]


# the types are: int, char, bool

string = SUB sp, sp, 4   #always 4 because it is a pointer
         LDR r0, msg_0
         STR r0, [sp]

 msg_0: .word {stringLength}
        .ascii {value}


#---------------------------Arrays------------------------------------------



array = SUB sp, sp, 4       #always 4 because its a pointer
        SUB sp, sp, {(arrayLength * sizeof(type))  + 4}  #array length stored at top of stack

        #
        LDR r0, {firstValue}
        STR r0, [sp, {sizeof(type)}]     #repeat these 2 steps for all of array elems
        #

        LDR r0, arrayLength
        STR r0, [sp]
        LDR sp, r0
        STR r0, [sp, {(arrayLength * sizeof(type))  + 4}]



#---------------------------Conditions---------------------------------------

conditional = CMP r0, 0     #see if the condidtion is false (0)
             BEQ L0        #jump to L0 if condition is false
             {ifBody}
             B L1          #jumps unconditionally over else body
         L0: {elseBody}
         L1:               #end of if statement
      

whileLoop = 





#--------------------------UnaryOps------------------------------------------


#after evaluating the operand and storing the int in r0:
NegOp =  RSBS r0, r0, 0
         BLVS p_throw_overflow_error 

#put the int to be converted in r0 and then call this function, the result will
#be put at the top of the stack
#bring it off the stack into r0 by "LDRSB r0, [sp]"
OrdOp = STRB r0, [sp] 


#arrays look weird, not quite sure whats going on there
LenOP = 

#loads the int value from the char in the stack at the certain displacement
ToIntOp = LDRSB r0, [sp, {stackDisplacementFromChar}]

#when the bool is stored in r0, this stores the 'notted' bool in r0
NotOp = EOR r0, r0, 1



#TODO: ----------------------------PAIROPS----------------------------------


#where left is stored in r0 and right is stored in r1
#result in r0
MulOp = SMULL r0, r1, r0, r1
        CMP r1, r0, ASR 31
        BLNE p_throw_overflow_error    


#where left is stored in r0 and right is stored in r1
#result in r0
AddOp = ADDS r0, r0, r1
        BLVS p_throw_overflow_error


#where left is stored in r0 and right is stored in r1
#result in r0
SubOp = SUBS r0, r0, r1
        BLVS p_throw_overflow_error


#divisor in r0, dividend in r1
DivOp = BL p_check_divide_by_zero
        BL __aeabi_idiv 


#same format as divide
ModOP = BL p_check_divide_by_zero
        BL __aeabi_idivmod    





#-------------------------FOR ALL COMPARISONS-------------------------------

#first arg in r0, second in r1. last line stores the result on the stack
#which is usually done for everything that is declared

LessOp = CMP r0, r1
         MOVLT r0, 1
         MOVGE r0, 0
         STRB r0, [sp]            


LessEqOp = CMP r0, r1
           MOVLE r0, 1
           MOVGT r0, 0
           STRB r0, [sp]  


GreaterOp = CMP r0, r1
            MOVGT r0, 1
            MOVLE r0, 0
            STRB r0, [sp]  

GreaterEqOp = CMP r0, r1
              MOVGE r0, 1
              MOVLT r0, 0
              STRB r0, [sp]  



#------------------------FOR LOGIC OPS------------------------


#the value 0 is compared to the first operand, stored in r0 is stored in r0,
#if this is false then the overall answer is false, otherwise the answer is
#the second operand.

AndOp =    CMP r0, 0               #first operand in r0
           BEQ L0
           LDRSB r0, [sp, 1]       #second operand stored in [sp, #{1}]
        L0:
           STRB r0, [sp]
           ADD sp, sp, {totalProgramBytes}
           MOV r0, 0
           POP {pc}     



#First operand compared against true (1), if this is equal then the answer
#is true, otherwise the answer is the second operand.
OrOp =    CMP r0, 1             #first operand in r0
          BEQ L0
          LDRSB r0, [sp, 1]     #second operand stored in [sp, #{1}]
       L0:
          STRB r0, [sp]
          ADD sp, sp, 3
          MOV r0, 0
          POP {pc}       


#same code if the operands are ints or bools, as long as the operands are
#stored in r0 and r1, again the last line just pushes the result onto the 
#stack which is what would normally happen if more statements were to 
#follow on
EqOp =   CMP r0, r1
         MOVEQ r0, 1
         MOVNE r0, 0
         STRB r0, [sp]



#pretty much identical to EqOp
NotEqOp =  CMP r0, r1
           MOVNE r0, 1
           MOVEQ r0, 0
           STRB r0, [sp]



#------------------------------Statements----------------------------------


#skip literally assembles to nothing at all
skip = ''



#could be any expression, but eventually boils down to a base type which
#is stored in r0 through either mov or ldr, example of each shown
Return =  MOV r0, 1  |  LDR r0, =1


#TODO: bit confusing
#Read =       


#first loads the expression passed to Exit into r0, in this case its 5, 
#then calls BL exit
Exit =  LDR r0, =5
           BL exit     


Print =          LDR r0, =5
                 BL p_print_int
                 MOV r0, #{0}
                 POP {pc}
    p_print_int:
                 PUSH {lr}
                 MOV r1, r0
                 LDR r0, =msg_0
                 ADD r0, r0, #{4}
                 BL printf
                 MOV r0, #{0}
                 BL fflush
                 POP {pc}      

