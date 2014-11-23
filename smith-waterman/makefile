smith: smith.o
	ld -m elf_i386 -o smith smith.o

smith.o: smith.asm
	nasm -f elf -g -F stabs smith.asm -l smith.lst
