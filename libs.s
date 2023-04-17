.global increment

# FUNCTION INCREMENT
# ARGS:
# a0 : The value to increment
# RETURN:
# a0 : The incremented value

increment:
    addi a0, a0, 1
    ret

.global put_char

# FUNCTION PUT_CHAR
# a0 : the character to put in uart (8bits)
put_char:
    # Load the address of uart
    lui t0, 0x10000

    # Put in uart
    sd a0, 0(t0)

    ret

.global print

# FUNCTION PRINT
# a0 : the base address
# a1 : the size of string
print: 
    # Initialize the temporary with actual address
    add t0, x0, a0

    # Maintain the final address
    add t1, t0, a1
loop:
    # Load the character in actual address
    ld t2, 0(t0)
    
    # Exit if the r0 = address + size (no more chars to write on UART)
    beq t0, t1, exit

    # Calling convention
    addi sp, sp, -24


    sd ra, 8(sp)
    sd t0, 16(sp)

    # Pass the actual character as argument for put_char
    andi t3, t2, 0xff
    add a0, x0, t3

    # Call the put_char
    call put_char

    # Restore the registers after call put_char
    ld t0, 16(sp)
    ld ra, 8(sp)

    addi sp, sp, 24

    # Increment the actual address
    addi t0, t0, 1

    j loop
exit: 
    ret
    addi a0, a0, 1
    ret

.global increment_list

# FUNCTION INCREMENT_LIST
# a0 : the base address
# a1 : the size of the list

increment_list:
    # Load the value at the current element into register t0
    add t0, x0, a0

    # Maintain the final address
    add t1, t0, a1
loop2:
    # Load the character in actual address
    ld t2, 0(t0)

    # Exit if the r0 = address + size (no more chars to write on UART)
    beq t0, t1, return

    # Increment the value at the current element
    addi t2, t2, 1

    # Store the updated value back into the current element
    sd t2, 0(t0)

    # Move to the next element
    addi t0, t0, 1

    j loop2
return:
    ret
