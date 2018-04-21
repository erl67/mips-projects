.data	#0x200 = 128 moves	use below buffer to loop the lights			
	#test: .word 1,2,4,8,1,2,4,8,1,2,4,8,1,2,4,8,1,2,4,8,1,2,4,8,1,2,4,8,1,2,4,8,1,2,4,8,1,2,4,8,1,2,4,8,1,2,4,8,1,2,4,8,1,2,4,8,1,2,4,8,1,2,4,8,1,2,4,8,1,2,4,8,1,2,4,8,1,2,4,8,1,2,4,8,1,2,4,8,1,2,4,8,1,2,4,8,1,2,4,8,1,2,4,8,1,2,4,8,1,2,4,8,1,2,4,8,1,2,4,8,1,2,4,8,1,2,4,8,1,2,4,8,1,2,4,8,1,2,4,8,1,2,4,8,1,2,4,8,1,2,4,8,1,2,4,8,1,2,4,8,1,2,4,8,1,2,4,8,1,2,4,8,1,2,4,8,1,2,4,8,1,2,4,8,1,2,4,8,1,2,4,8,1,2,4,8,1,2,4,8,1,2,4,8,1,2,4,8,1,2,4,8,1,2,4,8,1,2,4,8,1,2,4,8,1,2,4,8,1,2,4,8,1,2,4,8,1,2,4,8,1,2,4,8,1,2,4,8,1,2,4,8,1,2,4,8
	computer: .word 	#[1-blue,2-yellow,4-green,8-red] 
.text
	#add $t9, $zero, 0x10	#uncomment to start first game automatically
	add $t8, $zero, $zero	#enable start button
top:	
	add $s0, $zero, 0x0	#current length of game << 2, change if testing prebuilt buffer
	la $s1, computer	#address of game buffer
	add $s7, $zero, $zero	#success flag
	add $t9, $zero, $zero	#set $t9 = 0 to get input
start_loop: 
	bne $t9, 0x10, start_loop	#loop until start player one
	add $t8, $zero, 0x10		#start game 16d
	beq $t8, $zero, game
game:	
	add $a0, $zero, $s0	#set length of sequence to play and append to
	la $a1, 0($s1)
	jal playSequence
	add $s0, $zero, $v0	#updated game length usually $s0++, could make it harder though
	
	add $a0, $zero, $s0	#length of sequence to expect from user
	la $a1, 0($s1)		#previous moves that must be repeated by user
	jal userPlay
	add $s7, $zero, $v0	#success flag (0=fail)
	
	#uncomment below and bypass user function to loop forever randomly 
		#srl $t6, $s0, 2
		#addi $v0, $zero, 1 	#print int
		#add $a0, $zero, $t6
		#syscall
		#j game
		
	bne $s7, $zero, game	#continue if no errors, else clear and restart
	add $a0, $zero, $s0	#length of buffer to clear
	la $a1, 0($s1)		#address of buffer to clear
	jal _lose		#function to reset game and clear buffer
	add $s0, $zero, $v0	#set new size of buffer, should be 0
	
	j top
	j quit

# _userPlay
#
# Args:
#	- $a0: index of sequence on input
#	- $a1: input buffer address
# Return
#	- $v0: boolean of successful input (1=success,0=fail)	
userPlay:
	add $t0, $zero, $a0	#t0 set to length of inputs
	add $t1, $zero, $a1	# $1 set to game buffer
	add $t2, $zero, 0x0	#index for incrementing, starts at 0<<2
	add $t3, $zero, $zero	#hold character read from memory
	add $t4, $zero, $zero	#flag for bad input
	add $t7, $zero, $zero	#hold input
input_top:
	add $t9, $zero, $zero		#accept input
	beq $t8, $zero, input_loop	#check $t8 has cleared
input_loop: 
	beq $t9, $zero, input_loop	#loop until a button gets pressed	
	and $t7, $t9, 0xf		#set $t7 to input last 4 bits of button
	
	bne $t7, 0x1, u1		#this branch checks for valid input of the 4 buttons
	    j showinput
	u1:
	bne $t7, 0x2, u2
	    j showinput
	u2:
	bne $t7, 0x4, u4
	    j showinput
	u4:
	bne $t7, 0x8, input_top		#if not valid button data, try again
	u8:
	
	showinput:
	add $t8, $zero, $t7	#display color 	
	beq $t8, $zero, checknext
	
	checknext:
		lw $t3, 0($t1)		# Load the word
		beq $t3, $t7, match
		add $t4, $t4, 0x1	#remember bad input count
	    match:	
		add $t2, $t2, 0x4	#increment word index by 1<<2
		beq $t2, $t0, userdone	# check if finished looking through buffer (by length of words)
		add $t1, $t1, 0x4	# increment word store address 	 
	j input_top
userdone:	
	slti $v0, $t4, 1	#set return to 1, if no errors($t4)
	jr $ra	
	
	
# _playSequence
#
# Args:
#	- $a0: length of sequence previous to now
#	- $a1: input buffer address
# Return
#	- $v0: index of sequence on output
#	- $v1: return buffer address
playSequence:	
	addi $sp, $sp, -4	#adjust stack
	sw $ra, 0($sp)
	
	add $t0, $zero, $a0	#t0 set to length of inputs
	add $t1, $zero, $a1	#game buffer (word) address
	add $t2, $zero, $zero	#index for incrementing
	add $t3, $zero, $zero	#hold character
	
	beq $t0, $zero, playcolor	#first color if length of game is 0

	looknext:
		lw $t3, 0($t1)		# Load the character
		add $t8, $zero, $t3	#display color
		beq $t8, $zero, seqwait
		seqwait:
		beq $t2, $t0, playcolor	# if finished looking through buffer (next word would be 0)
		add $t1, $t1, 0x4	# increment word store 
		add $t2, $t2, 0x4	# increment index by 1<<2
		j looknext
			
	playcolor:
		addi $sp, $sp, -4	
		sw $t2, 0($sp)		#backup $t2, only thing required after call, even though callee uses nothing
	jal _rng
		lw $t2, 0($sp)
		addi $sp, $sp, 4	
	add $t5, $zero, $v0	#save RNG return value
	add $t8, $zero, $t5	#display color 	
	beq $t8, $zero, inc	#wait for t8 to clear
	
	inc:
	add $t2, $t2, 0x4	# increment word address by 1<<2
	sw $t5, 0($t1)		# save result

playdone:	
	lw $ra, 0($sp)
	addi $sp, $sp, 4	#adjust stack
	add $v0, $zero, $t2	#set length of game for return
	sub $v1, $t1, $t2	#set buffer address back to beginning to return
	jr $ra	

# _rng
#
# Args:
#	- none
# Return
#	- $v0 - value of color to play [1,2,4,8]
_rng:
	addi $v0, $zero, 30 # Syscall 30: System Time
	syscall

	add $t6, $zero, $a0	#store systime to $t6

	addi $v0, $zero, 40 # Syscall 40: Random seed
	add $a0, $zero, $zero # Set RNG ID to 0
	add $a1, $zero, $t6 # Set Random seed to systime($t6)
	syscall

	addi $v0, $zero, 42 # Syscall 42: Random int range
	add $a0, $zero, $zero # Set RNG ID to 0
	addi $a1, $zero, 4 # Set upper bound to 4 (exclusive)
	syscall # Generate a random number and put it in $a0
	
	bne $a0, $zero, one
	    add $v0, $zero, 0x1
	    j return
	one:
	bne $a0, 1, two
	    sll $v0, $a0, 1
	    j return
	two:
	bne $a0, 2, three
	    sll $v0, $a0, 1
	    j return
	three:
	    add $v0, $zero, 0x8
	return:
	jr $ra

# _lose
#
# Args:
#	- $a0: length of game sequence to erase
#	- $a1: buffer address
# Return
#	- $v0: new size of buffer (should be 0x0)
_lose:
	add $t2, $zero, $a0	#set index to clear in reverse
	add $t1, $zero, $a1	#game buffer (word) address
	add $t1, $t1, $t2	#clear buffer backwards to use less $t
	add $t6, $zero, 0x0	#word to overwrite with
	
	add $t8, $zero, 0xf	#play losing sound
	beq $t8, $zero, clearnext

	clearnext:
		add $t1, $t1, 0xfffffffc	# increment word store address down
		sw $t6, 0($t1)			# overwrite
		add $t2, $t2, 0xfffffffc	# increment index by -(1<<2)
		beq $t2, $zero, clearreturn	# if finished looking through buffer (words=0)
		j clearnext
	clearreturn:
	add $v0, $zero, $t2	#set length of game for return
	jr $ra
	
quit: 
	addi $v0, $zero, 10
	syscall
