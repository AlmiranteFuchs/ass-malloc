.section .data
    I: .quad 0
    topoInicialHeap: .quad 0
    str: .string "TESTE"
.section .text
.global _start

iniciaAlocador:
    # Requests the top of the heap, (brk), saves in the global variable topoInicialHeap
    pushq %rbp
    movq %rsp, %rbp       
    cmpq $0, topoInicialHeap            # IF brk was not set
    jne fim_inicia                      # THEN goto finalizaAlocador;

    # get the top of the heap
    movq $12, %rax                      # %rax = 12;
    syscall 
    movq %rax, topoInicialHeap          # topoInicialHeap = %rax;

    fim_inicia:
    pop %rbp
    ret

_start:
    call iniciaAlocador
    movq $60, %rax
    movq topoInicialHeap, %rdi
    syscall
