	.data
_c:
	 .word 0
$str1:
	 .asciiz "c\n"

	.text
	.globl main
main:
	li $t0, 4
	sw $t0, _c
$l1 :
	li $v0, 4
	la $a0, $str1
	syscall 
	lw $t0, _c
	li $t1, 1
	sub $t0, $t0, $t1
	sw $t0, _c
	lw $t0, _c
	bnez $t0, $l1

	li $v0, 10
	syscall
