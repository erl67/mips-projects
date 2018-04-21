.text
top_clear:
	add $t8, $zero, $zero
	add $s0, $zero, 0x0	#operator 
	add $s1, $zero, 0x0	#operand 1
	add $s2, $zero, 0x0	#operand 2
	add $s3, $zero, 0x0	#results
	add $s4, $zero, 0x0	#operand 1 backup
	add $s5, $zero, 0x0	#operand 2 backup
	add $t6, $zero, 0xe	#another equals flag
	add $t0, $zero, 0x0	#operator temporary flag
	add $t1, $zero, 0x1	#operand 1 flag, always should =1, but useful for debugging
	add $t2, $zero, 0x0	#operand 2 flag
	add $t3, $zero, 0x0	#used for calculating temps
	add $t4, $zero, 0x0	#used for calculating temps
	add $t5, $zero, 0x1	#counter
topbits:			#loop for second number entry
	add $s6, $zero, 0x0	#incrementer for bit of input
	add $s7, $zero, 0x0	#store input temporarily	
	add $t6, $zero, $s0	#backup operator for chains
	#add $t0, $zero, 0x0	#equals operator temporary flag
	#add $t6, $zero, 0x0	#another equals flag
	#add $s2, $zero, 0x0	#second operator
top:	
	add $t9, $zero, $zero	#set $t9 = 0 to get input
	add $t7, $zero, $zero	#hold input value
	input_loop: 
	beq $t9, $zero, input_loop	#loop until a button gets pressed
	andi $t7, $t9, 0xf	#set $t7 to input last 4 bits
keypress:	
	beq $t7, 0xf, cls	
	beq $t7, 0x0, key0
	beq $t7, 0x1, key1
	beq $t7, 0x2, key2
	beq $t7, 0x3, key3
	beq $t7, 0x4, key4
	beq $t7, 0x5, key5
	beq $t7, 0x6, key6
	beq $t7, 0x7, key7
	beq $t7, 0x8, key8
	beq $t7, 0x9, key9
	beq $t7, 0xa, keyadd
	beq $t7, 0xb, keysub
	beq $t7, 0xc, keymult
	beq $t7, 0xd, keydiv
	beq $t7, 0xe, keyeq
	beq $t7, 0xf, cls
j top
	
operands:
	bne $t0, 0xe, afterequal #if user enters numbers after an equals reset everything
	add $t8, $zero, $zero
	add $s0, $zero, 0x0	#operator 
	add $s1, $zero, 0x0	#operand 1
	add $s2, $zero, 0x0	#operand 2
	add $s3, $zero, 0x0	#results
	add $s4, $zero, 0x0	#operand 1 backup
	add $s5, $zero, 0x0	#operand 2 backup
	add $s6, $zero, 0x0	#incrementer for bit of input
	add $s7, $zero, 0x0	#store input temporarily
	add $t1, $zero, 0x1	#operand 1 flag, always should =1, but useful for debugging
	add $t2, $zero, 0x0	#operand 2 flag
	add $t3, $zero, 0x0	#used for calculating temps
	add $t4, $zero, 0x0	#used for calculating temps
	add $t5, $zero, 0x1	#counter
	add $t6, $zero, 0x0	#operator temporary flag
	add $t0, $zero, 0x0	#operator temporary flag
	afterequal:	
	beq $t1, $t2, secondOperand	#branch for when entering second number
firstOperand:
	beq $s6, $zero, first
	add $t4, $zero, $s7	
	sll $s7, $s7, 3
	add $s7, $s7, $t4
	add $s7, $s7, $t4

	first:
	add $s7, $s7, $t7

	add $s6, $s6, 0x1
	add $s1, $zero, $s7 #save first operand
	j update
secondOperand:
	beq $s6, $zero, firstdigit
	add $t4, $zero, $s7	
	sll $s7, $s7, 3
	add $s7, $s7, $t4
	add $s7, $s7, $t4

	firstdigit:
	add $s7, $s7, $t7
	
	add $s6, $zero, 0x1
	add $s2, $zero, $s7 #save second operand here
	j update

add:
	add $s3, $s1, $s2
	j opresult

sub:
	sub $s3, $s1, $s2
	j opresult		

mult:
	add $t3, $zero, $s1	#temporary variable for first operand for shifting (original preserved for output)
	add $t4, $zero, $s2	#2nd operand
	add $s3, $zero, $zero	#result holder
mult_loop:		
    	andi $t5, $t4, 1
    	beq $t5, $zero, bit_clear
    	add $s3, $s3, $t3  # if (multiplicand & 1) result += multiplier << shift
bit_clear:
    	sll $t3, $t3, 1     # multiplier <<= 1
    	srl $t4, $t4, 1     # multiplicand >>= 1
    	bne $t4, $zero, mult_loop
    	#beq $t0, $t6, results
	j opresult

div:
	slt $t5, $s1, $s2
	div1:
	bne $s1, $zero, div0	#div 1/0 =  0
		beq $s1, $s2, div0	#div 0/0 =  err
		add $s3, $zero, $zero	#set result to 0
		add $s2, $zero, $zero	#set operand2 to prevent backing up and restore bugs
		add $s5, $zero, $zero	#set backup to prevent backing up and restore bugs
			addi $v0, $zero, 31
			addi $a0, $zero, 82
			addi $a1, $zero, 1111
			addi $a2, $zero, 103
			addi $a3, $zero, 0x30
			syscall	
		j opresult
	div0:
	bne $s2, $zero, divint		#x/0=NaN
		add $s3, $zero, $s1	#set result back to s1
		add $s2, $zero, $zero	#set operand2 to prevent backing up and restore bugs
		add $s5, $zero, $zero	#set backup to prevent backing up and restore bugs
			addi $v0, $zero, 31
			addi $a0, $zero, 46
			addi $a1, $zero, 1111
			addi $a2, $zero, 102
			addi $a3, $zero, 0x30
			syscall	
		j opresult	
	divint:
	div $s1, $s2
	mflo $s3
	j opresult
	
	#below not working as intended
	add $t3, $zero, $s1	#temporary variable for dividend
	add $t4, $zero, $s2	#divisor
	add $s3, $zero, $zero	#quotient
div_loop:	
	slt $t5, $t3, $t4	#if dividend > divisor
	bne $t5, $zero, div_else
	sub $t3, $t3, $t4
	srl $s3, $s3, 1	
	add $s3, $s3, 0x1	#increase quotieunt by 2(one halfed)
	j end_else
div_else:		
    	srl $t3, $t3, 1		
end_else: 	
	srl $t4, $t4, 1		#shift divisor    
	slt $t5, $t3, $t4	
	bne $t5, $zero, div_loop#loop until dividend is less than divisor
	beq $t0, $t6, results
	j opresult

equalkey:
	beq $s0, 0x0, keyadd	#if number entered then equal treat as add + 0	
	bne $s2, $zero, restore #restore s2 from backup if mashing enter
	#bne $s0, 0xd, divrestore #restore if for Div/0
	#beq $s5, $s2, restore
	divrestor:
	add $s2, $zero, $s5
	restore:
	
	beq $s0, 0xa, add
	beq $s0, 0xb, sub
	beq $s0, 0xc, mult
	beq $s0, 0xd, div
			
operate:
	beq $s6, $zero, topbits  #no number was entered just operator button, reset entry but preserve last operator
	beq $t6, $zero, case	#first operator pressed skip parity check
	
	beq $s0, $t6, case	#parity check for operators
	bne $t6, 0xa, addfix
		add $s3, $s1, $s2
		j opresult
	addfix:
	bne $t6, 0xb, subfix
		sub $s3, $s1, $s2
		j opresult
	subfix:
	bne $t6, 0xc, mulfix
		j mult
	mulfix:
	bne $t6, 0xd, divfix
		j div
	divfix:
		#need to fix /0 =? & 1/1
				
	case:			#this entire thing is redundant now?
	beq $s0, 0xa, add
	beq $s0, 0xb, sub
	beq $s0, 0xc, mult
	beq $s0, 0xd, div
	j quit #(error catching)

opresult:
	add $s4, $zero, $s1	#operand 1 backup for contingency in equals:
	add $s5, $zero, $s2	#operand 2 backup for contingency in equals:
	
	add $s1, $zero, $s3	#operand 1 set to results
	add $t8, $zero, $s1	#display first operand again

	add $s2, $zero, 0x0	#reset second operand
	add $s3, $zero, 0x0	#results reset
	add $t6, $zero, $s0	#backup operator	
	j topbits		#return to blank entry for 2nd operand

results:  j quit #(error catching)

update:				#update display
	add $t8, $zero, $s7	#display temporary operand during entry
	beq $t8, 0x1a4, quit	#halt case for error checking
	j top						
key0:
	addi $v0, $zero, 31
	addi $a0, $zero, 48 #pitch (0-127)
	addi $a1, $zero, 400 #duration(ms)
	addi $a2, $zero, 0 #instrument (0-127)
	addi $a3, $zero, 20 #volume(0-100)
	syscall
	j operands
key1:
	addi $v0, $zero, 31
	addi $a0, $zero, 50
	addi $a1, $zero, 400
	addi $a2, $zero, 0
	addi $a3, $zero, 20
	syscall
	j operands
key2:
	addi $v0, $zero, 31
	addi $a0, $zero, 51
	addi $a1, $zero, 400
	addi $a2, $zero, 0
	addi $a3, $zero, 20
	syscall
	j operands
key3:
	addi $v0, $zero, 31
	addi $a0, $zero, 53 
	addi $a1, $zero, 400
	addi $a2, $zero, 0
	addi $a3, $zero, 20
	syscall
	j operands	
key4:
	addi $v0, $zero, 31
	addi $a0, $zero, 55
	addi $a1, $zero, 400
	addi $a2, $zero, 0
	addi $a3, $zero, 20
	syscall
	j operands
key5:
	addi $v0, $zero, 31
	addi $a0, $zero, 56
	addi $a1, $zero, 400
	addi $a2, $zero, 0
	addi $a3, $zero, 20
	syscall
	j operands
key6:
	addi $v0, $zero, 31
	addi $a0, $zero, 58 
	addi $a1, $zero, 400
	addi $a2, $zero, 0
	addi $a3, $zero, 20
	syscall
	j operands
key7:
	addi $v0, $zero, 31
	addi $a0, $zero, 60
	addi $a1, $zero, 400
	addi $a2, $zero, 0
	addi $a3, $zero, 20
	syscall
	j operands
key8:
	addi $v0, $zero, 31
	addi $a0, $zero, 62
	addi $a1, $zero, 400
	addi $a2, $zero, 0
	addi $a3, $zero, 20
	syscall
	j operands
key9:
	addi $v0, $zero, 31
	addi $a0, $zero, 63 
	addi $a1, $zero, 400
	addi $a2, $zero, 0
	addi $a3, $zero, 20
	syscall
	j operands	
keyadd:
	addi $v0, $zero, 31
	addi $a0, $zero, 65
	addi $a1, $zero, 500
	addi $a2, $zero, 26 
	addi $a3, $zero, 30
	syscall
	add $s0, $zero, 0xa
	add $t0, $zero, 0x0
	beq $t1, $t2, operate #if operand 2 has been entered treat 2nd operater as equals
	add $t2, $zero, 0x1
	j topbits
keysub:
	addi $v0, $zero, 31
	addi $a0, $zero, 67
	addi $a1, $zero, 500
	addi $a2, $zero, 26 
	addi $a3, $zero, 30
	syscall
	add $s0, $zero, 0xb
	add $t0, $zero, 0x0
	beq $t1, $t2, operate #if operand 2 has been entered treat 2nd operater as equals
	add $t2, $zero, 0x1
	j topbits																					
keymult:
	addi $v0, $zero, 31
	addi $a0, $zero, 69
	addi $a1, $zero, 500
	addi $a2, $zero, 26 
	addi $a3, $zero, 30
	syscall
	add $s0, $zero, 0xc
	add $t0, $zero, 0x0
	beq $t1, $t2, operate #if operand 2 has been entered treat 2nd operater as equals
	add $t2, $zero, 0x1
	j topbits
keydiv:
	addi $v0, $zero, 31
	addi $a0, $zero, 70
	addi $a1, $zero, 500
	addi $a2, $zero, 26 
	addi $a3, $zero, 30
	syscall
	add $s0, $zero, 0xd
	add $t0, $zero, 0x0
	beq $t1, $t2, operate #if operand 2 has been entered treat 2nd operater as equals
	add $t2, $zero, 0x1
	j topbits	
keyeq:
	addi $v0, $zero, 31
	addi $a0, $zero, 72
	addi $a1, $zero, 400
	addi $a2, $zero, 55
	addi $a3, $zero, 35
	syscall
	add $t0, $zero, 0xe
	add $t6, $zero, 0xe
	add $t2, $zero, 0x1
	j equalkey														
cls: 
	add $t8, $zero, $zero
	addi $v0, $zero, 31
	addi $a0, $zero, 61 #C#
	addi $a1, $zero, 400 #duration(ms)
	addi $a2, $zero, 40
	addi $a3, $zero, 30
	syscall
	j top_clear
	
#halt case added for error checking aHR0cDovL2kuaW1ndXIuY29tL3hmekE0V0UuanBn
quit: #C:48,50,52,53,55,57,59(DM=bf=58),60, octave=+12
	add $t5, $zero, 0x2
	repeatonce:
	addi $v0, $zero, 33
	addi $a0, $zero, 60 #C
	addi $a1, $zero, 200 #duration(ms)
	addi $a2, $zero, 32	#instrument
	addi $a3, $zero, 45	#volume
	syscall
	
	addi $v0, $zero, 33
	addi $a0, $zero, 60
	syscall
	
	addi $v0, $zero, 33
	addi $a0, $zero, 59
	syscall
	
	addi $v0, $zero, 33
	addi $a0, $zero, 60
	syscall
	
	addi $v0, $zero, 33
	addi $a0, $zero, 60
	addi $a3, $zero, 0 #volume 0=rest
	syscall
	
	addi $v0, $zero, 33
	addi $a0, $zero, 55
	addi $a3, $zero, 45 #restore volume
	syscall
	
	addi $v0, $zero, 33
	addi $a0, $zero, 60
	addi $a3, $zero, 0 #volume 0=rest
	syscall
	
	addi $v0, $zero, 33
	addi $a0, $zero, 55
	addi $a3, $zero, 45 #restore volume
	syscall
	
	#2ndms
	addi $v0, $zero, 33
	addi $a0, $zero, 60
	syscall
	
	addi $v0, $zero, 33
	addi $a0, $zero, 65
	syscall
	
	addi $v0, $zero, 33
	addi $a0, $zero, 64
	syscall
	
	addi $v0, $zero, 33
	addi $a0, $zero, 60
	syscall
	
	addi $v0, $zero, 33
	addi $a0, $zero, 60
	addi $a3, $zero, 0 #volume 0=rest
	syscall
	
	addi $v0, $zero, 33
	addi $a0, $zero, 55
	addi $a3, $zero, 45 #restore volume
	syscall
	
	addi $v0, $zero, 33
	addi $a0, $zero, 60
	addi $a3, $zero, 0 #volume 0=rest
	addi $a1, $zero, 1000 #whole rest
	syscall
	
	addi $t5, $t5, 0xffffffff
	bne $t5, $zero, repeatonce

	addi $v0, $zero, 10
	syscall
#cs447 project 1
#19jun17
