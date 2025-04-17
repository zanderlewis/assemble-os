; Data Module
%ifndef DATA_ASM
%define DATA_ASM

; OS Banner and Information
; OS Banner and Information
os_banner db 0Dh, 0Ah
          db '+-----------------------------+', 0Dh, 0Ah
          db '|         Assemble OS         |', 0Dh, 0Ah
          db '+-----------------------------+', 0Dh, 0Ah
          db '|         Version 1.0         |', 0Dh, 0Ah
          db '+-----------------------------+', 0Dh, 0Ah
          db '|   (c) 2025 Zander Lewis     |', 0Dh, 0Ah
          db '+-----------------------------+', 0Dh, 0Ah
          db 0Dh, 0Ah, 0

welcome_msg db 'Welcome to AssembleOS v1.0!', 0Dh, 0Ah
            db '(c) 2025 Zander Lewis', 0Dh, 0Ah
            db 'Type "help" for available commands.', 0Dh, 0Ah, 0Dh, 0Ah, 0

prompt      db 'A> ', 0
continue_prompt db '... ', 0
newline     db 0Dh, 0Ah, 0

; Commands
help_cmd    db 'help', 0
echo_cmd    db 'echo', 0
cls_cmd     db 'cls', 0
disk_cmd    db 'disk', 0
ver_cmd     db 'ver', 0
mem_cmd     db 'mem', 0
time_cmd    db 'time', 0
ls_cmd      db 'ls', 0
cat_cmd     db 'cat', 0
write_cmd   db 'write', 0
reboot_cmd  db 'reboot', 0

; Disk subcommands
disk_info_cmd db 'info', 0
disk_read_cmd db 'read', 0

; Messages
help_msg    db 'Available commands:', 0Dh, 0Ah
            db '  help         - Show this help message', 0Dh, 0Ah
            db '  echo [text]  - Display text', 0Dh, 0Ah
            db '  cls          - Clear the screen', 0Dh, 0Ah
            db '  disk info    - Show disk information', 0Dh, 0Ah
            db '  disk read    - Read first sector', 0Dh, 0Ah
            db '  ver          - Show OS version', 0Dh, 0Ah
            db '  mem          - Show memory information', 0Dh, 0Ah
            db '  time         - Display current time', 0Dh, 0Ah
            db '  ls           - List files', 0Dh, 0Ah
            db '  cat [file]   - Show file contents', 0Dh, 0Ah
            db '  write [file] - Create a new file', 0Dh, 0Ah
            db '  reboot       - Reboot system', 0Dh, 0Ah, 0


invalid_cmd_msg    db '[ERROR] Invalid command', 0Dh, 0Ah, 0
invalid_disk_cmd   db '[ERROR] Invalid disk command. Try "disk info" or "disk read"', 0Dh, 0Ah, 0
disk_info_msg      db 'Disk information: Floppy Disk, 1.44MB', 0Dh, 0Ah, 0
disk_read_msg      db 'Reading boot sector...', 0Dh, 0Ah, 0
disk_error_msg     db 'Error reading from disk', 0Dh, 0Ah, 0
sector_data_msg    db 'Boot sector data:', 0Dh, 0Ah, 0
version_msg        db 'AssembleOS v1.0', 0Dh, 0Ah
                   db '(c) 2025 Zander Lewis', 0Dh, 0Ah, 0
memory_info_msg    db 'Memory Information:', 0Dh, 0Ah, 0
memory_below_16m_msg db 'Memory below 16MB: ', 0
memory_above_16m_msg db 0Dh, 0Ah, 'Memory above 16MB: ', 0
kb_msg            db ' KB', 0Dh, 0Ah, 0
memory_error_msg  db 'Error retrieving memory information', 0Dh, 0Ah, 0
time_msg          db 'Current time: ', 0
time_error_msg    db 'Error retrieving current time', 0Dh, 0Ah, 0
fs_header_msg     db 'Files:', 0Dh, 0Ah, 0
bytes_msg         db ' bytes', 0Dh, 0Ah, 0
bytes_msg_short   db ' bytes', 0Dh, 0Ah, 0Dh, 0Ah, 0
cat_usage_msg     db 'Usage: cat [filename]', 0Dh, 0Ah, 0
displaying_file_msg db 'File: ', 0
displaying_size_msg db ' (', 0 
empty_file_msg    db 'File is empty.', 0Dh, 0Ah, 0
file_not_found_msg db '[ERROR] File not found', 0Dh, 0Ah, 0
write_usage_msg   db 'Usage: write [filename] [text]', 0Dh, 0Ah, 0
write_prompt_msg  db 'Enter file content (Ctrl+D on a new line to finish):', 0Dh, 0Ah, 0
file_written_msg  db 'File written successfully.', 0Dh, 0Ah, 0
no_space_msg      db '[ERROR] No space left for new files.', 0Dh, 0Ah, 0
reboot_msg          db 0Dh, 0Ah, 'Press any key to reboot...', 0Dh, 0Ah, 0
debug_size_msg    db 'Debug: File size = ', 0
debug_buffer      times 20 db 0     ; Buffer for debugging

; File system data
readme_name db 'README.TXT', 0, 0, 0
readme_data db 'Welcome to AssembleOS!', 0Dh, 0Ah
            db 'This is a simple 16-bit operating system written in assembly language.', 0Dh, 0Ah
            db 'Type "help" to see available commands.', 0Dh, 0Ah
readme_data_end:

hello_name db 'HELLO.TXT', 0, 0, 0
hello_data db 'Hello, world!', 0Dh, 0Ah
           db 'This is a text file in the RAM filesystem.', 0Dh, 0Ah
hello_data_end:

osinfo_name db 'OS.INFO', 0, 0, 0, 0, 0, 0
osinfo_data db 'AssembleOS v1.0.1', 0Dh, 0Ah
            db 'Developer: Zander Lewis', 0Dh, 0Ah
            db 'Year: 2025', 0Dh, 0Ah
            db 'Architecture: x86 16-bit Real Mode', 0Dh, 0Ah
osinfo_data_end:

; Buffers
buffer      times 128 db 0    ; Input buffer
cmd_buffer  times 16  db 0    ; Command buffer
arg_buffer  times 112 db 0    ; Argument buffer
temp_buffer times 512 db 0    ; Temporary buffer for disk operations
character_count dw 0          ; For tracking file content size
input_size dw 0               ; For tracking input size

; File system entries (16 bytes per entry: 12 bytes filename, 2 bytes size, 2 bytes pointer)
fs_entries  times 160 db 0

; Dynamic user data area - for file contents created at runtime
user_data_ptr dw user_data    ; Points to the next available memory location
user_data:                    ; Start of user data storage (1024 bytes available)
times 1024 db 0               ; Reserve 1024 bytes for user file storage

%endif ; DATA_ASM

