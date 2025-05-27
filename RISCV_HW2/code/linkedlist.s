.globl	__start

.rodata
        msg: .asciiz "Empty!"
        newline: .asciiz "\n"
.text

push_front_list:             
        ### if(list == NULL)return; ###
        beqz    a0, LBB0_2
        ### save ra、s0 ###
        addi    sp, sp, -16
        sw      ra, 12(sp)                      
        sw      s0, 8(sp)                       
        sw      s1, 4(sp)                       
        mv      s1, a1
        mv      s0, a0
        ### node_t *new_node = (node_t*)sbrk(sizeof(*new_node)); ###
        li      a0, 8
        call    sbrk
        ### new_node->value = value; ###
        sw      s1, 0(a0)
        ### new_node->next = list->head; ###
        lw      a1, 0(s0)
        sw      a1, 4(a0)
        ### list->head = new_node; ###
        sw      a0, 0(s0)
LBB0_2:
        ### exit handling ###
        lw      ra, 12(sp)                      
        lw      s0, 8(sp)                       
        lw      s1, 4(sp)                       
        addi    sp, sp, 16
        ret
        
print_list:
        beqz a0, done            # if a0 == NULL, return

        addi    sp, sp, -8      
        sw      a0, 0(sp)       # saves current node pointer
        sw      ra, 4(sp)

        lw      a0, 4(a0)       # a0 = node->next
        call    print_list

        lw      a0, 0(sp)       # restore current node
        lw      a0, 0(a0)       # load value
        call    print_int       # print it out

        lw      ra, 4(sp)
        addi    sp, sp, 8
done:
        ret
      
sort_list:
        addi    sp, sp, -16
        sw      ra, 12(sp)
        sw      s0, 8(sp)       # current node in unsorted list
        sw      s1, 4(sp)       # head in sorted list
        sw      s2, 0(sp)       # temp for next pointer

        # initialize loop
        mv      s0, a0          # set to head of unsorted list
        li      s1, 0           # head of sorted list set to NULL
sort_loop:
        beqz    s0, sort_done   # if nothing left in unsorted list then its done
        lw      s2, 4(s0)       # next = cur->next
        mv      a0, s1
        mv      a1, s0
        call    insert_sorted   # inserts a1 node into a0 list
        mv      s1, a0          # update sorted head
        mv      s0, s2          # next node!
        j     sort_loop         # no need to save ra since it's just continuing the loop
sort_done:
        mv      a0, s1          # sorted head returned in a0
        lw      ra, 12(sp)
        lw      s0, 8(sp)      
        lw      s1, 4(sp)       
        lw      s2, 0(sp)       
        addi    sp, sp, 16
        ret
insert_sorted:
        beqz    a0, insert_front
        lw      t0, 0(a1)
        lw      t1, 0(a0)
        blt     t0, t1, insert_front    # if insert node < head, sort in front
        mv      t2, a0                  # prev = a0
insert_loop:
        lw      t3, 4(t2)               # t3 = prev->next
        beqz    t3, insert_end          # if curr == NULL, insert_end
        lw      t1, 0(t3)
        blt     t0, t1, insert_end      # if insert node < curr 
        mv      t2, t3                  # prev = curr
        j       insert_loop
insert_front:
        sw      a0, 4(a1)               # node->next = head
        mv      a0, a1                  # update head
        ret
insert_end:
        lw      t3, 4(t2)               # t3 = prev->next
        sw      a1, 4(t2)               # prev->next = node
        sw      t3, 4(a1)               # node->next = t3
        ret     

__start:
        ### save ra、s0 ###                                   
        addi    sp, sp, -16
        sw      ra, 12(sp)                      
        sw      s0, 8(sp)                                            
        ### read the numbers of the linked list ###
        call    read_int
        ### if(nums == 0) output "Empty!" ###
        beqz    a0, LBB2_2
        ### if(nums <= 0) exit
        mv      s0, a0          # s0 saves the num of nodes
        blez    a0, exit
LBB2_1:                                
        call    read_int
        ### set push_front_list argument ###
        mv      a1, a0
        mv      a0, sp
        call    push_front_list
        addi    s0, s0, -1
        bnez    s0, LBB2_1
        lw      a0, 0(sp)       # a0 = head of linked list
        j       LBB2_3
LBB2_2:
        call    print_str       # print "Empty!"
        j       exit
LBB2_3:
        mv      s0, a0          # s0 = head of linked list
        call    print_list
        call    print_newline
        mv      a0, s0
        call    sort_list
        mv      s0, a0
        call    print_list
exit:   
        ### exit handling ###
        li      a0, 0
        lw      ra, 12(sp)                      
        lw      s0, 8(sp)                       
        addi    sp, sp, 16
	li a0,	10
	ecall

read_int:
	li	a0, 5
	ecall
	jr	ra

sbrk:
	mv	a1, a0
	li	a0, 9
	ecall
	jr	ra
 
print_int:
	mv 	a1, a0
	li	a0, 1
	ecall
	li	a0, 11
	li	a1, ' '
	ecall
	jr	ra

print_str:
        li      a0, 4
        la      a1, msg
        ecall
        jr      ra

print_newline:
        li      a0, 4
        la      a1, newline
        ecall
        jr      ra

