CC=/opt/local/bin/i386-elf-gcc
LD=/opt/local/bin/i386-elf-ld
NASM=nasm
CFLAGS=-Wall -Wextra -g -O0 -I./include

all: buildimage

buildimage: boot.o init.o kernel.o disk.img
	dd if=boot.o of=disk.img bs=512 count=1 conv=notrunc > /dev/null 2>&1
	dd if=init.bin of=disk.img bs=512 seek=1 conv=notrunc > /dev/null 2>&1
	dd if=kernel.img of=disk.img bs=512 seek=64 conv=notrunc > /dev/null 2>&1

disk.img:
	dd if=/dev/zero of=disk.img bs=1m count=10 > /dev/null 2>&1

boot.o: boot/boot.s
	${NASM} -fbin -o boot.o boot/boot.s

init.o: boot/init.c lib/screen.c include/screen.h string.o io.o include/x86.h
	${CC} ${CFLAGS} -c boot/init.c -nostdlib -fno-builtin -nostartfiles -nodefaultlibs
	${LD} -T boot/init.ld -o init.bin

exceptions.o: exceptions/exceptions.c
	${CC} ${CFLAGS} -c exceptions/exceptions.c -nostdlib -fno-builtin -nostartfiles -nodefaultlibs

idt.o: exceptions/idt.c include/idt.h
	${CC} ${CFLAGS} -c exceptions/idt.c -nostdlib -fno-builtin -nostartfiles -nodefaultlibs

exception_handler.o: exceptions/exception_handler.s
	${NASM} -felf32 -g -o exception_handler.o exceptions/exception_handler.s

io.o: lib/io.s
	${NASM} -felf32 -g -o io.o lib/io.s

string.o: lib/string.s include/string.h
	${NASM} -felf32 -g -o string.o lib/string.s

screen.o: lib/screen.c include/screen.h
	${CC} ${CFLAGS} -c lib/screen.c -nostdlib -fno-builtin -nostartfiles -nodefaultlibs

elf.o: lib/elf.c include/elf.h
	${CC} ${CFLAGS} -c lib/elf.c -nostdlib -fno-builtin -nostartfiles -nodefaultlibs

cpuid.o: 
	${CC} ${CFLAGS} -c lib/cpuid.c -nostdlib -fno-builtin -nostartfiles -nodefaultlibs
	
kernel.o: kernel/kernel.c screen.o lib/screen.c cpuid.o
	${CC} ${CFLAGS} -c kernel/kernel.c -nostdlib -fno-builtin -nostartfiles -nodefaultlibs
	${LD} -T kernel/kernel.ld -o kernel.img

clean:
	rm -rf *.o *.img *.bin
