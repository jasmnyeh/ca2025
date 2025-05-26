.globl __start

.rodata
    division_by_zero: .string "division by zero"

.text
__start:
    # Registers:
    # s0 = Operand A
    # s1 = Operation
    # s2 = Operand B
    # s3 = Result
    
    # Read first operand
    li a0, 5
    ecall
    mv s0, a0
    # Read operation
    li a0, 5
    ecall
    mv s1, a0
    # Read second operand
    li a0, 5
    ecall
    mv s2, a0

    # Check operation and jump to the corresponding function
    beq s1, zero, addition
    li t0, 1
    beq s1, t0, subtraction
    li t0, 2
    beq s1, t0, multiplication
    li t0, 3
    beq s1, t0, intdivision
    li t0, 4
    beq s1, t0, minimum
    li t0, 5
    beq s1, t0, power
    li t0, 6
    beq s1, t0, factorial
    
addition:
    add s3, s0, s2
    jal zero, output

subtraction:
    sub s3, s0, s2
    jal zero, output

multiplication:
    mul s3, s0, s2
    jal zero, output

intdivision:
    # check if s2 == 0
    beqz s2, division_by_zero_except
    div s3, s0, s2
    jal zero, output

minimum:
    bge s0, s2, min_set_s2
    mv s3, s0
    jal zero, output
min_set_s2:
    mv s3, s2
    jal zero, output

power:
    li s3, 1 # set s3 initially to 1
    li t1, 0 # t1 is the counter
pow_loop:
    beq t1, s2, pow_done
    mul s3, s3, s0
    addi t1, t1, 1
    jal zero, pow_loop
pow_done:
    jal zero, output

factorial:
    li s3, 1
    li t1, 1
    li t2, 0
fac_loop:
    beq t2, s0, fac_done
    mul s3, s3, t1
    addi t1, t1, 1
    addi t2, t2, 1
    jal zero, fac_loop
fac_done:
    jal zero, output


output:
    # Output the result
    li a0, 1 # a0 = system call number
    mv a1, s3 # a1 = int to print
    ecall

exit:
    # Exit program(necessary)
    li a0, 10 # set syscall to exit
    ecall

division_by_zero_except:
    li a0, 4 # set syscall for printing a string
    la a1, division_by_zero
    ecall
    jal zero, exit
