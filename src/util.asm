; util.asm - 08.04.2024


global readstr
global prtstr
global linelen
global write_digits
global calculate_unsigned_decimal_length


section .text
; reading from standart input sream
; arg1: buffer address
readstr:
        push rbp
        mov rbp, rsp
        push rdi
        push rsi

        mov rax, 0
        mov rdi, 0
        mov rsi, [rbp+16]
        mov rdx, 255
        syscall

        pop rsi
        pop rdi
        mov rsp, rbp
        pop rbp
        ret


; printing out into standart output stream
; arg1: buffer address
; arg2: string length
prtstr:
        push rbp
        mov rbp, rsp
        push rdi
        push rsi

        mov rax, 1
        mov rdi, 1
        mov rsi, [rbp+16]
        mov rdx, [rbp+24]
        syscall

        pop rsi
        pop rdi
        mov rsp, rbp
        pop rbp
        ret


; calculating string length
; arg1: buffer address
; returns line length without terminating symbols in rax
linelen:
        push rbp
        mov rbp, rsp
        push rsi
        
        mov rsi, [rbp+16]
        xor rax, rax
.lp:
        cmp byte [rsi], 0
        jz .q
        cmp byte [rsi], 10
        jz .q
        inc rax
        inc rsi
        jmp .lp
.q:
        pop rsi
        mov rsp, rbp
        pop rbp
        ret


; writes digits into memory
; arg1: number
; arg2: buffer address
; arg3: length
write_digits:
        push rbp
        mov rbp, rsp
        push rdi

        mov rax, [rbp+16]
        mov rdi, [rbp+24]
        mov rcx, [rbp+32]

.write_digit:
        xor rdx, rdx
        div r10
        add dl, 48
        mov byte [rdi+rcx-1], dl
        loop .write_digit

        pop rdi
        mov rsp, rbp
        pop rbp
        ret


; calculate decimal length of an unsigned number
; arg1: number
; returns length in rax
calculate_unsigned_decimal_length:
        push rbp
        mov rbp, rsp

        xor rcx, rcx
        mov rax, [rbp+16] 

.calculate:
        test rax, rax
        jz near .q
        inc rcx
        xor rdx, rdx
        div r10
        jmp near .calculate

.q:
        mov rax, rcx
        mov rsp, rbp
        pop rbp
        ret
