#include <malloc.h>

int main(){
    // This calls the functions in the assembly file malloc.s
    // The functions are defined in malloc.h
    
    // Debug, call foo in the malloc.s
    int res = foo(42);
    printf("Debug = %d\n", res);

    //alloc_init();
    //alloc();
    // alloc();
    // alloc();
    // alloc();
    // alloc();
}