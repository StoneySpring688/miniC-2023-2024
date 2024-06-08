	.data
_c:
	 .word 0
_a:
	 .word 0
_b:
	 .word 0
$str1:
	 .asciiz "a"
$str2:
	 .asciiz "\n"
$str3:
	 .asciiz "No a y b\n"
$str4:
	 .asciiz "Fin del programa\n"

	.text
	.globl main
main:
	li $t0, 3
	sw $t0, _c
	li $t0, 0
	sw $t0, _a
	li $t0, 0
	sw $t0, _b
	lw $t0, _a
	beqz $t0, $l2
	li $v0, 4
	la $a0, $str1
	syscall 
	li $v0, 4
	la $a0, $str2
	syscall 
	b $l3 
$l2 :
	lw $t1, _b
	beqz $t1, $l1
	li $v0, 4
	la $a0, $str3
	syscall 
$l1 :
$l3 :
	li $v0, 4
	la $a0, $str4
	syscall 

	li $v0, 10
	syscall
