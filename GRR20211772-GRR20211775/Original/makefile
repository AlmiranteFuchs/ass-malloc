CC = gcc
CFLAGS = -g -Wall -no-pie
PROG = avalia

all: $(PROG)

$(PROG): test.o ass_malloc.o
	$(CC) $(CFLAGS) -o $(PROG) test.o ass_malloc.o

test.o: test.c
	$(CC) $(CFLAGS) -c test.c -o test.o

ass_malloc.o: ass_malloc.h ass_malloc.s
	as ass_malloc.s -o ass_malloc.o -g

clean:
	rm -rf *.o $(PROG)
