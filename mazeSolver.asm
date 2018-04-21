#pretty buggy
.data
	log: .half
	north: .asciiz "North\n"
	south: .asciiz "South\n"
	east: .asciiz "East\n"
	west: .asciiz "West\n"
	loc: .asciiz "\nCar is at [rc]: "
	heading: .asciiz " facing: "
	walls: .asciiz ". Walls at "
	front: .asciiz "front "
	left: .asciiz "left "
	right: .asciiz "right "
	back: .asciiz "back "
	odo: .asciiz "\nTrip Odomometer(0x4): "
	map: .asciiz "\nMapquest(stops,buffer): "
	route: .asciiz "\nRoute: "
	sp: .asciiz "."
.text
	add $s7, $zero, 0x8	#size of maze
	add $t8, $zero, 0x4	#start the car

top:
	add $a0, $zero, $s7
	jal _leftHandRule
	
	add $a0, $zero, $v0	#pass address to next function
	add $a1, $zero, $v1	#length of trip
	jal _traceBack
	
	jal _moveForward 	#enter maze
	add $a0, $zero, 0x0	#row
	add $a1, $zero, 0x0	#column
	sub $a2, $zero, 0x1	#previous row
	sub $a3, $zero, 0x1	#previous column
	jal _backtracking
j quit

# _backtracking
#
# Args:
#	- $a0: row
#	- $a1: col
#	- $a2: prev row
#	- $a3: prev col
# Return
#	- $v0: boolean result
_backtracking:
addi $sp, $sp, -36
sw $ra, 0($sp)
sw $s7, 4($sp)	#maze size (8)hc
sw $s6, 8($sp)	#solution set, 0x1111
sw $s5, 12($sp)	#walls
sw $s4, 16($sp)	#heading 
sw $s3, 20($sp)	#prev col
sw $s2, 24($sp)	#prev row
sw $s1, 28($sp)	#col
sw $s0, 32($sp) #row
	add $s7, $zero, 0x7	#size
	add $t8, $zero, 0x4	#update car
	add $s0, $zero, $a0
	add $s1, $zero, $a1
	add $s2, $zero, $a2
	add $s3, $zero, $a3

	srl $t0, $t9, 24	#row
	srl $t1, $t9, 16	
	and $t1, 0xff		#col
	srl $s4, $t9, 8		#heading was t3
	and $s4, $s4, 0xf
	and $s5, 0xf		#walls was t2

	checkdone:
	bne $s0, $s7, else
	bne $s1, $s0, else
	j true
	
	else:
	northwall:
	la $a0, north
	addi $v0, $zero, 4
	syscall
	
	sub $t7, $t0, 0x1
	beq $t7, $s2, eastwall
	
	and $s5, $t9, 0xf
	and $s5, 0xf		
	
	bne $s4, 0x8, nwe
	and $s5, 0x8
	beq $s5, 0x8, eastwall
	j mvnorth
	nwe:
	bne $s4, 0x4, nws
	and $s5, 0x4
	beq $s5, 0x4, eastwall
	j mvnorth
	nws:
	bne $s4, 0x2, nww
	and $s5, 0x1
	beq $s5, 0x1, eastwall
	j mvnorth
	nww:
	bne $s4, 0x1, false
	and $s5, 0x2
	beq $s5, 0x2, eastwall
	mvnorth:

	btnorth:
		add $t8, $zero, 0x4
		srl $t6, $t9, 8
		andi $t6, 0xf
		beq $t6, 0x8, fnorth
		add $t8, $zero, 0x3
		j btnorth
	fnorth:
	jal _moveForward
	srl $t0, $t9, 24	#row
	srl $t1, $t9, 16
	and $t1, 0xff		#col
	#sub $t0, $t0, 0x1
	add $a0, $zero, $t0	#row
	add $a1, $zero, $t1	#column
	add $a2, $zero, $s0	#previous row
	add $a3, $zero, $s1	#previous column
	jal _backtracking
	
	bne $v0, 0x1, true
	#j false
	srl $t0, $t9, 24	#row
	srl $t1, $t9, 16	
	and $t1, 0xff		#col
	#add $a0, $s0, 0x1	#row
	add $a0, $zero, $s0
	add $a1, $zero, $t1	#column
	add $a2, $zero, $s0
	add $a3, $zero, $s1
	j false2

	
	eastwall:
	la $a0, east
	addi $v0, $zero, 4
	syscall
	srl $t0, $t9, 24	#row
	srl $t1, $t9, 16	
	and $t1, 0xff		#col
	
	add $t7, $t1, 0x1
	beq $t7, $s3, southwall
	and $s5, $t9, 0xf	#walls
	
	bne $s4, 0x8, ewe
	and $s5, 0x2
	beq $s5, 0x2, southwall
	j mveast
	ewe:
	bne $s4, 0x4, ews
	and $s5, 0x8
	beq $s5, 0x8, southwall
	j mveast
	ews:
	bne $s4, 0x2, eww
	and $s5, 0x4
	beq $s5, 0x4, southwall
	j mveast
	eww:
	bne $s4, 0x1, false
	and $s5, 0x1
	beq $s5, 0x1, southwall
	mveast:

	bteast:
		add $t8, $zero, 0x4
		srl $t6, $t9, 8
		andi $t6, 0xf
		beq $t6, 0x4, feast
		add $t8, $zero, 0x3
		j bteast
	feast:
	jal _moveForward
	srl $t0, $t9, 24	#row
	srl $t1, $t9, 16	
	and $t1, 0xff		#col
	#add $t1, $t1, 0x1	
	add $a0, $zero, $t0	#row
	add $a1, $zero, $t1	#column
	add $a2, $zero, $s0	#previous row
	add $a3, $zero, $s1	#previous column
	jal _backtracking	
	bne $v0, 0x1, true
	srl $t0, $t9, 24	#row
	srl $t1, $t9, 16	
	and $t1, 0xff		#col
	add $a0, $zero, $t0	#row
	#add $a1, $zero, $s1
	sub $a1, $s1, 0x1	#column
	add $a2, $zero, $s0
	add $a3, $zero, $s1	
	j false2

	
	southwall:
	la $a0, south
	addi $v0, $zero, 4
	syscall
	
	srl $t0, $t9, 24	#row
	srl $t1, $t9, 16	
	and $t1, 0xff		#col
	add $t7, $t0, 0x1
	beq $t7, $s2, westwall
	and $s5, $t9, 0xf	#walls
	
	bne $s4, 0x8, swe
	and $s5, 0x1
	beq $s5, 0x1, westwall
	j mvsouth
	swe:
	bne $s4, 0x4, sws
	and $s5, 0x2
	beq $s5, 0x2, westwall
	j mvsouth
	sws:
	bne $s4, 0x2, sww
	and $s5, 0x8
	beq $s5, 0x8, westwall
	j mvsouth
	sww:
	bne $s4, 0x1, false
	and $s5, 0x4
	beq $s5, 0x4, westwall
	
	mvsouth:

	btsouth:
		add $t8, $zero, 0x4
		srl $t6, $t9, 8
		andi $t6, 0xf
		beq $t6, 0x2, fsouth
		add $t8, $zero, 0x3
		j btsouth
	fsouth:
	jal _moveForward
	srl $t0, $t9, 24	#row
	srl $t1, $t9, 16	
	and $t1, 0xff		#col
	#add $t0, $t0, 0x1	# per function
	add $a0, $zero, $t0	#row
	add $a1, $zero, $t1	#column
	add $a2, $zero, $s0	#previous row
	add $a3, $zero, $s1	#previous column
	jal _backtracking
	#j false
	bne $v0, 0x1, true
	srl $t0, $t9, 24	#row
	srl $t1, $t9, 16	
	and $t1, 0xff		#col
	#sub $a0, $t0, 0x1	#row
	sub $a0, $t0, $s0
	add $a1, $zero, $s1	#column
	add $a2, $zero, $s0
	add $a3, $zero, $s1	
	j false2
	
	westwall:
	la $a0, west
	addi $v0, $zero, 4
	syscall
	srl $t0, $t9, 24	#row
	srl $t1, $t9, 16	
	and $t1, 0xff		#col
	sub $t7, $t1, 0x1
	beq $t7, $s3, false
	and $s5, $t9, 0xf	#walls
	
	bne $s4, 0x8, wwe
	and $s5, 0x4
	beq $s5, 0x4, false
	j mvwest
	wwe:
	bne $s4, 0x4, wws
	and $s5, 0x1
	beq $s5, 0x1, false
	j mvwest
	wws:
	bne $s4, 0x2, www
	and $s5, 0x2
	beq $s5, 0x2, false
	j mvwest
	www:
	bne $s4, 0x1, false
	and $s5, 0x8
	beq $s5, 0x8, false
	
	mvwest:

	btwest:
		add $t8, $zero, 0x4
		srl $t6, $t9, 8
		andi $t6, 0xf
		beq $t6, 0x1, fwest
		add $t8, $zero, 0x3
		j btwest
	fwest:
	jal _moveForward
	srl $t0, $t9, 24	#row
	srl $t1, $t9, 16	
	and $t1, 0xff		#col
	#sub $t1, $t1, 0x1
	add $a0, $zero, $t0	#row
	add $a1, $zero, $t1	#column
	add $a2, $zero, $s0	#previous row
	add $a3, $zero, $s1	#previous column
	jal _backtracking 
	bne $v0, 0x1, true
	srl $t0, $t9, 24	#row
	srl $t1, $t9, 16	
	and $t1, 0xff		#col
	add $a0, $zero, $s0	#row
	#add $a1, $zero, $t1	#column
	add $a1, $s1, 0x1	#column
	add $a2, $zero, $s0
	add $a3, $zero, $s1	
	j false2


false:
	add $t8, $zero, 0x3
	srl $t0, $t9, 24	#row
	srl $t1, $t9, 16	
	and $t1, 0xff		#col
	add $a0, $zero, $t0	#row
	add $a1, $zero, $t1	#column
	add $a2, $zero, $t0	#previous row
	add $a3, $zero, $t1	#previous column
false2:	
	add $v0, $zero, 0xff
	jal _backtracking 	
j return

true:
	add $t8, $zero, 0x2
	add $t8, $zero, 0x3
	add $v0, $zero, 0x1
return:	
lw $s0, 32($sp)	
lw $s1, 28($sp)		
lw $s2, 24($sp)
lw $s3, 20($sp)		
lw $s4, 16($sp)
lw $s5, 12($sp)		
lw $s6, 8($sp)
lw $s7, 4($sp)		
lw $ra, 0($sp)
addi $sp, $sp, 32
jr $ra

# _leftHandRule
#
# Args:
#	- $a0: size of maze(last column)
#	- $a1-3: 
# Return
#	- $v0:  buffer address(map of fastest route)
#	- $v1: 	trip odometer
_leftHandRule:
addi $sp, $sp, -36
sw $ra, 0($sp)
sw $s7, 4($sp)	#maze size
sw $s6, 8($sp)	#log addr
sw $s5, 12($sp)	#odometer (array index)
sw $s4, 16($sp)	#walls
sw $s3, 20($sp)	#left wall
sw $s2, 24($sp) #front wall
sw $s1, 28($sp)	#column
sw $s0, 32($sp)
	add $s7, $zero, $a0
	add $s5, $zero, $zero
	la $s6, log
	add $t8, $zero, 0x1
	#srl $t0, $t9, 16		#write start location to buffer
	#sh $t0, 0($s6)
	#add $s5, $zero, 0x2		#inc odometer
	#andi $t0, $t9, 0x00ff0000	#enter the maze if at start, assumed
	#bne $t0, $zero, moveit
	#beq $t0, $zero, lefttop
	#j moveit

	#jal _moveForward	
lefttop:
	add $t8, $zero, 0x4
	srl $s0, $t9, 16
	sh $s0, 0($s6)

	#do cleanup
	la $t0, log
	add $t0, $t0, 0x4
	add $t5, $zero, $zero
	cleanmap:
		beq $t5, $s5, cleaned
		lh $t1, -4($t0)
		beq $t1, $s0, cleanbuffer
		add $t0, $t0, 0x4
		add $t5, $t5, 0x4
		j cleanmap
	cleanbuffer:
	beq $s5, $t5, cleaned
	sh $zero, -4($s6)
	sub $s6, $s6, 0x4
	sub $s5, $s5, 0x4
	j cleanbuffer

	cleaned:
	sh $s0, 0($s6)
	add $s5, $s5, 0x4	#odometer++
	add $s6, $s6, 0x4	#odometer address ++

	#add $t8, $zero, 0x4
	#add $a0, $zero, $t9
	#jal geolocate
	
	andi $s4, $t9, 0xf	#walls
	andi $s3, $s4, 0x4	#keep wall on left
	andi $s2, $s4, 0x8	#check wall in front
	srl $s1, $t9, 16
	andi $s1, 0xff		#column
	beq $s1, 0x8, endleft	#if at end of maze 

	leftcorner:
	bne $s4, 0xc, rightcorner
	add $t8, $zero, 0x3
	jal _moveForward
	j lefttop
	
	rightcorner:
	bne $s4, 0xa, deadend
	add $t8, $zero, 0x2
	jal _moveForward
	j lefttop
	
	deadend:
	bne $s4, 0xe, clearfront
	add $t8, $zero, 0x3
	add $t8, $zero, 0x3
	jal _moveForward
	j lefttop
	
	clearfront:
	beq $s2, $zero, moveit
	bne $s2, 0x8, moveit
	add $t8, $zero, 0x2	#front wall only turn left and move once
	jal _moveForward
	j lefttop
	
	nowallonleft:
	add $t8, $zero, 0x2
	jal _moveForward
	j lefttop
	
	moveit:
	add $t8, $zero, 0x4
	beq $s3, $zero, nowallonleft
	jal _moveForward
	j lefttop
	
add $t6, $zero, $zero
endleft:
	add $t8, $zero, 0x3
	add $t6, $t6, 0x4
	bne $t6, 0x8, endleft	#do a 180 turn to indicate finish line
	
	sub $s5, $s5, 0x4	#ignore last spot
	sub $s6, $s6, 0x4  	#ignore last spot
	
	add $a0, $zero, $s6
	addi $v0, $zero, 1	#print int
	syscall
	la $a0, odo
	addi $v0, $zero, 4	#print string
	syscall
	add $a0, $zero, $s5
	addi $v0, $zero, 1	#print int
	syscall
	

	add $v0, $zero, $s6	#buffer addr
	add $v1, $zero, $s5	#odometer

lw $s0, 32($sp)	
lw $s1, 28($sp)		
lw $s2, 24($sp)
lw $s3, 20($sp)		
lw $s4, 16($sp)
lw $s5, 12($sp)		
lw $s6, 8($sp)
lw $s7, 4($sp)		
lw $ra, 0($sp)
addi $sp, $sp, 32
jr $ra


# _traceBack
#
# Args:
#	- $a0: buffer that contains list coordinates
#	- $a1: length of trip in halfs
# Return
#	- $v0:  
#	- $v1: 
_traceBack:
addi $sp, $sp, -36
sw $ra, 0($sp)
sw $s7, 4($sp)	#maze size
sw $s6, 8($sp)	#log addr
sw $s5, 12($sp)	#odometer (array index)
sw $s4, 16($sp)	#half store of addr
sw $s3, 20($sp)
sw $s2, 24($sp) #and s1&s4
sw $s1, 28($sp)	#current location
sw $s0, 32($sp)
tracetop:
	add $s6, $zero, $a0	#route to take
	add $s5, $zero, $a1	#trip length

	la $a0, map
	addi $v0, $zero, 4	#print string
	syscall
	add $a0, $zero, $s5
	addi $v0, $zero, 1	#print int
	syscall
	la $a0, sp
	addi $v0, $zero, 4	#print string
	syscall
	add $a0, $zero, $s6
	addi $v0, $zero, 34	#print int
	syscall

	mapquest:
	la $a0, route
	addi $v0, $zero, 4	#print string
	syscall
	
	lh $s4, -4($s6)
	sub $s5, $s5, 0x4
	sub $s6, $s6, 0x4
	
	add $a0, $zero, $s4
	addi $v0, $zero, 34	#print int
	syscall
	la $a0, sp
	addi $v0, $zero, 4	#print string
	syscall
	add $a0, $zero, $s5
	addi $v0, $zero, 1	#print int
	syscall
	la $a0, sp
	addi $v0, $zero, 4	#print string
	syscall
	add $a0, $zero, $s6
	addi $v0, $zero, 1	#print int
	syscall
	la $a0, sp
	addi $v0, $zero, 4	#print string
	syscall
	
	add $t8, $zero, 0x4			
	srl $s1, $t9, 16	#location
	beq $s1, $zero, exit	#prevents having to deal with ff start location
	srl $t0, $s1, 8		#row
	#sll $t1, $s1, 8
	and $t1, $s1, 0xff
	
	srl $s0, $s4, 8		#next row
	and $s1, $s4, 0xff	#next column	
	
	bne $t0, $s0, moverow
	bne $t1, $s1, movecol
	
	moverow:
	slt $t2, $t1, $s1	#move left t0<s0=1
	bne $t2, $zero, godown
	goup:
		add $t8, $zero, 0x4
		srl $t6, $t9, 8
		andi $t6, 0xf
		beq $t6, 0x8, movefinish
		add $t8, $zero, 0x2
		j goup
	godown:
		add $t8, $zero, 0x4
		srl $t6, $t9, 8
		andi $t6, 0xf
		beq $t6, 0x2, movefinish
		add $t8, $zero, 0x3
		j godown
	
	movecol:	
	slt $t2, $t1, $s1	#move left t0<s0=1
	bne $t2, $zero, goright
	goleft:
		add $t8, $zero, 0x4
		srl $t6, $t9, 8
		andi $t6, 0xf
		beq $t6, 0x1, movefinish
		beq $s5, $zero, tracedone
		add $t8, $zero, 0x2
		j goleft
	goright:
		add $t8, $zero, 0x4
		srl $t6, $t9, 8
		andi $t6, 0xf
		beq $t6, 0x4, movefinish
		add $t8, $zero, 0x3
		j goright
		
	movefinish:
	jal _moveForward			
	beq $s5, $zero, tracedone
	j mapquest
exit:
	add $t8, $zero, 0x4
	srl $t6, $t9, 8
	andi $t6, 0xf
	add $t8, $zero, 0x2
	beq $t6, 0x8, tracedone	#face left to exit
	j exit
tracedone:
	jal _moveForward
add $t6, $zero, $zero
turn:
	add $t8, $zero, 0x3
	add $t6, $t6, 0x4
	bne $t6, 0x8, turn	#do a 180 turn to indicate finish line
lw $s0, 32($sp)	
lw $s1, 28($sp)		
lw $s2, 24($sp)
lw $s3, 20($sp)		
lw $s4, 16($sp)
lw $s5, 12($sp)		
lw $s6, 8($sp)
lw $s7, 4($sp)		
lw $ra, 0($sp)
addi $sp, $sp, 32
jr $ra


# _moveForward (Safeguard from hitting walls)
#
# Args:
#	- $a0: 
# Return
#	- $v1: Boolean Success(1)/Fail(-1)
_moveForward:
addi $sp, $sp, -16
sw $ra, 0($sp)
lw $s7, 4($sp)	
lw $s2, 8($sp)		
lw $s3, 12($sp)
	add $t8, $zero, 0x4	#update location	
	add $s7, $zero, $t9	#store location	
	#heading
	srl $s2, $s7, 8
	andi $s2, 0xf
	#walls
	andi $s3, $s7, 0xf
	andi $s3, $s3, 0x8	#front wall
	beq $s3, 0x8, nomove
	move:
	add $t8, $t8, 0x1
	add $v1, $zero, 0x1	#good move
	j moved
	nomove:
	addi $v1, $zero, -1	#no move
moved:	
beq $t8, $zero, movingdone
movingdone:
add $t8, $t8, 0x4
lw $s3, 12($sp)		
lw $s2, 8($sp)
lw $s7, 4($sp)	
lw $ra, 0($sp)
addi $sp, $sp, 16
jr $ra

# _geolocate (prints locations and wall statuses)
#
# Args:
#	- $a0: location of car
geolocate:
addi $sp, $sp, -4	#adjust stack
sw $ra, 0($sp)
	
	add $t7, $zero, $a0	#store location
	
	#row
	srl $t0, $t7, 24
	#column
	srl $t1, $t7, 16
	andi $t1, 0xff
	#heading
	srl $t2, $t7, 8
	andi $t2, 0xf
	#walls
	andi $t3, $t7, 0xf
	
	la $a0, loc
	addi $v0, $zero, 4	#print string
	syscall
	add $a0, $zero, $t0
	addi $v0, $zero, 1	#print int
	syscall
	add $a0, $zero, $t1
	addi $v0, $zero, 1	#print int
	syscall
	la $a0, heading
	addi $v0, $zero, 4	#print string
	syscall
	bne $t2, 0x8, n
	la $a0, north
	j w
	n:
	bne $t2, 0x4, e
	la $a0, east
	j w
	e:
	bne $t2, 0x2, s
	la $a0, south
	j w
	s:
	bne $t2, 0x1, w
	la $a0, west
	w:
	addi $v0, $zero, 4	#print string
	syscall
	
	la $a0, walls
	addi $v0, $zero, 4	#print string
	syscall
	
	wallcheck:
		add $t4, $zero, 0x8	#value to compare and shift by for each case
		and $t5, $t3, $t4
		bne $t5, 0x8, wfront
		la $a0, front
		addi $v0, $zero, 4
		syscall
		wfront:
		srl $t4, $t4, 0x1
		and $t5, $t3, $t4
		bne $t5, 0x4, wleft
		la $a0, left
		addi $v0, $zero, 4
		syscall
		wleft:
		srl $t4, $t4, 0x1
		and $t5, $t3, $t4
		bne $t5, 0x2, wback
		la $a0, right
		addi $v0, $zero, 4
		syscall
		wback:
		srl $t4, $t4, 0x1
		and $t5, $t3, $t4
		bne $t5, 0x1, wallcheckdone
		la $a0, back
		addi $v0, $zero, 4
		syscall
	wallcheckdone:
lw $ra, 0($sp)
addi $sp, $sp, 4	#adjust stack
jr $ra

quit: 
	addi $v0, $zero, 10
	syscall