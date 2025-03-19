.data
prompt: .asciiz "Enter s (s mod 9 != 0): "
resultStr: .asciiz "s div 9 = "

.text
.globl main

main:
    # Print prompt message
    li $v0, 4
    la $a0, prompt
    syscall

    # Read integer input into register $t0 (s)
    li $v0, 5
    syscall
    move $t0, $v0

    # Initialize result as 0
    li $t1, 0


sub_loop:
    slti $t2, $t0, 9
    bne $t2, $zero, sub_done
    addi $t0, $t0, -9
    addi $t1, $t1, 1
    j sub_loop

sub_done:
    # Print result message
    li $v0, 4
    la $a0, resultStr
    syscall

    # Print result
    li $v0, 1
    move $a0, $t1
    syscall

    # Exit program
    li $v0, 10
    syscall