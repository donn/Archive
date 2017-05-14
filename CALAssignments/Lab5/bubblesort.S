main:
la $s0, 0
li $t0, 9
sw $t0, 0($s0)
li $t0, 5
sw $t0, 4($s0)
li $t0, 17
sw $t0, 8($s0)
li $t0, 6
sw $t0, 12($s0)
li $t0, 8
sw $t0, 16($s0)
li $t0, 2
sw $t0, 20($s0)
li $t0, 4
sw $t0, 24($s0)
li $t0, 39
sw $t0, 28($s0)
li $t0, 18
sw $t0, 32($s0)
li $t0, 3
sw $t0, 36($s0)
addiu $t0, $s0, 40

loop1:
beq $s0, $t0, exit1
lb $a0, 0($s0)
li $v0, 1
li $v0, 11
li $a0, 32
addiu $s0, $s0, 4
j loop1

exit1:
li $a0, 10
li $v0, 11
syscall 

la $a0, 0
li $a1, 10
jal bubblesort

la $s0, 0
addiu $t0, $s0, 40

loop2:
beq $s0, $t0, exit2
lb $a0, 0($s0)
li $v0, 1

li $v0, 11
li $a0, 32
syscall
addiu $s0, $s0, 4
j loop2

exit2:
li $v0, 10
syscall

bubblesort:
ble $a1, 0, return
li $v0, 11

li $s0, 0

addiu $t2, $a1, -1 #length - 1
bsloop:
beq $s0, $t2, bsexit

sll $t1, $s0, 2
addu $t0, $a0, $t1
lb $s1, 0($t0)
addiu $t0, $t0, 4
lb $s2, 0($t0)

ble $s1, $s2, endif
move $t1, $s2
move $s2, $s1
move $s1, $t1

sll $t1, $s0, 2
addu $t0, $a0, $t1
sb $s1, 0($t0)
addiu $t0, $t0, 4
sb $s2, 0($t0)
endif:

addiu $s0, $s0, 1
j bsloop

bsexit:
addiu $sp, $sp, -8
sw $ra, 0($sp)
sw $a1, 4($sp)
addiu $a1, $a1, -1
jal bubblesort
lw $a1, 4($sp)
lw $ra, 0($sp)
addiu $sp, $sp, 8

return:
jr $ra
