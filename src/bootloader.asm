; AssembleOS Bootloader

org 0x7C00

start:
    ; Save boot drive number provided by BIOS
    mov [boot_drive], dl
    
    ; Set up video mode
    mov ah, 0x00
    mov al, 0x03           ; 80x25 text mode
    int 0x10
    
    ; Print boot message
    mov si, boot_msg
    call print_string
    
    ; Print version
    mov si, version_msg
    call print_string
    
    ; Small delay to show boot message
    mov cx, 0x0F
    mov dx, 0xFFFF
    mov ah, 0x86
    int 0x15
    
    ; Print copyright
    mov si, copyright_msg
    call print_string

    ; Print load message
    mov si, load_msg
    call print_string
    
    ; Show loading animation
    mov cx, 10             ; Number of dots
    mov si, dot_msg
.loading_loop:
    call print_string
    
    ; Small delay between dots
    push cx
    mov cx, 0x03
    mov dx, 0xFFFF
    mov ah, 0x86
    int 0x15
    pop cx
    
    loop .loading_loop

    ; Print newline
    mov si, newline
    call print_string

    ; Load kernel from disk:
    ; Read sectors (starting at sector 2) into memory at 0x1000:0000.
    mov ax, 0x1000
    mov es, ax
    xor bx, bx             ; BX = 0, so destination = 0x1000:0000

    ; Read sectors from boot drive
    mov dl, [boot_drive]   ; Use saved boot drive number
    mov dh, 0              ; Head 0 (required for BIOS int 13h)
    mov ah, 0x02           ; BIOS read sectors function
    mov al, 8              ; Number of sectors to read
    mov ch, 0              ; Cylinder 0
    mov cl, 2              ; Start at sector 2
    int 0x13
    
    ; Jump to loaded kernel (far jump to segment 0x1000, offset 0)
    jmp 0x1000:0

; Print string routine (prints the string at SI until a zero terminator)
print_string:
    mov ah, 0x0E           ; BIOS teletype function
.next_char:
    lodsb                  ; Load byte at SI into AL, and increment SI
    cmp al, 0
    je .done
    int 0x10
    jmp .next_char
.done:
    ret

boot_drive    db 0  ; Storage for boot drive number
boot_msg      db '  AssembleOS Booting...', 0Dh, 0Ah, 0
version_msg   db '  Version 1.0', 0Dh, 0Ah, 0
copyright_msg db '  (C) 2025 Zander Lewis', 0Dh, 0Ah, 0Dh, 0Ah, 0
load_msg      db '  Loading Kernel...', 0
dot_msg       db '.', 0
newline       db 0Dh, 0Ah, 0

; Pad boot sector to 510 bytes.
times 510 - ($ - $$) db 0
dw 0xAA55                 ; Boot signature
