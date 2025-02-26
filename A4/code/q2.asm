.data
promptA:    .asciiz "Enter the first positive integer: "
promptB:    .asciiz "Enter the second positive integer: "
error_msg:  .asciiz "Please enter a positive number"
gcdStr:     .asciiz "The GCD is: "

.text
main:
    # $v0 = 4 is for printing a string, here we ask the user for the first integer
    li   $v0, 4
    la   $a0, promptA
    syscall
    
    # $v0 = 5 is for reading an integer, here we read the first integer
    li   $v0, 5
    syscall
    move $t0, $v0      # A

    blez $t0, error    # If A <= 0, then we print an error message

    # Similar to the above, we ask the user for the second integer
    li   $v0, 4
    la   $a0, promptB
    syscall

    # Similar to the above, we read the second integer
    li   $v0, 5
    syscall
    move $t1, $v0      # B

    blez $t1, error    # If B <= 0, then we print an error message


gcd_loop:
    beq  $t0, $t1, gcd_done # If A = B, then we are done
    bgt  $t0, $t1, sub_A # If A > B, then we subtract B from A and go top of loop
    sub  $t1, $t1, $t0 # If B > A, then we subtract A from B
    j    gcd_loop

sub_A:
    sub  $t0, $t0, $t1
    j    gcd_loop


error:
    # Print the string "Please enter a positive number"
    li   $v0, 4
    la   $a0, error_msg
    syscall
    
    # Exit the program
    li  $v0, 10
    syscall

gcd_done:
    # Only here when A = B = gcd(A, B)

    # Print the string "The GCD is: "
    li   $v0, 4
    la   $a0, gcdStr
    syscall
    
    # Print the GCD
    li   $v0, 1
    move $a0, $t0
    syscall