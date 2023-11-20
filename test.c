#include <stdio.h>
#include "ass_malloc.h"

int main(){
    // This calls the functions in the assembly file malloc.s
    // The functions are defined in malloc.h
    void *ptr1;
    // Debug, call foo in the malloc.s
    int res = foo(42);
    printf("Debug = %d\n", res);

    // Call the alloc_init function
    iniciaAlocador();

    // Call the alloc function
    ptr1 = (void *) alocaMem(10);
    liberaMem(ptr1);


    //alloc_init();
    //alloc();
    // alloc();
    // alloc();
    // alloc();
    // alloc();
}