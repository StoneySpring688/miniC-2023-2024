	.data
_a:
	 .word 0
_b:
	 .word 0
_c:
	 .word 0
_d:
	 .word 0
$str1:
	 .asciiz "hola\n"
$str2:
	 .asciiz "Inicio del programa\n"

	.text
	.globl main
main:
	li $t0, 1
	sw $t0, _a
	lw $t0, _a
	li $t1, 6
	mul $t0, $t0, $t1
	li $t1, 3
	div $t0, $t0, $t1
	sw $t0, _b
	li $t0, 5
	li $t1, 2
	lw $t2, _b
	lw $t3, _a
	sub $t2, $t2, $t3
	mul $t1, $t1, $t2
	add $t0, $t0, $t1
	sw $t0, _d
$l1 :
	lw $t0, _a
	beqz $t0, $l2
	li $v0, 4
	la $a0, $str1
	syscall 
	b $l1 
$l2 :
	li $v0, 4
	la $a0, $str2
	syscall 

	li $v0, 10
	syscall
