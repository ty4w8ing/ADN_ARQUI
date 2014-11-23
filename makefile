
generar: generar.o
	ld -m elf_i386 -o generar generar.o

generar.o: generar.asm
	nasm -f elf -g -F stabs generar.asm -l generar.lst


