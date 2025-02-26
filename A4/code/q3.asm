.data
promptFib:  .asciiz "Enter a positive integer (>= 2) for Fibonacci: "
fibStr:     .asciiz "The Fibonacci number is: "
errorStr:  .asciiz "Please enter a number >= 2"

.text
.globl main

main:
    li   $v0, 4
    la   $a0, promptFib
    syscall

    li   $v0, 5
    syscall
    move $t0, $v0      # N
    
    blt $t0, 2, fib_error # If N < 2, then we print an error message
    # Although the assignment says check for N < 0, we asked for N >= 2

    li   $t1, 0        # f0
    li   $t2, 1        # f1
    li   $t3, 3        # counter

fib_loop:
    bgt  $t3, $t0, fib_done # i > N => done
    add  $t4, $t1, $t2  # f2 = f0 + f1
    move $t1, $t2      # f0 = f1
    move $t2, $t4      # f1 = f2
    addi $t3, $t3, 1   # i = i + 1
    j    fib_loop

fib_error:
    li   $v0, 4
    la   $a0, errorStr
    syscall

    li  $v0, 10
    syscall

fib_done:
    li   $v0, 4
    la   $a0, fibStr
    syscall

    li   $v0, 1
    move $a0, $t2
    syscall