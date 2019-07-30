	.text
main :
	# set coefficeints
	li $s0, 3	# e = 3
	li $s1, 2	# f = 2	
	li $s2, 5	# g = 5
	li $s3, 1	# h = 1
	
	# Evaluate polynominal
	sub $t0, $s0, $s1	#
	sub $t1, $s2, $s3	#
	add $s4, $t0, $t1	# save 'y' in register s4
	
	li $v0, 10	# exit program
	
syscall