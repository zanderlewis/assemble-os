; Screen Module

; Clear the screen
clear_screen:
    mov ah, 0x00           ; Set video mode
    mov al, 0x03           ; 80x25 text mode
    int 0x10
    ret