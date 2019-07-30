.text
.globl main

main :
	la $t0, n				# $t0 is address of n
	lw $s1, 0($t0)			# load n to $s1
	lw $s2, 4($t0)			# load i to $s2
	lw $s3, 8($t0)			# load fact to $s3
	j WL					# jump to while loop
	
L1:
	sw $s2, 4($t0)			# store calculated i
	sw $s3, 8($t0)			# store calculated fact
	syscall					# End Program

WL :						# While loop
	slt $t1, $s2, $s1		# if i < n then do not break
	beq $t1, $zero, L1		# else break while loop
	mul $s3, $s3, $s2		# fact = fact * i
	li $t2, 10000			
	bgt $s3, $t2, L1		# if fact > 10000 then break
	addi $s2, 1				# i++
	j WL					# go to while loop

		.data
n : 	.word 10;
i : 	.word 1;
fact : 	.word 1;