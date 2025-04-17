; Utilities Module
%ifndef UTILS_ASM
%define UTILS_ASM

; Print a BCD value as decimal
print_bcd:
    push ax
    
    shr al, 4
    add al, '0'
    call print_char
    
    pop ax
    push ax
    
    and al, 0x0F
    add al, '0'
    call print_char
    
    pop ax
    ret

;;; Utility Functions ;;;
; Print a byte in hexadecimal
print_hex_byte:
    push ax
    push cx
    
    mov ah, al             ; Save byte in AH
    
    ; High nibble
    shr al, 4              ; Get high nibble
    cmp al, 10
    jb .high_digit
    add al, 'A' - 10 - '0' ; Convert to A-F
.high_digit:
    add al, '0'            ; Convert to ASCII
    call print_char
    
    ; Low nibble
    mov al, ah             ; Restore byte
    and al, 0x0F           ; Get low nibble
    cmp al, 10
    jb .low_digit
    add al, 'A' - 10 - '0' ; Convert to A-F
.low_digit:
    add al, '0'            ; Convert to ASCII
    call print_char
    
    pop cx
    pop ax
    ret

; Print decimal number in BX
print_decimal:
    push ax
    push bx
    push cx
    push dx
    
    mov ax, bx
    mov bx, 10
    mov cx, 0
    
    ; Handle zero case
    cmp ax, 0
    jne .not_zero
    
    mov al, '0'
    call print_char
    jmp .done
    
.not_zero:
    ; Convert number to digits
.convert_loop:
    cmp ax, 0
    je .print_digits
    
    xor dx, dx
    div bx          ; Divide AX by 10, quotient in AX, remainder in DX
    
    add dl, '0'     ; Convert remainder to ASCII
    push dx         ; Store digit on stack
    inc cx          ; Count digits
    jmp .convert_loop
    
.print_digits:
    ; Print digits in reverse order
    cmp cx, 0
    je .done
    
    pop ax
    call print_char
    dec cx
    jmp .print_digits
    
.done:
    pop dx
    pop cx
    pop bx
    pop ax
    ret

; Print a single character
print_char:
    push ax
    mov ah, 0x0E
    int 0x10
    pop ax
    ret

; Compare strings at SI and DI
; Sets carry flag if equal
strcmp:
    push si
    push di
.loop:
    lodsb                  ; Load byte from SI into AL
    mov bl, [di]           ; Load byte from DI into BL
    inc di                 ; Advance DI
    cmp al, bl
    jne .not_equal
    cmp al, 0              ; Check if end of string
    je .equal
    jmp .loop
.not_equal:
    clc                    ; Clear carry flag (not equal)
    jmp .done
.equal:
    stc                    ; Set carry flag (equal)
.done:
    pop di
    pop si
    ret

; Copy string from SI to DI
strcpy:
    push ax
    push si
    push di
.loop:
    lodsb
    stosb
    cmp al, 0
    jne .loop
    pop di
    pop si
    pop ax
    ret

; Print string at SI until zero terminator
print_string:
    mov ah, 0x0E
.print_char:
    lodsb
    cmp al, 0
    je .done
    int 0x10
    jmp .print_char
.done:
    ret

; Read line from keyboard into buffer
read_line:
    mov di, buffer
.read_char:
    mov ah, 0
    int 0x16              ; BIOS: read char
    cmp al, 0x0D          ; Enter?
    je .done
    cmp al, 0x08          ; Backspace?
    je .backspace
    stosb                 ; Store char
    mov ah, 0x0E          ; Echo char
    int 0x10
    jmp .read_char
.backspace:
    cmp di, buffer
    je .read_char
    dec di
    mov ah, 0x0E
    mov al, 0x08          ; Backspace
    int 0x10
    mov al, ' '           ; Space (to clear the character)
    int 0x10
    mov al, 0x08          ; Backspace again (to move cursor back)
    int 0x10
    jmp .read_char
.done:
    mov al, 0
    stosb                 ; Null-terminate
    ret

%endif ; UTILS_ASM
