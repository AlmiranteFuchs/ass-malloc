as malloc.s -o malloc.o -g
ld malloc.o -o malloc -g
./malloc
echo $?
