; Time Module

; Show current time from RTC
show_time:
    mov si, time_msg
    call print_string
    
    ; Get current time from RTC
    mov ah, 0x02
    int 0x1A
    jc .time_error
    
    ; Convert BCD to ASCII and print
    ; CH = hours, CL = minutes, DH = seconds
    
    mov al, ch
    call print_bcd
    
    mov al, ':'
    call print_char
    
    mov al, cl
    call print_bcd
    
    mov al, ':'
    call print_char
    
    mov al, dh
    call print_bcd
    
    mov si, newline
    call print_string
    ret
    
.time_error:
    mov si, time_error_msg
    call print_string
    ret