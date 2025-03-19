.data
array:    .space 48 # Reserve space for 12 integers (12 * 4 bytes)
prompt:   .asciiz "Enter number: "
newline:  .asciiz "\n"

.text
.globl main

main:
    li $t0, 0
    la $t1, array

input_loop:
    bge $t0, 12, start_sort

    li $v0, 4
    la $a0, prompt
    syscall

    li $v0, 5
    syscall
    move $t2, $v0

    sll $t3, $t0, 2
    add $t4, $t1, $t3
    sw $t2, 0($t4)

    addi $t0, $t0, 1
    j input_loop

start_sort:
    li $t0, 1 # Outer loop index
    la $t1, array # Array address

sort_outer:
    bge $t0, 12, print_array # If outer loop index >= 12, then print array

    sll $t2, $t0, 2
    add $t3, $t1, $t2 # Address of key
    lw $t4, 0($t3) # Load key into $t4
    move $t5, $t0 # Inner loop index

sort_inner:
    addi $t5, $t5, -1 # Decrement inner loop index
    blt $t5, $zero, insert_key # If inner loop index < 0, then insert key

    sll $t6, $t5, 2
    add $t7, $t1, $t6  # Address of element to compare
    lw $t8, 0($t7) # Load element
    bgt $t8, $t4, shift_element # If element > key, shift it
    j insert_key # Otherwise, insert key into $t5 + 1

shift_element:
    addi $t9, $t5, 1 # New index of element
    sll $t9, $t9, 2
    add $t9, $t1, $t9 # Address of new index
    sw $t8, 0($t9) # Shift element to new index
    j sort_inner

insert_key:
    addi $t5, $t5, 1 # Store key in $t5 + 1
    sll $t6, $t5, 2
    add $t6, $t1, $t6 # Address of key position
    sw $t4, 0($t6) # Insert key into correct position
    addi $t0, $t0, 1 # Increment outer loop index
    j sort_outer

print_array:
    li $t0, 0
    la $t1, array

print_loop:
    bge $t0, 12, exit_program

    sll $t2, $t0, 2
    add $t3, $t1, $t2
    lw $t4, 0($t3)
    li $v0, 1
    move $a0, $t4
    syscall

    li $v0, 4
    la $a0, newline
    syscall

    addi $t0, $t0, 1
    j print_loop

exit_program:
    li $v0, 10
    syscall