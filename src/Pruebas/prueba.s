	.data
_a:
	 .word 0
_b:
	 .word 0
_c:
	 .word 0
$str1:
	 .asciiz "Inicio del programa\n"
$str2:
	 .asciiz "a"
$str3:
	 .asciiz "\n"
$str4:
	 .asciiz "c = "
$str5:
	 .asciiz "\n"
$str6:
	 .asciiz "Final"
$str7:
	 .asciiz "\n"

	.text
	.globl main
main:
	li $t0, 123
	sw $t0, _a
	li $t0, 0
	sw $t0, _b
	li $t0, 5
	li $t1, 2
	add $t0, $t0, $t1
	li $t1, 2
	sub $t0, $t0, $t1
	sw $t0, _c
	li $v0, 4
	la $a0, $str1
	syscall 
	lw $t0, _a
	beqz $t0, $l1
	li $v0, 4
	la $a0, $str2
	syscall 
	li $v0, 4
	la $a0, $str3
	syscall 
	b $l2 
$l1 :
	li $v0, 4
	la $a0, $str4
	syscall 
	lw $t1, _c
	li $v0, 1
	move $a0, $t1
	syscall 
	li $v0, 4
	la $a0, $str5
	syscall 
	lw $t1, _c
	li $t2, 2
	sub $t1, $t1, $t2
	li $t2, 1
	add $t1, $t1, $t2
	sw $t1, _c
$l2 :
	li $v0, 4
	la $a0, $str6
	syscall 
	li $v0, 4
	la $a0, $str7
	syscall 

	li $v0, 10
	syscall
