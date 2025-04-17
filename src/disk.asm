; Disk Module

; Boot drive number passed from bootloader
boot_drive_number db 0

; Show disk info
show_disk_info:
    mov si, disk_info_msg
    call print_string
    ret

; Read a sector from disk
read_disk_sector:
    mov si, disk_read_msg
    call print_string
    
    ; Save original ES
    push es
    
    ; Read sector 1 (the boot sector) into temp_buffer
    mov ax, 0              ; Segment 0
    mov es, ax
    mov bx, temp_buffer    ; Buffer
    
    ; Reset disk system first to ensure reliable reads
    xor ah, ah                  ; Function 0 - reset disk system
    mov dl, [boot_drive_number] ; Use stored boot drive number
    int 0x13
    
    mov dl, [boot_drive_number] ; Use stored boot drive number
    mov dh, 0                   ; Head 0
    mov ch, 0                   ; Cylinder 0
    mov cl, 1                   ; Sector 1 (boot sector)
    mov ah, 0x02                ; Read sectors
    mov al, 1                   ; Read 1 sector
    int 0x13
    
    ; Restore original ES
    pop es
    
    ; Display first few bytes as hex
    mov si, sector_data_msg
    call print_string
    
    mov cx, 32             ; Show 32 bytes
    mov si, temp_buffer
.hex_loop:
    lodsb
    call print_hex_byte
    mov al, ' '
    call print_char
    
    ; Add newline every 16 bytes for readability
    test cx, 0x000F
    jnz .no_line_break
    push si
    mov si, newline
    call print_string
    pop si
.no_line_break:
    
    loop .hex_loop
    
    mov si, newline
    call print_string
    ret
