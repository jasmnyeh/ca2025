.text
.globl __start

__start:
    # read user input
    li a0, 5    # syscall 5 = read_int
    ecall   # stores input in a0

    # call function
    jal func

    # print_int
    mv a1, a0
    li a0, 1
    ecall

    # exit
    li a0, 10
    ecall

func:
    addi sp, sp, -12
    sw ra, 0(sp)    # save return address
    sw a0, 4(sp)    # save input n

    # base case: if n == 0 return 0, if n == 1 return 1
    li t1, 2
    blt a0, t1, base_case

    # first recursive call: T(n-1)
    addi a0, a0, -1
    jal func
    slli a0, a0, 1  # a0 = 2 * T(n-1)
    sw a0, 8(sp)

    # second recursive call: T(n-2)
    lw a0, 4(sp)
    addi a0, a0, -2
    jal func

    # calculate T(n)
    lw t0, 8(sp)
    add a0, t0, a0  # T(n) = 2 * T(n-1) + T(n-2)

    j end_func

base_case:
    beqz a0, return_zero    # if n == 0
    li a0, 1    # if n == 1
    j end_func

return_zero:
    li a0, 0

end_func:
    lw ra, 0(sp)
    addi sp, sp, 12
    jalr x0, 0(ra)