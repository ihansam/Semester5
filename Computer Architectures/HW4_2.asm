# qs code
# pivot = a[start]
# i = start+1
# j = end
# while i<=j
	# while a[i]<pivot & i<=end i++
	# while a[j]>pivot & j>=start+1 j--
	# if i<=j swap a[i] a[j]
# if start < end
	# swap a[start], a[j]
	# qs(start, j-1)
	# qs(j+1, end)

	.data
a:	.word 43, 21, 34, 54, 23, 12, 45, 65, 74, 72, 22, 3, 93, 3, 6, 13, 52, 61, 27, 37	

	.text
.globl main

main:
	li $a0, 0			# a0: start
	li $a1, 19			# a1: end
	la $s0, a			# s0: address a[0]
	jal QS				# Fuction call
	li $v0, 10
	syscall
QS:
	addi $sp, $sp, -24
	sw $s1, 0($sp)	# pivot
	sw $s2, 4($sp)	# i
	sw $s3, 8($sp)	# j
	sw $a0, 12($sp)	# start
	sw $a1, 16($sp)	# end
	sw $ra, 20($sp)	# return address
	
	sll $t0, $a0, 2		# t0: 4*start
	add $t0, $t0, $s0	# t0: address a[start]
	lw $s1, 0($t0)		# s1: pivot = a[start]
	addi $s2, $a0, 1	# s2: i = start + 1
	add $s3, $a1, $zero	# s3: j = end

	L1:		# outer while loop
		slt $t8, $s3, $s2		# if j < i
		bne $t8, $zero, PS	# break

		Li:		# i++ loop
			sll $t1, $s2, 2		# t1: 4*i
			add $t1, $t1, $s0	# t1: address a[i]
			lw $s4, 0($t1)		# s4: a[i]
			slt $t8, $s1, $s4	# if pivot < a[i]
			bne $t8, $zero, Lj	# break
			slt $t8, $a1, $s2	# if end < i
			bne $t8, $zero, Lj	# break								
			addi $s2, $s2, 1	# else i++
			j Li				# and loop i agian

		Lj:		# j-- loop
			sll $t2, $s3, 2		# t2: 4*j
			add $t2, $t2, $s0	# t2: address a[j]
			lw $s5, 0($t2)		# s5: a[j]
			slt $t8, $s5, $s1	# if a[j] < pivot
			bne $t8, $zero, IJS	# break
			addi $t9, $a0, 1	
			slt $t8, $s3, $t9	# if j < start + 1
			bne $t8, $zero, IJS	# break	
			addi $s3, $s3, -1	# else j--
			j Lj				# and loop j agian

		IJS:	# i j swap
			slt $t8, $s3, $s2	# if j < i
			bne $t8, $zero, L1	# break. if not,
			sw $s4, 0($t2)		# a[j] = a[i]	# 주소와 값 모두 레지스터에 불러왔기 때문에
			sw $s5, 0($t1)		# a[i] = a[j]	# temp 변수를 통한 swap할 필요는 없음
			j L1				# and while loop again
			
	PS:		# pivot swap
		slt $t8, $a0, $a1		# if not start < end
		beq $t8, $zero, EQS		# end quick sort
		sw $s1, 0($t2)			# a[j] = a[start]
		sw $s5, 0($t0)			# a[start] = a[j]		
		
	RQS:	# recall quick sort
		
		addi $a0, $a0, 0		# start = start
		addi $a1, $s3, -1		# end = j-1
		jal QS
	
		lw $a0, 12($sp)	# start
		lw $a1, 16($sp)	# end
		lw $ra, 20($sp)	# return address
	
		addi $a0, $s3, 1		# start = j + 1
		addi $a1, $a1, 0		# end = end
		jal QS

		lw $a0, 12($sp)	# start
		lw $a1, 16($sp)	# end
		lw $ra, 20($sp)	# return address
		
		lw $s1, 0($sp)	# pivot
		lw $s2, 4($sp)	# i
		lw $s3, 8($sp)	# j
		
		addi $sp, $sp, 24
		jr $ra
		
	EQS:	# End Quick Sort!
		jr $ra
		