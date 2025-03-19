.data
buffer:    .space 33               # Space for 32-bit binary string + null terminator
prompt:    .asciiz "Enter a 32-bit binary number (A): "
prompt2:   .asciiz "Enter a 32-bit binary number (B): "
newline:   .asciiz "\n"
dot:       .asciiz "."

.text
.globl main

#------------------------------------------------------------
# Function: convert
# Input:  $a0 = pointer to the binary string
# Output: $v0 = integer part, $v1 = fractional part
#------------------------------------------------------------
convert:
    # Save return address ($ra) on stack
    addi    $sp, $sp, -4
    sw      $ra, 0($sp)

    # Convert the binary string to a 32-bit integer
    li      $t0, 0       # Accumulator for binary value
    move    $t1, $a0     # Input string

conv_loop:
    lb      $t2, 0($t1)  # Load character

    # If newline or null terminator, done
    beq     $t2, 10, conv_done_loop
    beq     $t2, 0, conv_done_loop

    sll     $t0, $t0, 1  # Shift left for next bit
    li      $t3, '1'
    beq     $t2, $t3, conv_set_bit # Set bit if character is '1'
    j       conv_next_char

conv_set_bit:
    ori     $t0, $t0, 1  # Set LSB if character is '1'

conv_next_char:
    addi    $t1, $t1, 1  # Next character
    j       conv_loop

conv_done_loop:
    # At this point $t0 holds the 32-bit binary value
    
    # Extract exponent to $t4
    move    $t4, $t0
    sll     $t4, $t4, 1    # Discard sign bit
    srl     $t4, $t4, 24   # Discard mantissa bits
    addi    $t4, $t4, -127 # Unbias exponent.

    # Extract raw mantissa (removing sign and exponent) to $t5
    move    $t5, $t0
    sll     $t5, $t5, 9   # Discard sign and exponent bits
    srl     $t5, $t5, 9   # Move back to the right

    # Compute significand = (2^23 + mantissa) and store to $t5
    li      $t6, 1
    sll     $t6, $t6, 23  # $t6 = 2^23
    add     $t5, $t5, $t6 # $t5 = significand (with implicit 1)

    # Compute divisor = 2^(23 - exponent) and store to $t6
    li      $t6, 1       # Reinitialize $t6.
    li      $t7, 23
    sub     $t7, $t7, $t4  # $t7 = 23 - exponent.
    sll     $t6, $t6, $t7  # $t6 = 2^(23 - exponent).

    # Divide significand by divisor
    div     $t5, $t6
    mflo    $t8        # $t8 = integer part (quotient)
    mfhi    $t9        # $t9 = remainder

    # Compute the fractional part
    li      $t7, 0     # Digit counter
    li      $t1, 0     # Fractional accumulator

conv_fraction_loop:
    addi    $t7, $t7, 1    # Increment digit counter
    mul     $t9, $t9, 10   # Multiply remainder by 10

    div     $t9, $t6
    mflo    $t2          # Next digit
    mfhi    $t9          # Update remainder

    mul     $t1, $t1, 10 # Shift accumulator
    add     $t1, $t1, $t2  # Add new digit
    bne     $t7, 7, conv_fraction_loop # Stop at 7 digits

    # Return: integer part in $v0, fractional part in $v1
    move    $v0, $t8
    move    $v1, $t1

    lw      $ra, 0($sp) # Restore return address
    addi    $sp, $sp, 4 # Restore stack pointer
    jr      $ra         # Return


main:
    li      $v0, 4
    la      $a0, prompt
    syscall

    li      $v0, 8
    la      $a0, buffer
    li      $a1, 33
    syscall

    # Call conversion function for first input
    la      $a0, buffer
    jal     convert

    # Save conversion results
    move    $t0, $v0   # Integer part of A
    move    $t1, $v1   # Fractional part of A

    li      $v0, 4
    la      $a0, newline
    syscall

    # Print first converted value: integer part . fractional part.
    li      $v0, 1
    move    $a0, $t0
    syscall

    li      $v0, 4
    la      $a0, dot
    syscall

    li      $v0, 1
    move    $a0, $t1
    syscall

    li      $v0, 4
    la      $a0, newline
    syscall

    li      $v0, 4
    la      $a0, prompt2
    syscall

    li      $v0, 8
    la      $a0, buffer
    li      $a1, 33
    syscall

    la      $a0, buffer
    jal     convert
    move    $t2, $v0   # Integer part of B
    move    $t3, $v1   # Fractional part of B

    li      $v0, 4
    la      $a0, newline
    syscall

    # Print second converted value: integer part . fractional part.
    li      $v0, 1
    move    $a0, $t2
    syscall

    li      $v0, 4
    la      $a0, dot
    syscall

    li      $v0, 1
    move    $a0, $t3
    syscall

    # End program
    li      $v0, 10
    syscall