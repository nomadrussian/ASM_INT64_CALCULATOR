; calculate.asm - 12.06.2025
;
; ----------------------------------------------------
; | The key subroutine for doing actual calculations |
; ----------------------------------------------------
;


global calculate


; extern .data
extern errmsg_0division
extern errmsg_0d_len

; extern .text
extern prtstr


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

        mov r8, [rbp+32]            ; operation
        mov r9, [rbp+16]            ; arg1
        mov r10, [rbp+24]           ; arg2

        mov r8, [r8]                ; load the operand
        test r8, r8                 ; if id == 0 -> +
        jz .add
        cmp qword r8, 1             ; if id == 1 -> -
        jz .sub
        cmp qword r8, 2             ; if id == 2 -> *
        jz .mul
        cmp qword r8, 3             ; if id == 3 -> /
        jz .div
        cmp qword r8, 4             ; if id = 4 -> ^ (natural)
        jz .pow
.add:
        mov rax, [r9]               ; loading the first term
        add rax, [r10]              ; add
        jmp near .q
.sub:
        mov rax, [r9]               ; loading the first term
        sub rax, [r10]              ; subtract
        jmp near .q
.mul:
        mov rax, [r9]               ; loading the first multiplier
        imul qword [r10]            ; multiply it by the second
        jmp near .q
.div:
        mov rcx, [r10]              ; loading the divisor from the memory
        test rcx, rcx               ; check if zero
        jz near .q_err_0div         ; division by zero is impossible
        mov rax, [r9]               ; loading the dividend
        cqo                         ; expanding rax to rdx:rax
        idiv rcx                    ; divide
        xor rcx, rcx                ; clearing rcx because no error
        jmp short .q
.pow:
        mov r9, [r9]                ; load the base of the power
        mov rax, 1                  ; the result
        mov rcx, [r10]              ; loading the power
.pow_loop:
        test rcx, rcx               ; check if power is 0
        jz short .q
        imul r9                     ; multiply the number one more time
        dec rcx                     ; power--
        jmp short .pow_loop
.q:
        cmp r8, 3                   ; check if the operation was *
        jz short .qq                ; skip div by zero handling
        xor rdx, rdx                ; if not, clear rdx
        jmp short .qq               ; skip div by zero handling
.q_err_0div:
        push qword errmsg_0d_len
        push qword errmsg_0division
        call prtstr                 ; print div by 0 error message
        xor rax, rax                ; clear the result reg
        mov rcx, -1                 ; return error code -1
.qq:
        pop r10
        pop r9
        pop r8
        mov rsp, rbp
        pop rbp
        ret
; ----------------------------------

