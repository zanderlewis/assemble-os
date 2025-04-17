; Filesystem Module

; Initialize the RAM filesystem (just mock data)
init_filesystem:
    ; Initialize first file entry
    mov di, fs_entries
    
    ; File 1: README.TXT
    mov si, readme_name
    call strcpy
    add di, 12          ; Skip to data size
    
    mov word [di], readme_data_end - readme_data
    add di, 2           ; Skip size field
    
    mov word [di], readme_data
    add di, 2           ; Skip to next entry
    
    ; File 2: HELLO.TXT
    mov si, hello_name
    call strcpy
    add di, 12          ; Skip to data size
    
    mov word [di], hello_data_end - hello_data
    add di, 2           ; Skip size field
    
    mov word [di], hello_data
    add di, 2           ; Skip to next entry
    
    ; File 3: OS.INFO
    mov si, osinfo_name
    call strcpy
    add di, 12          ; Skip to data size
    
    mov word [di], osinfo_data_end - osinfo_data
    add di, 2           ; Skip size field
    
    mov word [di], osinfo_data
    add di, 2           ; End of entries
    
    ; Null terminate the list
    mov byte [di], 0
    
    ret

; List files in our filesystem
list_files:
    mov si, fs_header_msg
    call print_string
    
    mov si, fs_entries
    
.next_file:
    cmp byte [si], 0
    je .done
    
    push si
    call print_string        ; Print filename
    pop si
    
    add si, 12               ; Skip to file size
    
    mov ax, [si]             ; Load file size
    push si
    
    ; Print spaces to align size column - even simpler approach
    mov cx, 16               ; Target column for size
    mov bx, si               
    sub bx, 12               ; Go back to filename start
    
    ; Count filename length using a safer approach
    push ax                  ; Save file size
    xor dx, dx               ; DX will hold string length
    mov si, bx               ; SI points to filename
.count_loop:
    cmp byte [si], 0         ; Check for null terminator using safer addressing
    je .count_done
    inc dx                   ; Increment length counter
    inc si                   ; Move to next character
    jmp .count_loop
    
.count_done:
    ; Calculate spaces needed (handle the case where filename > column width)
    cmp dx, cx               ; Compare length to target column
    jae .min_space           ; If filename too long, just add minimum space
    sub cx, dx               ; Normal case: subtract length from target
    jmp .space_ready
.min_space:
    mov cx, 2                ; Add just 2 spaces if filename is too long
.space_ready:
    pop ax                   ; Restore file size
    
    ; Print the spaces
    mov al, ' '
.print_space_loop:
    cmp cx, 0
    jle .print_size
    call print_char
    dec cx
    jmp .print_space_loop
    
.print_size:
    mov bx, ax               ; Size in BX
    call print_decimal
    mov si, bytes_msg
    call print_string
    
    pop si
    add si, 4                ; Skip to next entry
    
    jmp .next_file
    
.done:
    ret

; Print file contents
cat_file:
    mov si, arg_buffer
    cmp byte [si], 0
    je .no_filename
    
    ; Search for file
    mov di, fs_entries
    
.find_file:
    cmp byte [di], 0
    je .file_not_found
    
    push si
    push di
    call strcmp
    pop di
    pop si
    
    jc .file_found
    
    add di, 16               ; Skip to next entry
    jmp .find_file
    
.file_found:
    add di, 12               ; Skip to size field
    mov cx, [di]             ; Get file size
    
    ; Verify file size is reasonable
    cmp cx, 0
    je .empty_file
    cmp cx, 1024             ; Limit to reasonable size
    jbe .size_ok
    mov cx, 1024             ; Cap at 1024 bytes for safety
    
.size_ok:
    ; Print header
    mov si, displaying_file_msg
    call print_string
    mov si, arg_buffer
    call print_string
    mov si, displaying_size_msg
    call print_string
    push cx                  ; Save size for later
    mov bx, cx              ; Print file size
    call print_decimal
    mov si, bytes_msg_short
    call print_string
    pop cx                  ; Restore size
    
    ; Get data pointer 
    add di, 2                ; Skip to data pointer
    mov si, [di]             ; Get data pointer
    
    ; Print file contents with correct size limit
.print_loop:
    cmp cx, 0                ; Check if we've printed all characters
    je .print_done
    lodsb                    ; Load byte from [SI] into AL
    call print_char          ; Print the character
    dec cx                   ; Decrement counter
    jmp .print_loop          ; Continue loop
    
.print_done:
    mov si, newline
    call print_string
    ret
    
.empty_file:
    mov si, empty_file_msg
    call print_string
    ret
    
.no_filename:
    mov si, cat_usage_msg
    call print_string
    ret
    
.file_not_found:
    mov si, file_not_found_msg
    call print_string
    ret

; Write to a file (create a new one in our RAM filesystem)
write_file:
    mov si, arg_buffer         ; arg_buffer = "filename text..."
    mov al, [si]
    cmp al, 0                  ; require filename
    je .no_filename
    ; find space separating filename and text
    mov bx, si
.find_sep:
    mov al, [bx]
    cmp al, ' '
    je .have_sep
    cmp al, 0
    je .no_text
    inc bx
    jmp .find_sep
.have_sep:
    ; compute filename length (<=11)
    mov dx, bx
    sub dx, si
    cmp dx, 11
    jbe .name_len_ok
    mov dx, 11
.name_len_ok:
    ; locate free entry
    mov di, fs_entries
.next_entry:
    cmp byte [di], 0
    je .entry_found
    add di, 16
    jmp .next_entry
.entry_found:
    ; Clear filename field (12 bytes)
    push di                  ; Save entry start
    mov cx, 12
    xor al, al
    rep stosb
    pop di                   ; Restore entry start
    
    ; Copy filename from arg_buffer
    push di                  ; Save entry start
    mov cx, dx               ; CX = filename length
    mov si, arg_buffer
    rep movsb                ; Copy filename
    pop di                   ; Restore entry start
    
    ; Move to size field (entry+12)
    add di, 12
    
    ; Calculate text pointer and length
    mov si, arg_buffer       ; Start of arg_buffer 
    add si, dx               ; Skip filename
    inc si                   ; Skip separator space
    
    ; Calculate text length
    mov bx, si               ; BX = start of text
    xor cx, cx               ; CX will hold text length
.count_text:
    mov al, [bx]
    cmp al, 0
    je .text_counted
    inc cx
    inc bx
    jmp .count_text
.text_counted:
    ; Store text length
    mov [di], cx
    add di, 2                ; Move to data pointer field
    
    ; Allocate data area
    mov ax, [user_data_ptr]
    mov [di], ax             ; Store pointer to allocated area
    mov di, ax               ; DI = destination for text
    
    ; Copy text to data area
    rep movsb                ; Copy CX bytes from SI to DI
    mov byte [di], 0         ; Null-terminate
    
    ; Update user_data_ptr
    mov ax, [user_data_ptr]
    add ax, cx               ; Add text length
    inc ax                   ; Add null terminator
    mov [user_data_ptr], ax
    
    ; Success message
    mov si, file_written_msg
    call print_string
    ret
    
.no_text:
    mov si, write_usage_msg
    call print_string
    ret

.no_filename:
    mov si, write_usage_msg
    call print_string
    ret

; Read multi-line text input (ends with Ctrl+D)
read_multiline:
    pusha
    mov di, temp_buffer
    xor cx, cx                 ; Initialize character count to 0
    
    ; Get the first line of input
    call read_line
    
    ; Copy first line to temp buffer
    mov si, buffer
.copy_first:
    lodsb                      ; Load character from buffer
    cmp al, 0                  ; Check for end of line
    je .first_done
    stosb                      ; Store character in temp_buffer
    inc cx                     ; Count this character
    jmp .copy_first
    
.first_done:
    ; Add newline to buffer
    mov al, 0Dh
    stosb
    inc cx
    mov al, 0Ah
    stosb
    inc cx
    
    ; Print prompt for next line
    mov si, continue_prompt
    call print_string
    
    ; Continue reading lines until Ctrl+D
.read_more:
    call read_line
    
    ; Check for Ctrl+D as first character
    mov al, [buffer]
    cmp al, 4                  ; ASCII code for Ctrl+D
    je .done
    
    ; Copy this line to the buffer
    mov si, buffer
.copy_line:
    lodsb
    cmp al, 0                  ; End of line?
    je .end_of_line
    stosb
    inc cx                     ; Count each character
    jmp .copy_line
    
.end_of_line:
    ; Add newline to buffer
    mov al, 0Dh
    stosb
    inc cx
    mov al, 0Ah
    stosb
    inc cx
    
    ; Print prompt for next line
    mov si, continue_prompt
    call print_string
    jmp .read_more
    
.done:
    ; Null-terminate the buffer
    mov byte [di], 0
    inc cx                     ; Count the null terminator
    
    ; Store the count in character_count for debugging/verification
    mov [character_count], cx
    
    popa
    ret

; Special version of read_line that checks for Ctrl+D and doesn't echo it
read_line_special:
    mov di, buffer
.read_char:
    mov ah, 0
    int 0x16              ; BIOS: read char
    
    ; Special handling for Ctrl+D
    cmp al, 4             ; Ctrl+D?
    je .got_ctrl_d
    
    cmp al, 0x0D          ; Enter?
    je .done
    cmp al, 0x08          ; Backspace?
    je .backspace
    
    stosb                 ; Store char
    mov ah, 0x0E          ; Echo char
    int 0x10
    jmp .read_char

.got_ctrl_d:
    ; Accept Ctrl+D anywhere, not just at the beginning
    mov byte [di], 0      ; Null terminate the current buffer
    ret
    
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

; Read text input until Ctrl+D
read_text_input:
    pusha
    mov di, temp_buffer     ; Start writing at temp_buffer
    xor cx, cx              ; Clear character counter
    
    ; Loop for input
.input_loop:
    ; Print prompt for first/next line
    mov si, continue_prompt
    call print_string
    
    ; Get a line of input
    call read_line
    
    ; Check if it's just Ctrl+D (start of line)
    mov al, [buffer]
    cmp al, 4              ; Ctrl+D ASCII code
    je .done
    
    ; Copy the line to our buffer
    mov si, buffer
.copy_loop:
    lodsb                  ; Get character
    cmp al, 0              ; End of string?
    je .end_of_line
    stosb                  ; Store in temp_buffer
    inc cx                 ; Count the character
    jmp .copy_loop
    
.end_of_line:
    ; Add CR+LF
    mov al, 13             ; CR
    stosb
    inc cx                 ; Count CR
    mov al, 10             ; LF
    stosb
    inc cx                 ; Count LF
    jmp .input_loop
    
.done:
    ; Store null terminator
    mov byte [di], 0
    
    ; Store the character count
    mov [input_size], cx
    
    popa
    ret