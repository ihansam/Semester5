.text

main:

lw $t3, x		# get 'x' from merory
lw $a0, a		# get 'a' from merory
lw $a1, bb		# get 'bb' from merory
lw $a2, c		# get 'c' from merory
jal func		# fuction call		
sw $t5, value	# store result to value
li $v0, 10

syscall


func:
mult $t3, $t3		# x^2
mflo $t0			# $t0 = x^2 = 25
mult $a0, $t0		# a*x^2
mflo $t0			# $t0 = a*x^2 = 425
mult $a1, $t3		# bb*x
mflo $t1			# $t1 = bb*x = -20
add $t5, $t0, $t1	# $t5 = a*x^2 + bb*x = 405
add $t5, $t5, $a2	# $t5 = a*x^2 + bb*x + c = 411
jr $ra				# return to main


		.data
x:		.word 5
value:	.word 1
a:		.word 17
bb:		.word -4
c:		.word 6