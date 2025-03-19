.data
array:    .space 64 # Reserve space for 16 integers (16 x 4 bytes)
newline:  .asciiz "\n"
space:    .asciiz " "
prompt1:  .asciiz "Enter number: "
prompt2:  .asciiz "Target: "

.text
.globl main

main:
    li $t0, 0  # Outer index i = 0
    la $t1, array

read_loop:
    bge $t0, 16, ask_target
    li $v0, 4
    la $a0, prompt1
    syscall

    li $v0, 5
    syscall

    sll $t2, $t0, 2
    add $t9, $t1, $t2
    sw $v0, 0($t9)

    addi $t0, $t0, 1
    j read_loop

ask_target:
    li $v0, 4
    la $a0, prompt2
    syscall

    li $v0, 5
    syscall
    move $s0, $v0

    li $t0, 0 # Outer index i = 0

outer_loop:
    bge $t0, 16, exit_program # If i >= 16, then exit program

    sll $t2, $t0, 2
    add $t9, $t1, $t2 # Address of element in index i
    lw $t4, 0($t9) # Load element

    addi $t8, $t0, 1 # Inner index j = i + 1

inner_loop:
    bge $t8, 16, next_outer # If j >= 16, then go to next outer loop

    sll $t2, $t8, 2
    add $t9, $t1, $t2 # Address of element in index j
    lw $t5, 0($t9) # Load element

    add $t7, $t4, $t5 # Sum of elements in index i and j
    beq $t7, $s0, print_pair # If sum = target, then print pair

    addi $t8, $t8, 1 # Increment inner index
    j inner_loop

print_pair:
    li $v0, 1
    move $a0, $t4
    syscall

    li $v0, 4
    la $a0, space
    syscall

    li $v0, 1
    move $a0, $t5
    syscall

    li $v0, 4
    la $a0, newline
    syscall

next_outer:
    addi $t0, $t0, 1 # Increment outer index
    j outer_loop # Jump

exit_program:
    li $v0, 10
    syscall