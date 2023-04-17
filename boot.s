# boot.S
# bootloader for SoS
# Based on Stephen Marz
# Available at https://osblog.stephenmarz.com/

.option norvc
.section .text.init
.global _start
_start:
	csrr	t0, mhartid
	addi    tp, t0, 0
	# SATP should be zero, but let's make sure (no MMU)
	csrw	satp, zero
.option push
.option norelax
	la		gp, _global_pointer
.option pop
	# The BSS section is expected to be zero
	la 		a0, _bss_start
	la		a1, _bss_end

    # If _bss_start >= _bss_end, go to label 2
	bgeu	a0, a1, 2f
1:
    # Loop to clean the bss section
	sd		zero, (a0)

    # Going to the next byte
	addi	a0, a0, 8

    # If the actual bss address is less than _bss_end, do the loop again
	bltu	a0, a1, 1b
2:
    # Copy the address of _stack_end to stack pointer (sp)
	la		sp, _stack_end

	# Setting the mstatus register:
    # 0b01 << 11 : MPP = 01 (SUPERVISOR) => When we return with 'mret' the privilege mode will be SUPERVISOR
    # 1 << 7 : MPIE = 1 => When we return with 'mret' the MIE will receive the MPIE, setting the interrupts enable when starting the os_start
    # 0 << 3 : MIE = 0 => Because we don't any interruption while booting
	li		t0, (0b01 << 11) | (1 << 7) | (0 << 3)

    # Write the t0 value on mstatus
	csrw	mstatus, t0

	la		t1, os_start

    # Putting the address of os_start in mepc, which will cause the first instruction to be executed will be that after using mret
	csrw	mepc, t1

	la		t2, machine_mode_trap_handler

    # Setting the mtvec to our machine mode trap handler
	csrw	mtvec, t2

    # Setting the mie register:
    # 1 << 3 : MSIE = 1 => We will handle software interrupt : ecall
	li		t3, (1 << 3)
	csrw	mie, t3

    # Setting the medeleg register:
    # 1 << 8: Delegate the exception of user-mode environment call to supervisor-mode
    li t4, (1 << 8)
    csrw medeleg, t4
    
	# Set the retun address to infinitely wait for interrupts.
	la		ra, 3f

	mret
3:
    # Idle
	wfi
	j		3b

os_start:
    # setup for sstatus register
	# 1 << 1: SIE = 1
	# 1 << 5: SPIE = 1
	# 0b0 << 8: SPP = 0 (User-mode)
    li      t0, (1 << 1) | (1 << 5) | (0b0 << 8)
    csrw    sstatus, t0

    # turn on the interrupts for supervisor mode
    # 1 << 1: SSIE = 1 => Enabling software interrupt (bit 1)
    li      t0, (1 << 1)
    csrw    sie, t0

	# setting a handler to S-mode interrupts
    la      t0, supervisor_mode_trap_handler
    csrw    stvec, t0

    # Setting a next ret address to force configurations to be applied
    la t0, init_uart
    csrw sepc, t0
    sret

init_uart:
    li t0, 0x10000000
    # Setting the LCR[0:1] (Line Control Register) bits to '11' to set the word length to 8 bits
    # The LCR is UART_ADDRESS + 3
    li t1, 0x3
    sw t1, 3(t0)

    li t2, 0x1
    # Setting the FCR[0] (FIFO Control Register) bit to '1' to enable the FIFOs
    # The FCR is UART_ADDRESS + 2
    sw t2, 2(t0)

    # Setting the IER[0] (Interrupt Enable Register) to '1' to enable receiver interrupts
    # The IER is UART_ADDRESS + 1
    sw t2, 1(t0)

    j main
