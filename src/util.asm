; util.asm - 12.06.2025
;
; ----------------
; | Useful utils |
; ----------------
;
; This file contains the following subroutines:
;   
;   readstr -> reads a string from stdin up to 255 characters
;   prtstr -> prints out a string to stdout
;   linelen -> calculates the length of a line
;   write_digits -> writes digits of a number to RAM
;   calc_unsigned_dec_len -> returns length of an unsigned number in digits
;


global readstr
global prtstr
global linelen
global write_digits
global calc_unsigned_dec_len


section .text
; reading from standart input sream
; arg1: buffer address
readstr:
        push rbp
        mov rbp, rsp
        push rdi
        push rsi

        mov rax, 0                  ; read syscall index
        mov rdi, 0                  ; stdin file descriptor
        mov rsi, [rbp+16]           ; loading buffer address from arg1
        mov rdx, 255                ; max length
        syscall

        pop rsi
        pop rdi
        mov rsp, rbp
        pop rbp
        ret
; ----------------------------------


; printing out into standart output stream
; arg1: buffer address
; arg2: buffer length
prtstr:
        push rbp
        mov rbp, rsp
        push rdi
        push rsi

        mov rax, 1                  ; write syscall index
        mov rdi, 1                  ; stdout file descriptor
        mov rsi, [rbp+16]           ; loading buffer address from arg1
        mov rdx, [rbp+24]           ; loading buffer length from arg2
        syscall

        pop rsi
        pop rdi
        mov rsp, rbp
        pop rbp
        ret
; ----------------------------------


; calculating string length
; arg1: buffer address
; returns line length without terminating symbols in rax
linelen:
        push rbp
        mov rbp, rsp
        push rsi
        
        mov rsi, [rbp+16]           ; loading buffer length from arg1
        xor rax, rax                ; result length is accumulated here
.lp:
        cmp byte [rsi], 0           ; check for '\0' end of string
        jz .q
        cmp byte [rsi], 10          ; check for '\n' end of line
        jz .q
        inc rax                     ; length++
        inc rsi                     ; next byte of the buffer
        jmp .lp
.q:
        pop rsi
        mov rsp, rbp
        pop rbp
        ret
; ----------------------------------


; writes digits into memory
; arg1: number
; arg2: buffer address
; arg3: length
write_digits:
        push rbp
        mov rbp, rsp
        push rdi
        push r10

        mov rax, [rbp+16]           ; load number to rax
        mov rdi, [rbp+24]           ; load buffer address to rdi
        mov rcx, [rbp+32]           ; load length to rcx
        mov r10, 10                 ; for 10

.write_digit:
        xor rdx, rdx                ; clear rdx for division
        div r10                     ; divide by 10
        add dl, 48                  ; remainder digit -> it's ascii code
        mov byte [rdi+rcx-1], dl    ; write it to RAM
        loop .write_digit           ; reiterate while rcx > 0

        pop r10
        pop rdi
        mov rsp, rbp
        pop rbp
        ret
; ----------------------------------


; calculate decimal length of an unsigned number
; arg1: number
; returns length in rax
calc_unsigned_dec_len:
        push rbp
        mov rbp, rsp
        push r10

        xor rcx, rcx                ; accumulated length
        mov rax, [rbp+16]           ; load the number from arg1
        mov r10, 10                 ; for 10

.calculate:
        test rax, rax               ; check if number = 0
        jz near .q
        inc rcx                     ; length++
        xor rdx, rdx                ; clear rdx for division
        div r10                     ; next digit
        jmp near .calculate         ; iterate while number != 0

.q:
        mov rax, rcx                ; return the result
        pop r10
        mov rsp, rbp
        pop rbp
        ret
; ----------------------------------

