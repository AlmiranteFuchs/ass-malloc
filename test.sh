nasm -f elf64 -g -F dwarf -o nyalloc.o nyalloc.asm
ld -o nyalloc nyalloc.o
