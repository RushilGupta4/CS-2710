        .data
prompt:         .asciiz "Enter an integer N: "
result_msg:     .asciiz "The 2's compliment Hex of N is: 0x"
err_msg:        .asciiz "Invalid input\n"
hex_lookup:     .ascii  "0123456789ABCDEF"
buffer:         .space  32

        .text
        .globl main

main:
    li      $v0, 4             # syscall: print string
    la      $a0, prompt
    syscall

    # Read the input
    li      $v0, 8             # syscall: read string
    la      $a0, buffer
    li      $a1, 32
    syscall

    la      $t0, buffer        # start of input string
    li      $t1, 0             # integer value accumulator
    li      $t2, 1             # default sign is +1 (positive)

    # Loading some constants
    lb      $t3, 0($t0)        # current character from buffer
    li      $s0, 45
    li      $s1, 48            
    li      $s2, 57            
    li      $s3, 10
    li      $s4, 214748364     # limit to check overflow

    # Check if first character is '-'. If so, set sign = -1
    seq     $t2, $t3, $s0
    sub     $t2, $zero, $t2
    ori     $t2, $t2, 1

    # If $t2 < 0, we skip the sign character.
    # If $t2 > 0, we jump to digit conversion.
    blt     $t2, $zero, skip_sign
    bgt     $t2, $zero, convert_digit


skip_sign:
    addi    $t0, $t0, 1        # move pointer to next char

convert_digit:
    lb      $t3, 0($t0)

    # If we reach end of string, jump to hex printing.
    beq     $t3, $zero, start_hex

    beq     $t3, $s3, skip_sign

    # Check if character is digit (between '0' and '9');
    # otherwise, go to error.
    blt     $t3, $s1, error
    bgt     $t3, $s2, error

    # Convert ASCII digit to integer value
    addi    $t3, $t3, -48

    bgt     $t1, $s4, error
    beq     $t1, $s4, check_last_digit
    j       add_digit


check_last_digit:
    # maximum last digit for 214748364<?>
    li      $t4, 7
    slt     $t5, $t2, $zero
    add     $t4, $t4, $t5

    bgt     $t3, $t4, error

add_digit:
    mul     $t1, $t1, $s3
    addu    $t1, $t1, $t3
    addi    $t0, $t0, 1
    j       convert_digit

start_hex:
    mul     $t1, $t1, $t2
    move    $t2, $t1

    li   $v0, 4             # hex conversion start (0x prefix)
    la   $a0, result_msg
    syscall

    li   $t0, 8              # set count: 8 hex digits to print
    li   $t1, 28             # start shifting at bit position 28

hex_loop:
    srl     $t3, $t2, $t1
    andi    $t3, $t3, 0xF
    la      $t4, hex_lookup
    add     $t3, $t4, $t3
    lbu     $t5, 0($t3)
    move    $a0, $t5
    li      $v0, 11
    syscall

    addi    $t0, $t0, -1
    addi    $t1, $t1, -4
    bgt     $t0, $zero, hex_loop

    j    exit_program

error:
    li      $v0, 4
    la      $a0, err_msg
    syscall
    j       exit_program

exit_program:
    li      $v0, 10
    syscall