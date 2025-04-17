; Memory Module

; Show memory information
show_memory_info:
    mov si, memory_info_msg
    call print_string
    
    ; Get memory size (simplified)
    mov ax, 0xE801
    int 0x15
    jc .mem_error
    
    ; AX = KB between 1M and 16M, BX = number of 64K blocks above 16M
    
    ; Print AX (kB below 16MB)
    push bx
    mov bx, ax
    mov si, memory_below_16m_msg
    call print_string
    call print_decimal
    mov si, kb_msg
    call print_string
    pop bx
    
    ; Print BX * 64 (kB above 16MB)
    push bx
    mov ax, bx
    mov bx, 64
    mul bx
    mov bx, ax
    mov si, memory_above_16m_msg
    call print_string
    call print_decimal
    mov si, kb_msg
    call print_string
    pop bx
    
    mov si, newline
    call print_string
    ret

.mem_error:
    mov si, memory_error_msg
    call print_string
    ret
