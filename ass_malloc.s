.section .data
    I: .quad 0
    INITIAL_TOP_HEAP: .quad 0
    INITIAL_LK: .quad 0
    TOP_LK: .quad 0
    hello: .ascii "Debug\n"
.section .text

.globl alloc_init
.type alloc_init, @function
alloc_init:
    # Requests the top of the heap, (brk), saves in the global variable INITIAL_TOP_HEAP
    pushq %rbp
    movq %rsp, %rbp                     # Activate the stack frame

    cmpq $0, INITIAL_TOP_HEAP            # IF brk was not set
    jne fim_inicia                      # THEN goto alloc_exit;

    # get the top of the heap
    movq $0, %rdi                       # %rdi = 0;
    movq $12, %rax                      # %rax = 12;
    syscall 
    movq %rax, INITIAL_TOP_HEAP          # INITIAL_TOP_HEAP = %rax;
    movq %rax, TOP_LK               # TOP_LK = INITIAL_TOP_HEAP;
    movq %rax, INITIAL_LK             # INITIAL_LK = INITIAL_TOP_HEAP;

    fim_inicia:
    pop %rbp
    ret

.globl alloc_exit
.type alloc_exit, @function
alloc_exit:
    # Restaura o valor inicial do brk
    pushq %rbp
    movq %rsp, %rbp

    movq INITIAL_TOP_HEAP, %rdi
    movq $12, %rax
    syscall
    
    pop %rbp
    ret

.globl alloc
.type alloc, @function
alloc:
    # Procura um bloco livre que caiba o tamanho solicitado seta como ocupado e retorna o endereço de inicio
    # se nao achar cria um novo bloco utilizando o brk e retorna o endereço de inicio
    pushq %rbp
    movq %rsp, %rbp

# Private functions

create_node:
    pushq %rbp
    movq %rsp, %rbp

    movq %rdi, %rbx                 # Get the size of the block to be created from the stack
    movq %rdi, %r8                 # Get the size of the block to be created from the stack

    movq TOP_LK, %rax               # Get the top of the heap
    addq %rbx, %rax                     # Add the size of the block to the top of the heap
    addq $16, %rax                      # Add 16 bytes to the top of the heap for the dirty bit and the size of the block

    movq %rax, TOP_LK               # Set the new top of the heap
    movq TOP_LK, %rdi               # Set the new top of the heap as the argument for the brk syscall
    movq $12, %rax                      # Set the brk syscall number
    syscall                             # Call the brk syscall

    # Treat the return of the syscall
    cmpq $0, %rax                       # IF the syscall failed
    je fim_create_node                   # THEN goto fim_create_node; 

    # system call succeeded
    movq TOP_LK, %rax                   # Get the top of the heap
    # sub size of the block from the top of the heap
    subq %rbx, %rax                     # Subtract the size of the block from the top of the heap
    subq $16, %rax                      # Subtract 16 bytes from the top of the heap for the dirty bit and the size of the block

    # Goes to the first 8 bytes of the block and sets the dirty bit to 0
    movq %rax, %rbx                     # Get the address of the dirty bit
    movq $1, 8(%rbx)                    # Set the dirty bit to 0
    movq %r8, 16(%rbx)                 # Set the size of the block



    
    # TODO save in linked list


    fim_create_node:
    pop %rbp
    ret

.globl foo
.type foo, @function
foo:
    # Prints hello world
    pushq %rbp
    movq %rsp, %rbp

    movq $1, %rdi
    movq $1, %rax
    movq $hello, %rsi
    movq $12, %rdx
    syscall

    pop %rbp
    ret
    

#       _start
#     call alloc_init
#     movq $5, %rdi
#     call create_node
#     call alloc_exit

#     movq $100, %rdi
#     movq $12, %rax
#     syscall
    

#     movq $60, %rax
#     movq TOP_LK, %rdi
#     syscall

