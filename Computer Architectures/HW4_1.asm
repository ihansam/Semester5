.text
.globl main

# notation
# s0: n, s1: address array[0] s2:array[j]
# s3: array[indexMin], s4: temp, s5: n-1
# t8:array[i], t9: address array[i]
# t0: i, t1: indexMin, t2: j
# t3: address array[j], t4: address array[indexMin]
# t5: branch condition

main :
	li $s0, 20				# n = 20
	addi $s5, $s0, -1		# n-1 = 19
	la $s1, n1				# address of array[0]
	li $t0, 0				# i = 0
	
L1:							# Outer for loop
	add $t1, $t0, $zero		# indexMin = i
	addi $t2, $t0, 1		# j = i + 1

L2 : 						# Inner for loop
	sll $t3, $t2, 2			# offset 4j
	add $t3, $t3, $s1		# address of array[j]
	lw $s2, 0($t3)			# load array[j]

	sll $t4, $t1, 2			# offset 4indexMin
	add $t4, $t4, $s1		# address of array[indexMin]
	lw $s3, 0($t4)			# load array[indexMin]

	slt $t5, $s2, $s3		# if array[j] < array[indexMin]
	beq $t5, $zero, JIN		# (if not, skip below instruction)		
	add $t1, $zero, $t2		# indexMin = j

JIN :		
	addi $t2, $t2, 1		# j ++
	slt $t5, $t2, $s0		# if j < n
	bne $t5, $zero, L2		# go to inner loop

SWAP :
	sll $t9, $t0, 2			# offset 4i
	add $t9, $t9, $s1		# address of array[i]
	lw $t8, 0($t9)			# array[i]

	sll $t4, $t1, 2			# offset 4indexMin
	add $t4, $t4, $s1		# address of array[indexMin]
	lw $s3, 0($t4)			# load array[indexMin] -> index min 값을 다시 불러와야 함
	
	add $s4, $s3, $zero		# temp = array[indexMin]
	sw $t8, 0($t4)			# a[indexMin] = array[i]
	sw $s4, 0($t9)			# array[i] = temp
	
JOUT : 
	addi $t0, $t0, 1		# i ++	
	slt $t5, $t0, $s5		# if i < n-1
	bne $t5, $zero, L1		# go to inner loop
	li		$v0, 10	
	syscall
	

		.data
n1 : 	.word 43;
n2 : 	.word 21;
n3 : 	.word 34;
n4 : 	.word 54;
n5 : 	.word 23;
n6 : 	.word 12;
n7 : 	.word 45;
n8 : 	.word 65;
n9 : 	.word 74;
n10 : 	.word 72;
n11 : 	.word 22;
n12 : 	.word 3;
n13 : 	.word 93;
n14 : 	.word 3;
n15 : 	.word 6;
n16 : 	.word 13;
n17 : 	.word 52;
n18 : 	.word 61;
n19 : 	.word 27;
n20 : 	.word 37;