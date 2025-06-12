; main.asm - 12.06.2025
;
; -----------------------------------------------
; | The main module of the INT64 CLI Calculator |
; -----------------------------------------------
;


; extern .data
extern errmsg_0division
extern errmsg_0d_len
extern errmsg_wrong_expression 
extern errmsg_we_len 

; extern .text
extern calculate
extern readstr
extern prtstr
extern linelen
extern write_digits
extern calc_unsigned_dec_len


section .bss
exp_buff resb 255
operand1 resq 1
operand2 resq 1
operation resq 1


; ---------------
; | ENTRY POINT |
; ---------------
global _start
section .text
_start:
        ; step 1: check if the expression matches the correct format
        push exp_buff
        call readstr
        call check_exp_format
        add rsp, 8
        test rax, rax               ; 0 means wrong format
        jz short _start             ; if wrong format, try again

        ; step 2: parsing the expression
        push rax
        push qword operation
        push qword operand2
        push qword operand1
        push qword exp_buff
        call parse_exp
        add rsp, 40

        ; step 3: calculating
        push qword operation
        push qword operand2
        push qword operand1
        call calculate
        add rsp, 24
        cmp rcx, -1
        jz near _start

        ; step 4: saving the result to RAM
        push exp_buff
        push rdx
        push rax
        call write_result
        add rsp, 24

        ; step 5: calculating the total length or the result
        ; after converting it into a string
        push exp_buff
        call linelen
        add rsp, 8
        inc rax

        ; step 6: printing out the result
        push rax
        push exp_buff
        call prtstr                 ; print the result
        add rsp, 16

        jmp near _start             ; next expression
; ----------------------------------


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

        mov rax, [rbp+16]           ; load the result number
        xor rcx, rcx
        xor rdx, rdx
        mov rdi, [rbp+32]
        mov r10, 10                 ; for ten
        test rax, rax               ; check if the number is negative
        jns short .calculate_length
        mov byte [rdi], "-"         ; if it is, then start with '-'
        inc rdi
        neg rax                     ; and then treat is a positive
        ; btw that's why it's negative limit is -(2^63-1), not -2^63
.calculate_length:
        push rdx
        push rcx
        push rax
        call calc_unsigned_dec_len  ; get the number of digits to write
        add rsp, 8
        pop rcx
        pop rdx

        mov rcx, rax
        cmp rcx, 0                  ; if the length is zero, it still takes 1 byte
        jnz short .skip_zero_adjustment
        inc rcx

.skip_zero_adjustment:
        mov rax, [rbp+16]
        test rax, rax
        jns short .write_digits
        neg rax

.write_digits:
        push rdx
        push rcx
        push rdi
        push rax
        call write_digits           ; write the digits of the result to RAM as a string
        add rsp, 16
        pop rcx
        pop rdx

        ; now dealing with the remainder
        add rdi, rcx
        mov rax, [rbp+24]           ; division remainder check
        test rax, rax               ; if it's equal to 0, then print nothing else
        jz near .q
        mov byte [rdi], " "         ; else print it in round brackets after a space
        inc rdi
        mov byte [rdi], "("
        inc rdi

        test rax, rax               ; now check if the remainder is negative
        jns short .calc_rem_len
        neg rax                     ; if it is, then treat is as positive
        mov byte [rdi], "-"         ; but first write '-'
        inc rdi                     ; one character left (after '-')

.calc_rem_len:
        push rax
        call calc_unsigned_dec_len  ; get the remainder's length in digits
        mov rcx, rax
        pop rax

        push rcx
        push rdi
        push rax
        call write_digits           ; append the remainder digits
        pop rax
        pop rdi
        pop rcx
 
        add rdi, rcx
        mov byte [rdi], ")"         ; close the round bracket
        inc rdi
        xor rcx, rcx
.q:
        mov byte [rdi], 10          ; append '\n' (end of line)
    
        pop r10
        pop rdi
        pop rbx
        mov rsp, rbp
        pop rbp
        ret 
; ----------------------------------


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
        jmp short .parsedigit1
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
;-----------------------------------


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
        jmp short .closefound
.foundmul:
        add al, 2
        jmp short .closefound
.founddiv:
        add al, 3
        jmp short .closefound
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
        jz short .setminus2flag
        cmp bl, "0"
        jl near .q_err
        cmp bl, "9"
        jg near .q_err
        jmp short .skipminus2flag
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
        jl short .q_err
        cmp bl, "9"
        jg .q_err
        jmp short .seekfortheend

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
; ----------------------------------


; exiting program
; arg1: return code
_exit:
        mov rax, 60
        mov rdi, [rsp+8]
        syscall
; ----------------------------------

