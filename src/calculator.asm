; calculate.asm - 08.04.2024


global calculate


extern prtstr


global errmsg_0division
global errmsg_0d_len


section .data
errmsg_0division db "FATAL ERROR: DIVISION BY ZERO IS STRICTLY FORBIDDEN!!!!!!!!", \
10, 0
errmsg_0d_len equ $-errmsg_0division


section .text
; calculating the expression
; arg1: operand1
; arg2: operand2
; arg3: operation ID
; returns the result in rax and, if division, also rdx
; division by 0 is -1 in rcx
calculate:
        push rbp
        mov rbp, rsp
        push r8
        push r9
        push r10

        xor rax, rax
        xor rdx, rdx
        mov r8, [rbp+32]        ; operation
        mov r9, [rbp+16]        ; arg1
        mov r10, [rbp+24]       ; arg2

        mov r8, [r8]
        test r8, r8
        jz .add
        cmp qword r8, 1
        jz .sub
        cmp qword r8, 2
        jz .mul
        cmp qword r8, 3
        jz .div
        cmp qword r8, 4
        jz .pow
.add:
        mov rax, [r9]
        add rax, [r10]
        jmp near .q
.sub:
        mov rax, [r9]
        sub rax, [r10]
        jmp near .q
.mul:
        mov rax, [r9]
        imul qword [r10]
        jmp near .q
.div:
        mov rcx, [r10]
        test rcx, rcx
        jz near .q_err_0div
        mov rax, [r9]
        cqo
        idiv qword [r10]
        jmp near .q
.pow:
        mov rax, 1
        mov rcx, [r10]
.pow_loop:
        test rcx, rcx
        jz near .q
        imul qword [r9]
        dec rcx
        jmp near .pow_loop
.q:
        cmp r8, 3
        jz near .qq
        xor rdx, rdx
        jmp near .qq
.q_err_0div:
        push qword errmsg_0d_len
        push qword errmsg_0division
        call prtstr
        add rsp, 16
        xor rax, rax
        mov rcx, -1
.qq:
        pop r10
        pop r9
        pop r8
        mov rsp, rbp
        pop rbp
        ret
