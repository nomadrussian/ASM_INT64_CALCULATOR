; err.asm
;
; --------------------------
; | Storing error messages |
; --------------------------
;


global errmsg_0division
global errmsg_0d_len
global errmsg_wrong_expression 
global errmsg_we_len 


section .data
errmsg_0division db "FATAL ERROR: DIVISION BY ZERO IS STRICTLY FORBIDDEN!!!!!!!!", \
10, 0
errmsg_0d_len equ $-errmsg_0division

errmsg_wrong_expression db "FATAL ERROR: WRONG EXPRESSION FORMAT, COULDN'T READ THE ", \
"EXPRESSION", 10, "PLEASE TRY AGAIN, IT ACCEPTS TWO(!) 64-bit ", \
"WHOLE OPERANDS AND", 10, "'+', '-', '/'(':'), NATURAL '^' OPERATIONS!!!!!!!!!!!", \
10, 0
errmsg_we_len equ $-errmsg_wrong_expression

