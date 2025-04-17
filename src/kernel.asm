; AssembleOS Kernel

org 0x0000          ; Offset 0 within segment 0x1000

;;; Kernel Entry Point ;;;
start:
    ; Store the boot drive number passed in DL from bootloader
    mov [boot_drive_number], dl
    
    ; Set up data segment registers
    mov ax, cs      ; Copy code segment to data segments
    mov ds, ax      ; Set DS=CS
    mov es, ax      ; Set ES=CS
    
    ; Clear the screen for a fresh start
    call clear_screen
    
    ; Show welcome banner
    mov si, os_banner
    call print_string
    
    ; Print welcome message
    mov si, welcome_msg
    call print_string
    
    ; Initialize filesystem
    call init_filesystem
    
    ; Show memory info
    call show_memory_info

;;; Command Declaration and Loop ;;;
%include "commands/declaration.asm"

;;; Command Parsing ;;;
%include "commands/parsing.asm"

;;; Screen Functions ;;;
%include "screen.asm"

;;; File System Functions ;;;
%include "fs.asm"

;;; Disk Functions ;;;
%include "disk.asm"

;;; Memory Functions ;;;
%include "mem.asm"

;;; Time Functions ;;;
%include "time.asm"

;;; Utility Functions ;;;
%include "utils.asm"

;;; Data Section ;;;
%include "data.asm"
