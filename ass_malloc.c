#include <malloc.h>

int main(){
    // This calls the functions in the assembly file malloc.s
    // The functions are defined in malloc.h
    
    // Debug, call foo in the malloc.s
    foo();
}