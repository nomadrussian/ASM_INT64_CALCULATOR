; main.asm - 08.04.2024


extern calculate
extern readstr
extern prtstr
extern linelen
extern write_digits
extern calculate_unsigned_decimal_length


global _start

extern errmsg_0division
extern errmsg_0d_len


section .data
errmsg_wrong_expression db "FATAL ERROR: WRONG EXPRESSION FORMAT, COULDN'T READ THE ", \
"EXPRESSION", 10, "PLEASE TRY AGAIN, IT ACCEPTS TWO(!) 64-bit ", \
"WHOLE OPERANDS AND", 10, "'+', '-', '/'(':'), NATURAL '^' OPERATIONS!!!!!!!!!!!", \
10, 0
errmsg_we_len equ $-errmsg_wrong_expression


section .bss
exp_buff resb 255
operand1 resq 1
operand2 resq 1
operation resq 1


section .text
_start:
        push exp_buff
        call readstr
        call check_exp_format
        add rsp, 8
        test rax, rax           ; 0 means wrong format
        jz near _start

        push rax
        push qword operation
        push qword operand2
        push qword operand1
        push qword exp_buff
        call parse_exp
        add rsp, 40

        push qword operation
        push qword operand2
        push qword operand1
        call calculate
        add rsp, 24
        cmp rcx, -1
        jz near _start

        push exp_buff
        push rdx
        push rax
        call write_result
        add rsp, 24

        push exp_buff
        call linelen
        add rsp, 8
        inc rax

        push rax
        push exp_buff
        call prtstr
        add rsp, 16

        jmp near _start

; converting the result to a string
; arg1: number
; arg2: additional result info (used only if division, otherwise 0)
; arg3: destination buffer address
write_result:
        push rbp
        mov rbp, rsp
        push rbx
        push rdi
        push r10

        mov rax, [rbp+16]
        xor rcx, rcx
        xor rdx, rdx
        mov rdi, [rbp+32]
        mov r10, 10             ; for ten
        test rax, rax
        jns near .calculate_length
        mov byte [rdi], "-"
        inc rdi
        neg rax

.calculate_length:
        push rdx
        push rcx
        push rax
        call calculate_unsigned_decimal_length
        add rsp, 8
        pop rcx
        pop rdx

        mov rcx, rax
        cmp rcx, 0
        jnz near .skip_zero_adjustment
        inc rcx

.skip_zero_adjustment:
        mov rax, [rbp+16]
        test rax, rax
        jns near .write_digits
        neg rax

.write_digits:
        push rdx
        push rcx
        push rdi
        push rax
        call write_digits
        add rsp, 16
        pop rcx
        pop rdx
        jmp near .check_remainder

.check_remainder:
        add rdi, rcx
        mov rax, [rbp+24]       ; division remainder check
        test rax, rax
        jz near .q
        mov byte [rdi], " "
        inc rdi
        mov byte [rdi], "("
        inc rdi

        test rax, rax
        jns near .calculate_remainder_length
        neg rax
        mov byte [rdi], "-"
        inc rdi

.calculate_remainder_length:
        push rax
        call calculate_unsigned_decimal_length
        mov rcx, rax
        pop rax

        push rcx
        push rdi
        push rax
        call write_digits
        pop rax
        pop rdi
        pop rcx
 
        add rdi, rcx
        mov byte [rdi], ")"
        inc rdi
        xor rcx, rcx
.q:
        mov byte [rdi], 10
    
        pop r10
        pop rdi
        pop rbx
        mov rsp, rbp
        pop rbp
        ret 


; parsing the expression
; arg1: buffer address
; arg2: operand1 address
; arg3: operand2 address
; arg4: operation address
; arg5: operation and signs info
parse_exp:
        push rbp
        mov rbp, rsp
        push rsi
        push rdi
        push rbx
        push r15                ; for arg4
        push r8                 ; for operation and end byte indices
        push r9                 ; for sign
        push r10                ; for 10
        mov r10, 10

        mov r15, [rbp+48]       ; signs and operation info
        mov r8, r15
        and r8, 0xff            ; get operation id
        mov rdi, [rbp+40]
        mov [rdi], r8           ; save it in memory
        mov r8, r15
        and r8, 0xff0000        ; now get its position
        shr r8, 16

        mov rsi, [rbp+16]
        xor r9, r9
        xor rcx, rcx
        xor rax, rax
        xor rdx, rdx

        test r15, 0x200
        jz .skipminus1flag
        inc r9
.skipminus1flag: 

        add rcx, r9
.parsedigit1:
        mul r10
        mov bl, [rsi+rcx]
        sub bl, "0"
        add al, bl
        inc rcx
        cmp rcx, r8
        jz .finishoperand1
        jmp .parsedigit1
.finishoperand1:
        test r9, r9
        jz .skipnegating1
        neg rax
.skipnegating1:
        mov rdi, [rbp+24]
        mov [rdi], rax

        inc rcx
        push rcx
        push rsi
        call linelen
        add rsp, 8
        pop rcx
        mov r8, rax

        xor rdx, rdx            ; now proceeding operand2
        xor rax, rax
        xor r9, r9

        test r15, 0x100
        jz .skipminus2flag
        inc r9
.skipminus2flag:

        add rcx, r9
.parsedigit2:
        mul r10
        mov bl, [rsi+rcx]
        sub bl, "0"
        add al, bl
        inc rcx
        cmp rcx, r8
        jz .finishoperand2
        jmp .parsedigit2
.finishoperand2:
        test r9, r9
        jz .skipnegating2
        neg rax
.skipnegating2:
        mov rdi, [rbp+32]
        mov [rdi], rax

        pop r10
        pop r9
        pop r8
        pop r15
        pop rbx
        pop rdi
        pop rsi
        mov rsp, rbp
        pop rbp
        ret


; checking if the expression format is valid
; arg1: buffer address
; return: ah contains information about signs: 11b=first/secondb
;         al contains the operation ID
;         rax>>16 contains the operation byte position ID
check_exp_format:
        push rbp
        mov rbp, rsp
        push rsi
        push rbx

        xor ax, ax
        xor rbx, rbx
        xor rcx, rcx

        mov rsi, [rbp+16]
        mov bl, [rsi]          ; loading the first byte
        cmp bl, "q"
        jz near .q_exit
        cmp bl, "Q"
        jz near .q_exit
        cmp bl, "-"
        jz .setminus1flag
        cmp bl, "0"
        jl near .q_err
        cmp bl, "9"
        jg near .q_err
        jmp .skipminus1flag
.setminus1flag:
        inc ah
.skipminus1flag:
        
        mov cl, ah              ; operand1 sign shift
        mov bl, [rsi+rcx]
        cmp bl, "0"             ; it has to start with a digit
        jl near .q_err
        cmp bl, "9"
        jg near .q_err
.seekforoperation:
        inc cl
        sub cl, ah
        cmp cl, 20              ; max 64bit operand consists of 19 digits + '-' sign
        jz .q_err
        add cl, ah
        mov bl, [rsi+rcx]
        cmp bl, "+"
        jz near .closefound
        cmp bl, "-"
        jz near .foundsub
        cmp bl, "*"
        jz near .foundmul
        cmp bl, ":"
        jz near .founddiv
        cmp bl, "/"
        jz near .founddiv
        cmp bl, "^"
        jz near .foundpow
        cmp bl, "0"
        jl near .q_err
        cmp bl, "9"
        jg near .q_err
        jmp .seekforoperation

.foundsub:
        inc al
        jmp near .closefound
.foundmul:
        add al, 2
        jmp near .closefound
.founddiv:
        add al, 3
        jmp near .closefound
.foundpow:
        add al, 4
.closefound:
        shl rcx, 16
        or rax, rcx
        shr rcx, 16

        shl ah, 1
        inc cl
        add rsi, rcx
        xor cl, cl
        mov bl, [rsi]           ; now checking the first byte of operand2
        cmp bl, "-"
        jz .setminus2flag
        cmp bl, "0"
        jl near .q_err
        cmp bl, "9"
        jg near .q_err
        jmp .skipminus2flag
.setminus2flag:
        cmp al, 4              ; check if power operation
        jz .q_err              ; it must have positive exponent
        inc ah
        inc rsi
.skipminus2flag:        
                                       
        mov bl, [rsi+rcx]       ; now proceeding operand2
        cmp bl, "0"             ; but we need at least one digit
        jl .q_err
        cmp bl, "9"
        jg .q_err
.seekfortheend:
        inc cl
        cmp cl, 20              ; 20 because we also need to find \0 or \n
        jz .q_err
        mov bl, [rsi+rcx]
        test bl, bl
        jz .q
        cmp bl, 10
        jz .q
        cmp bl, "0"
        jl .q_err
        cmp bl, "9"
        jg .q_err
        jmp .seekfortheend

.q_err:
        push qword errmsg_we_len
        push qword errmsg_wrong_expression
        call prtstr
        add rsp, 16
        xor rax, rax
.q: 
        pop rbx
        pop rsi
        mov rsp, rbp
        pop rbp
        ret
.q_exit:
        push qword 0
        call _exit


; exiting program
; arg1: return code
_exit:
        mov rax, 60
        mov rdi, [rsp+8]
        syscall
