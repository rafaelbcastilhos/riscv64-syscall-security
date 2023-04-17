.option norvc

.section .text
.global machine_mode_trap_handler

machine_mode_trap_handler:
    csrw mip, zero
    csrr t0, mepc

    # Going to the next instruction
    addi t0, t0, 8

    csrw mepc, t0
    mret
    
.global supervisor_mode_trap_handler
.align 4

supervisor_mode_trap_handler:

    # Saving the registers

save_registers:

    addi sp, sp, -64

    sd ra, 8(sp)
    sd t0, 16(sp)
    sd t1, 24(sp)
    sd t2, 32(sp)
    sd t3, 40(sp)
    sd t4, 48(sp)
    sd a7, 56(sp)

verify_type:
    csrr t0, scause
    srli t1, t0, 31
    beqz t1, exception_handler

clean:
    csrw sip, zero
    csrr t0, sepc

    # We are adding 4, because the spec is pointing to ecall instruction
    addi t0, t0, 8

    csrw sepc, t0

load_registers:

    ld a7, 56(sp)
    ld t4, 48(sp)
    ld t3, 40(sp)
    ld t2, 32(sp)
    ld t1, 24(sp)
    ld t0, 16(sp)
    ld ra, 8(sp)

    addi sp, sp, 64

supervisor_comeback:
    sret
    
exception_handler:
    andi t2, t0, 0x3f
    addi t3, x0, 8
    beq t3, t2, syscall_handler
    j clean 

syscall_handler:
    beqz a7, syscall_print

    addi t4, x0, 1
    beq a7, t4, syscall_increment

    addi t4, x0, 2
    beq a7, t4, syscall_increment_list
    
    j clean

syscall_print:

    addi sp, sp, -16

    sd a0, 8(sp)

    call print

    ld a0, 8(sp)

    addi sp, sp, 16

    j clean

syscall_increment:
    call increment
    j clean

syscall_increment_list:
    # Save the current register state
    addi sp, sp, -24
    sd ra, 8(sp)
    sd s0, 16(sp)

    call increment_list

    # Restore the original register state and return from the system call
    ld ra, 16(sp)
    ld s0, 8(sp)
    addi sp, sp, 24
    
    j clean

.data
aqui: .ascii "aqui\n"
