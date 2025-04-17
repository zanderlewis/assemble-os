# AssembleOS Makefile
# Developed by Zander Lewis (c) 2025

ASM = nasm
ASMFLAGS = -f bin -I $(SRC_DIR)
IMG = AssembleOS.img
BOOT = src/bootloader.asm
KERNEL = src/kernel.asm
KERNEL_BIN = kernel.bin
SRC_DIR = src

build: $(IMG)

$(IMG): $(BOOT) $(KERNEL_BIN)
	$(ASM) $(ASMFLAGS) $(BOOT) -o boot.tmp
	cat boot.tmp > $(IMG)
	dd if=$(KERNEL_BIN) of=$(IMG) bs=512 seek=1 conv=notrunc
	truncate -s 8704 $(IMG)
	rm -f boot.tmp
	@echo "AssembleOS image built successfully!"

$(KERNEL_BIN): $(KERNEL) $(wildcard $(SRC_DIR)/*.asm)
	$(ASM) $(ASMFLAGS) $(KERNEL) -o $(KERNEL_BIN)

run: $(IMG)
	@echo "Starting AssembleOS..."
	qemu-system-i386 -drive file=$(IMG),format=raw,if=floppy

clean:
	@echo "Cleaning up AssembleOS build files..."
	if [ -f $(KERNEL_BIN) ]; then rm -f $(KERNEL_BIN); fi
	if [ -f $(IMG) ]; then rm -f $(IMG); fi
	if [ -f boot.tmp ]; then rm -f boot.tmp; fi

it: clean build run
	@echo "AssembleOS session completed."
