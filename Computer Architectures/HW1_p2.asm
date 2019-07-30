	.text
main :
	la $s0, x			# get base address of x
	la $s1, y			# get base address of y
	
	lw $t0, 12($s0)		# get data from memory of x[3]
	lw $t1, 16($s0) 	# get data from memory of x[4]
	
	add $t2, $t0, $t1	
	
	sw $t2, 8($s1)		# store result to y[2]
	li $v0, 10			# exit program
syscall


	.data
x : .word 5, 1, 17, -4, 6, 3
y : .word 0, 0,  0,  0, 0, 0
