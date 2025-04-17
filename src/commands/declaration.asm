; Command Declaration Module

main_loop:
    mov si, prompt
    call print_string
    call read_line
    
    ; Add a newline after user input
    mov si, newline
    call print_string
    
    ; Check if buffer is empty
    mov si, buffer
    lodsb
    cmp al, 0
    je .empty_command
    dec si          ; Move back to start of buffer
    
    ; Parse command and arguments
    call parse_command
    
    ; Check commands
    mov si, cmd_buffer
    mov di, help_cmd
    call strcmp
    jc .help_command
    
    mov si, cmd_buffer
    mov di, echo_cmd
    call strcmp
    jc .echo_command
    
    mov si, cmd_buffer
    mov di, cls_cmd
    call strcmp
    jc .cls_command
    
    mov si, cmd_buffer
    mov di, disk_cmd
    call strcmp
    jc .disk_command
    
    mov si, cmd_buffer
    mov di, ver_cmd
    call strcmp
    jc .ver_command
    
    mov si, cmd_buffer
    mov di, mem_cmd
    call strcmp
    jc .mem_command
    
    mov si, cmd_buffer
    mov di, time_cmd
    call strcmp
    jc .time_command
    
    mov si, cmd_buffer
    mov di, ls_cmd
    call strcmp
    jc .ls_command
    
    mov si, cmd_buffer
    mov di, cat_cmd
    call strcmp
    jc .cat_command
    
    mov si, cmd_buffer
    mov di, write_cmd
    call strcmp
    jc .write_command
    
    mov si, cmd_buffer
    mov di, reboot_cmd
    call strcmp
    jc .reboot_command
    
    ; If not a recognized command, show invalid command message
    mov si, invalid_cmd_msg
    call print_string
    jmp main_loop

.empty_command:
    jmp main_loop
    
.help_command:
    mov si, help_msg
    call print_string
    jmp main_loop
    
.echo_command:
    ; Output the argument that was parsed
    mov si, arg_buffer
    call print_string
    mov si, newline
    call print_string
    jmp main_loop
    
.cls_command:
    call clear_screen
    jmp main_loop
    
.disk_command:
    ; Parse disk subcommand
    mov si, arg_buffer
    mov di, disk_info_cmd
    call strcmp
    jc .disk_info
    
    mov si, arg_buffer
    mov di, disk_read_cmd
    call strcmp
    jc .disk_read
    
    ; Invalid disk subcommand
    mov si, invalid_disk_cmd
    call print_string
    jmp main_loop
    
.disk_info:
    call show_disk_info
    jmp main_loop
    
.disk_read:
    call read_disk_sector
    jmp main_loop
    
.ver_command:
    mov si, version_msg
    call print_string
    jmp main_loop
    
.mem_command:
    call show_memory_info
    jmp main_loop
    
.time_command:
    call show_time
    jmp main_loop
    
.ls_command:
    call list_files
    jmp main_loop
    
.cat_command:
    call cat_file
    jmp main_loop
    
.write_command:
    call write_file
    jmp main_loop
    
.reboot_command:
    mov si, reboot_msg
    call print_string
    
    ; Wait for any key
    mov ah, 0
    int 0x16
    
    ; Reboot
    mov ax, 0
    int 0x19