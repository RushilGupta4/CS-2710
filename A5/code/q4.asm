.data
prompt: .asciiz "Enter a number: "
newline: .asciiz "\n"
bufferA: .space 33
bufferB: .space 33
intBuffer:  .space 16         # Buffer to hold the integer part (in ASCII)
zeroStr:    .asciiz "0"        # For printing a simple "0" when needed
dotStr:     .asciiz "."        # Decimal point
.text
.globl main

main:
    # Print prompt message
    li $v0, 4
    la $a0, prompt
    syscall

    # Read string input into buffer (A)
    li $v0, 8
    la $a0, bufferA
    li $a1, 33
    syscall

    # Print newline
    li $v0, 4
    la $a0, newline
    syscall

    # # Print prompt message
    # li $v0, 4
    # la $a0, prompt
    # syscall

    # # Read string input into buffer (B)
    # li $v0, 8
    # la $a0, bufferB
    # li $a1, 33
    # syscall

    # # Print newline
    # li $v0, 4
    # la $a0, newline
    # syscall

    # Convert bufferA to binary
    la $a0, bufferA
    jal convert_string_to_binary
    move $t0, $v0

    # # Convert bufferB to binary
    # la $a0, bufferB
    # jal convert_string_to_binary
    # move $t1, $v0

    move $a0, $t0
    jal get_mantissa
    move $t1, $v0

    move $a0, $t0
    jal get_exponent
    move $t2, $v0

    move $a0, $t1
    move $a1, $t2
    jal convert_to_decimal

    # Print the result
    li $v0, 1
    move $a0, $t1
    syscall

    # # Print the result
    # li $v0, 1
    # move $a0, $t1
    # syscall

    # Exit the program
    li $v0, 10
    syscall

# We want to convert the string in $a0
# the strings are in the format of "01010101", 32 characters long
# we want to convert each character to a binary number
# and store the result in $v0
convert_string_to_binary:
    li   $v0, 0        
    li   $t0, 32        
    li   $t4, 10
    li   $t5, 0

loop_string_to_binary:
    lb   $t1, 0($a0)
    beq  $t1, $t4, skip  # newline
    beq  $t1, $t5, skip  # null
    sll  $v0, $v0, 1    
    li   $t2, 48        
    sub  $t3, $t1, $t2  # Compute bit value: ('0' -> 0, '1' -> 1)
    addu $v0, $v0, $t3
skip:
    addi $a0, $a0, 1    
    addi $t0, $t0, -1   
    bgtz $t0, loop_string_to_binary
    jr   $ra

get_exponent:
    move $v0, $a0
    sll $v0, $v0, 1
    srl $v0, $v0, 24
    jr $ra
    
get_mantissa:
    move $v0, $a0
    sll $v0, $v0, 9
    srl $v0, $v0, 9
    jr $ra


convert_to_decimal:
    addiu $sp, $sp, -1024       # Allocate space for buffer and saved registers
    sw $ra, 1020($sp)
    sw $s0, 1016($sp)
    sw $s1, 1012($sp)
    sw $s2, 1008($sp)
    sw $s3, 1004($sp)
    sw $s4, 1000($sp)

    # Step 1: Extract mantissa (M) from $a0 (lower 23 bits)
    andi $s0, $a0, 0x007FFFFF   # $s0 = M

    # Step 2: Determine if denormalized (exponent == 0)
    move $s1, $a1               # $s1 = stored exponent
    beqz $s1, denormal

normal_case:
    # Calculate significand S = 1 << 23 + M
    li $s2, 1
    sll $s2, $s2, 23           # $s2 = 0x800000
    addu $s2, $s2, $s0          # $s2 = S
    # Calculate actual exponent E' = stored_exp + 127 - 23 = stored_exp + 104
    addiu $s3, $s1, 104         # $s3 = E'
    j convert_significand

denormal:
    # For denormal: S = M, E' = 1 - (-127) - 23 = 105
    move $s2, $s0               # S = M
    li $s3, 105                # E' = 105

convert_significand:
    # Convert integer S ($s2) to decimal string
    move $a0, $s2
    jal integer_to_decimal
    move $s4, $v0              # $s4 = address of string

    # Multiply by 2^E' (s3 times)
    move $a0, $s4
    move $a1, $s3
    jal multiply_power_of_two

    # Print the resulting string
    move $a0, $v0
    li $v0, 4
    syscall

    # Restore registers and return
    lw $s4, 1000($sp)
    lw $s3, 1004($sp)
    lw $s2, 1008($sp)
    lw $s1, 1012($sp)
    lw $s0, 1016($sp)
    lw $ra, 1020($sp)
    addiu $sp, $sp, 1024
    jr $ra

# Subroutine: Convert integer to decimal string
# Input: $a0 = integer
# Output: $v0 = address of null-terminated string (in buffer)
integer_to_decimal:
    addiu $sp, $sp, -32
    sw $ra, 28($sp)
    sw $s0, 24($sp)
    sw $s1, 20($sp)

    move $s0, $a0              # $s0 = number
    la $s1, 8($sp)             # Buffer in stack

    # Handle zero case
    bnez $s0, convert_loop
    li $t0, '0'
    sb $t0, 0($s1)
    sb $zero, 1($s1)
    la $v0, 8($sp)
    j convert_done

convert_loop:
    # Divide by 10 to get digits
    li $t0, 10
    divu $s0, $t0             # HI = remainder, LO = quotient
    mfhi $t1                  # $t1 = digit
    mflo $s0                  # $s0 = quotient
    addiu $t1, $t1, '0'       # Convert to ASCII
    sb $t1, 0($s1)
    addiu $s1, $s1, 1
    bnez $s0, convert_loop

    # Null-terminate and reverse
    sb $zero, 0($s1)
    la $a0, 8($sp)
    move $a1, $s1
    jal reverse_string

    la $v0, 8($sp)
convert_done:
    lw $s1, 20($sp)
    lw $s0, 24($sp)
    lw $ra, 28($sp)
    addiu $sp, $sp, 32
    jr $ra

# Subroutine: Reverse string in-place
# Inputs: $a0 = start address, $a1 = end address (exclusive)
reverse_string:
    addiu $a1, $a1, -1        # Point to last character
reverse_loop:
    bge $a0, $a1, reverse_end
    lb $t0, 0($a0)
    lb $t1, 0($a1)
    sb $t1, 0($a0)
    sb $t0, 0($a1)
    addiu $a0, $a0, 1
    addiu $a1, $a1, -1
    j reverse_loop
reverse_end:
    jr $ra

# Subroutine: Multiply decimal string by 2^N
# Inputs: $a0 = string address, $a1 = exponent (N)
multiply_power_of_two:
    addiu $sp, $sp, -32
    sw $ra, 28($sp)
    sw $s0, 24($sp)
    sw $s1, 20($sp)
    sw $s2, 16($sp)

    move $s0, $a0              # $s0 = string
    move $s1, $a1              # $s1 = remaining multiplications

mult_loop:
    beqz $s1, mult_end
    jal multiply_by_two
    addiu $s1, $s1, -1
    j mult_loop

mult_end:
    move $v0, $s0
    lw $s2, 16($sp)
    lw $s1, 20($sp)
    lw $s0, 24($sp)
    lw $ra, 28($sp)
    addiu $sp, $sp, 32
    jr $ra

# Subroutine: Multiply decimal string by 2
multiply_by_two:
    addiu $sp, $sp, -32
    sw $ra, 28($sp)
    sw $s0, 24($sp)
    sw $s1, 20($sp)
    sw $s2, 16($sp)

    move $s0, $a0              # $s0 = string
    li $s1, 0                  # Carry
    move $s2, $s0              # Current position

find_end:
    lb $t0, 0($s2)
    beqz $t0, end_found
    addiu $s2, $s2, 1
    j find_end

end_found:
    addiu $s2, $s2, -1         # Last character before null

process_digits:
    blt $s2, $s0, handle_carry
    lb $t0, 0($s2)
    addiu $t0, $t0, -'0'       # Convert to digit
    sll $t1, $t0, 1            # Multiply by 2
    add $t1, $t1, $s1          # Add carry
    li $t2, 10
    divu $t1, $t2              # HI = remainder, LO = carry
    mfhi $t3
    mflo $s1
    addiu $t3, $t3, '0'        # Back to ASCII
    sb $t3, 0($s2)
    addiu $s2, $s2, -1
    j process_digits

handle_carry:
    beqz $s1, no_carry
    # Shift string right and add carry
    move $t0, $s0
shift_loop:
    lb $t1, 0($t0)
    beqz $t1, shift_done
    addiu $t0, $t0, 1
    j shift_loop
shift_done:
    addiu $t0, $t0, 1          # New end
shift_back:
    beq $t0, $s0, shift_finish
    lb $t1, -1($t0)
    sb $t1, 0($t0)
    addiu $t0, $t0, -1
    j shift_back
shift_finish:
    addiu $s1, $s1, '0'
    sb $s1, 0($s0)
no_carry:
    lw $s2, 16($sp)
    lw $s1, 20($sp)
    lw $s0, 24($sp)
    lw $ra, 28($sp)
    addiu $sp, $sp, 32
    jr $ra
