	.text
main :
	#set coefficients
	li $s0, 3	# 1st coeff is 3
	li $s1, -4	# 2nd coeff is -4
	
	lw $s3, Val_x	#Load X value
	
	#Evaluate polymomial
	mult $s3, $s3	# LO = x^2
	mflo $t0		# $t0 = x^2 = 9
	mult $s0, $t0	# LO = 3*x^2
	mflo $t0		# $t0 = 3*x^2 = 27
	mult $s1, $s3	# LO = -4*x
	mflo $t1		# $t1 = -4*x = -12
	add  $s4, $t0, $t1	# $s4 = 3*x^2 - 4*x = 15
	addi $s4, $s4, 1	# $s4 = 3*x^2 - 4*x + 1 = 16
		
	li $v0, 10	#exit program
	
syscall

	.data
Val_x : .word	3