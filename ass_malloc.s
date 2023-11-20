
.section .data
    I: .quad 0
    INITIAL_TOP_HEAP: .quad 0
    INITIAL_LK: .quad 0
    TOP_LK: .quad 0
    format: .string "%d\n"
    hello: .ascii "Debug\n"
    gerencial_bits: .string "################"
    block_free: .string "-"
    block_occupied: .string "+"
    
.section .text

.globl iniciaAlocador
.type iniciaAlocador, @function
iniciaAlocador:
    # Requests the top of the heap, (brk), saves in the global variable INITIAL_TOP_HEAP
    pushq %rbp
    movq %rsp, %rbp                     # Activate the stack frame

    cmpq $0, INITIAL_TOP_HEAP            # IF brk was not set
    jne fim_inicia                      # THEN goto finalizaAlocador;

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

.globl finalizaAlocador
.type finalizaAlocador, @function
finalizaAlocador:
    # Restaura o valor inicial do brk
    pushq %rbp
    movq %rsp, %rbp

    movq INITIAL_TOP_HEAP, %rdi
    movq $12, %rax
    syscall
    
    pop %rbp
    ret

.globl alocaMem
.type alocaMem, @function
alocaMem:
    # Procura um bloco livre que caiba o tamanho solicitado seta como ocupado e retorna o endereço de inicio
    # se nao achar cria um novo bloco utilizando o brk e retorna o endereço de inicio
    pushq %rbp
    movq %rsp, %rbp
    movq %rdi, %rax     # Numero de bytes a serem alocados
    movq INITIAL_LK, %rbx   # Get the initial top of the heap

    jmp busca_bloco
    cmpq $0, %rax   
    jne fim_alocaMem
    aloca_novo_bloco:
    call create_node
    jmp fim_alocaMem

    fim_alocaMem:
    call create_node
    pop %rbp
    ret

    busca_bloco:
        cmpq %rbx, TOP_LK
        je fim_alocaMem
        cmpq $0, 8(%rbx)
        jne pega_proximo_bloco

        # Bloco livre encontrado
        cmpq %rax, 16(%rbx)
        jg pega_proximo_bloco
        jmp bloco_encontrado

        pega_proximo_bloco:
        addq 16(%rbx), %rbx
        jmp busca_bloco
    
    bloco_encontrado:
        movq $1, 8(%rbx)
        movq %rbx, %rax
        pop %rbp
        ret

.globl liberaMem    # NEEDS TO RECIEVE THE ADDRESS OF THE BLOCK AND HIS LEFT NEIGHBOR
.type liberaMem, @function
liberaMem:
    pushq %rbp
    movq %rsp, %rbp

    movq %rdi, %rbx
    movq $0, 8(%rbx)  # Unset the dirty bit
    call fuse_neighbors # Fuse the neighbors if they are free 

    pop %rbp
    ret


# Private functions

.globl print_node
.type print_node, @function
print_node:
    # Prints all the nods in the heap
    pushq %rbp
    movq %rsp, %rbp

    movq TOP_LK, %rax                   # Get the top of the heap
    movq INITIAL_LK, %rbx               # Get the initial top of the heap
    

    # Loop to print all the nodes
    print_node_loop:
    cmpq %rbx, %rax                     # IF the top of the heap is equal to the initial top of the heap
    je fim_print_node                   # THEN goto fim_print_node;

    # Prints the dirty


    fim_print_node:



    pop %rbp
    ret

create_node:
    pushq %rbp
    movq %rsp, %rbp

    movq %rdi, %rbx                     # Get the size of the block to be created from the stack
    movq %rdi, %r8                      # Get the size of the block to be created from the stack

    movq TOP_LK, %rax                   # Get the top of the heap
    addq %rbx, %rax                     # Add the size of the block to the top of the heap
    addq $16, %rax                      # Add 16 bytes to the top of the heap for the dirty bit and the size of the block

    movq %rax, TOP_LK                   # Set the new top of the heap
    movq TOP_LK, %rdi                   # Set the new top of the heap as the argument for the brk syscall
    movq $12, %rax                      # Set the brk syscall number
    syscall                             # Call the brk syscall

    # Treat the return of the syscall
    cmpq $0, %rax                       # IF the syscall failed
    je fim_create_node                  # THEN goto fim_create_node; 

    # system call succeeded
    movq TOP_LK, %rax                   # Get the top of the heap
    # sub size of the block from the top of the heap
    subq %rbx, %rax                     # Subtract the size of the block from the top of the heap
    subq $16, %rax                      # Subtract 16 bytes from the top of the heap for the dirty bit and the size of the block

    # Goes to the first 8 bytes of the block and sets the dirty bit to 0
    movq %rax, %rbx                     # Get the address of the dirty bit
    movq $1, 8(%rbx)                    # Set the dirty bit to 0
    movq %r8, 16(%rbx)                  # Set the size of the block

    fim_create_node:

    movq %rbx, %rax                     # Get the address of the block to be returned
    pop %rbp
    ret

fuse_neighbors:
    pushq %rbp
    movq %rsp, %rbp

    movq %rdi, %rax                     # Get the address of the block to be freed
    
    # movq %rsi, %rbx                     # Get the address of the left neighbor IF PASSED BY PARAMETER

    # Get the address of the left neighbor
    movq INITIAL_LK, %rbx               # Get the initial top of the heap
    cmpq %rax, INITIAL_LK               # IF the address of the block to be freed is equal to the initial top of the heap
    je end_fuse_left                    # THEN goto end_fuse_left;

    busca_vizinho:
        movq %rbx, %rcx                     # Get the initial top of the heap
        addq 16(%rbx), %rcx                 # Add the size of the block to the top of the heap
        cmpq %rax, %rcx                     # IF the top of the heap is equal to the initial top of the heap
        je check_dirtybit                    # THEN goto end_fuse_left;
        addq 16(%rbx), %rbx                 # Add the size of the block to the top of the heap
        jmp busca_vizinho

    check_dirtybit: 
        # Check if the left neighbor is free
        cmpq $0, 8(%rbx)                    # IF the dirty bit of the left neighbor is 0
        jne  end_fuse_left                    # THEN goto fuse_left;

    # Fuse the left neighbor
    movq 16(%rax), %rcx
    addq %rcx, 16(%rbx)

    cmpq %rax, TOP_LK
    je end_fuse_left
    end_fuse_left:
    cmpq %rax, INITIAL_LK
    je end_fuse_right
    # Check if the right neighbor is free
    movq %rax, %rbx
    addq 16(%rax), %rbx
    cmpq $0, 8(%rbx)                    # IF the dirty bit of the right neighbor is 0
    jne  end_fuse_right                    # THEN goto fuse_right;

    # Fuse the right neighbor
    movq 16(%rbx), %rcx
    addq %rcx, 16(%rax)

    end_fuse_right:
    pop %rbp
    ret


.globl foo
.type foo, @function
foo:
    # Prints hello world
    pushq %rbp
    movq %rsp, %rbp

    # movq $1, %rdi
    # movq $1, %rax
    # movq $hello, %rsi
    # movq $12, %rdx
    # syscall

    # prints rdi in the sdout 
    movq $1, %rdi
    leaq format(%rip), %rsi
    movq $3, %rdx
    movq $1, %rax           # Get the top of the heap
    movq INITIAL_LK, %rbx               # Get the initial top of the heap

    syscall

    pop %rbp
    ret
    
.globl imprimeMapa
.type imprimeMapa, @function
imprimeMapa:
    # Prints the map of the heap
    pushq %rbp
    movq %rsp, %rbp


    movq INITIAL_LK, %rbx               # Get the initial top of the heap

    imprimeLoop:
        movq TOP_LK, %rax                   # Get the top of the heap
        cmpq %rbx, %rax                     # IF the top of the heap is equal to the initial top of the heap
        je fim_imprimeLoop                  # THEN goto fim_imprimeLoop;

        # Prints the gerencial bits
        movq $1, %rdi
        movq $1, %rax
        leaq gerencial_bits(%rip), %rsi
        movq $16, %rdx
        syscall

        # Sets the counter to 0
        movq $0, I

        # Get the size of the block
        movq 16(%rbx), %rcx

        # Check if the block is occupied
        cmpq $0, 8(%rbx)                    # IF the dirty bit of the block is 0
        je block_free                       # THEN goto block_free;

        # TODO: Print the block as occupied
        block_occupied:
            



        block_free:
        # TODO: Print the block as free






    fim_imprimeLoop:

    pop %rbp
    ret


