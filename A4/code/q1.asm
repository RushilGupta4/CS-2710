.data
prompt:      .asciiz "Enter a positive integer (<1000): "
resultStr:   .asciiz "The Sum (S) is equal to: "

.text
.globl main

main:
    # Print prompt message
    li   $v0, 4
    la   $a0, prompt
    syscall

    # Read integer input into register $t0 (N)
    li   $v0, 5 # We load into $v0 since it is a special register
    syscall
    move $t0, $v0      # $t0 holds N

    # Initialize sum = 0 and counter i = 1
    li   $t1, 0        # $t1 will hold the sum
    li   $t2, 1        # $t2 is our loop counter i

sum_loop:
    bgt  $t2, $t0, sum_done # If i = $t2 > $t1 = N, then we are done with the loop
    add  $t1, $t1, $t2
    addi $t2, $t2, 1
    j    sum_loop

sum_done:
    li   $v0, 4
    la   $a0, resultStr # Load the address of the result string
    syscall

    li   $v0, 1
    move $a0, $t1 # Load the sum into $a0
    syscall
