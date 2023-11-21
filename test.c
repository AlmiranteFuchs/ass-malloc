#include <stdio.h>
#include "ass_malloc.h"


int main(){
    // This calls the functions in the assembly file malloc.s
    // The functions are defined in malloc.h
    void *ptr1, *ptr2;
    // Debug, call foo in the malloc.s
    iniciaAlocador();

    // Call the alloc function
    ptr1 = (void *) alocaMem(10);
    printf("ptr = %p\n", ptr1);
    ptr2 = (void *) alocaMem(20);
    printf("ptr = %p\n", ptr2);

    imprimeMapa();

    liberaMem(ptr1);
    liberaMem(ptr2);

    finalizaAlocador();

}
