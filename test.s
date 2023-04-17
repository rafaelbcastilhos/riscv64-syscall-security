.section .text
.global main
main:

    # Load the address of ponteiro_certo into register a0
    la a0, ponteiro_certo

    # Load the size of ponteiro_certo into register a1
    addi a1, x0, 25

    # Save Registers
    addi sp, sp, -8

    sd a0, 4(sp)

    call print #Ponteiro não malicioso

    # Restore Registers
    ld a0, 4(sp)

    addi sp, sp, 8

    # Load the address of the list into register a0 
    la a0, list

    # Load the size of the list into register a1
    addi a1, x0, 6

    # Save Registers
    addi sp, sp, -8

    sd a0, 4(sp)

    call print #1 2 3 4 5\n

    # Restore Registers
    ld a0, 4(sp)

    addi sp, sp, 8

    # Passing syscall 2: increment list
    addi a7, x0, 2
    ecall

    # Save Registers
    addi sp, sp, -8

    sd a0, 4(sp)

    call print

    # Restore Registers
    ld a0, 4(sp)

    addi sp, sp, 8

    # Load the address of ponteiro_errado into register a0
    la a0, ponteiro_errado

    # Load the size of ponteiro_errado into register a1
    addi a1, x0, 21

    # Save Registers
    addi sp, sp, -8

    sd a0, 4(sp)

    call print

    # Restore Registers
    ld a0, 4(sp)

    addi sp, sp, 8

    # Load a malicious pinter (tp value)
    ld a0, 0(x4)

    addi a1, x0, 20

    # Passing syscall 2: increment list
    addi a7, x0, 2
    ecall

    # Load a malicious pinter (tp value)
    ld a0, 0(x4)

    addi a1, x0, 1

    # Save Registers
    addi sp, sp, -8

    sd a0, 4(sp)

    call print

    # Restore Registers
    ld a0, 4(sp)

    addi sp, sp, 8



    ret


.data 
list: .ascii "12345\n"  # List of integers
ponteiro_certo: .ascii "Ponteiro não malicioso: \n"
ponteiro_errado: .ascii "Ponteiro malicioso: \n"
