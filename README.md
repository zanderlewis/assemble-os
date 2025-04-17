# AssembleOS
AssembleOS is an Operating System made in 100% Assembly. It features basic commands and a basic on-RAM filesystem.

## Background
AssembleOS is an operating system in pure assembly language, entirely written by AI (Claude 3.7 Sonnet, ChatGPT o3, and ChatGPT o4). It is designed to be simple and lightweight, making it easy to understand and modify. The OS is built using NASM (Netwide Assembler) and runs on QEMU, a generic and open-source machine emulator and virtualizer.

## Pre-requisites
For building AssembleOS, you need to have the following tools installed:
- [NASM](https://www.nasm.us/)
- [QEMU](https://www.qemu.org/)
- [Make](https://www.gnu.org/software/make/)

You can install these tools using your package manager. For example, on MacOS, you can run:
```bash
brew install nasm qemu make
```

## Building and Running
To build and run AssembleOS, you can simply run this command:
```bash
make it
```

This will build the kernel and run it in QEMU. You can also run the following commands:
```bash
make build
make run
```

The `make build` command will build the kernel, and the `make run` command will run it in QEMU.

## Commands
AssembleOS supports the following commands:
- `ls`: List files in the current directory.
- `cat <filename>`: Display the contents of a file.
- `write <filename> <text>`: Write text to a file.
- `echo <text>`: Print text to the console.
- `cls`: Clear the console.
- `exit`: Reboot the system.
- `help`: Display help information.
- `disk info`: Display information about the disk.
- `disk read`: Read the first 16 bytes of the disk.
- `ver`: Display the version and other information.
- `mem`: Display memory information.
- `time`: Displays the current time in UTC.
