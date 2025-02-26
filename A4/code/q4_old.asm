.data
prompt:  .asciiz "Enter an integer N: "
resultStr: .asciiz "The 32-bit 2's complement hexadecimal representation of N is: 0x"

.text
.globl main

main:
    li   $v0, 4
    la   $a0, prompt
    syscall

    li   $v0, 5
    syscall
    move $t0, $v0      # N
    
    
    # Sanity check: N should be representable in 32 bits
    # But note, that since N is read from syscall 5, 
    # it is already in the range of 32-bit signed integers
    # Otherwise, MIPS will give a out of bounds error

    # Conclusion: MIPS already has this worked out!
    li $v0, 34 # The syscall to output int as hex
    move $a0, $t0
    syscall

    li $v0, 10
    syscall
