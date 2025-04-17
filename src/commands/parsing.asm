; Command Parsing Module

parse_command:
    mov si, buffer
    mov di, cmd_buffer
    
.cmd_loop:
    lodsb                  ; Get character from buffer
    cmp al, 0              ; End of string?
    je .cmd_end
    cmp al, ' '            ; Space?
    je .found_space
    stosb                  ; Store in cmd_buffer
    jmp .cmd_loop
    
.found_space:
    mov byte [di], 0       ; Null-terminate cmd_buffer
    mov di, arg_buffer     ; Switch to arg_buffer
    
.arg_loop:
    lodsb                  ; Get next character
    cmp al, 0              ; End of string?
    je .arg_end
    stosb                  ; Store in arg_buffer
    jmp .arg_loop
    
.cmd_end:
    mov byte [di], 0       ; Null-terminate cmd_buffer
    mov byte [arg_buffer], 0 ; Clear arg_buffer
    
.arg_end:
    mov byte [di], 0       ; Null-terminate arg_buffer
    ret
