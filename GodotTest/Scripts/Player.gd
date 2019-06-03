extends KinematicBody2D


const Utils = preload("res://Scripts/Utils.gd")

export var runSpeed : float = 220

export var jumpHeight : float = 40
export var jumpTime : float = 0.3
export var canIdle := true
export var canFall := true


var velocity := Vector2()
#Acceleration/strafing
export var groundMvmtTime := {
	accel = 0.2,
	decel = 0.1,
	turn = 0.3
}
export var airMvmtTime := {
	accel = 0.4,
	decel = 0.2,
	turn = 0.5
}

export var wallJumpSpeed := 500.0
export var wallSlide := {
	maxSpeed = 600,
	accelTime = 0.5
}
#export var wallSlideSpeed := 
#export var accelTimeG := 0.2
#export var decelTimeG := 0.1
#export var turnTimeG := 0.1
#export var accelTimeA := 0.2
#export var decelTimeA := 0.4
#export var turnTimeA := 0.1


#export var cancels := {
#	"Idle": false,
#	"Fall": false,
#	"Attack": false,
#	"Jump": false
#}

#Child nodes
onready var animP : AnimationPlayer = $AnimationPlayer
onready var sprite : Sprite = $Sprite

var gravity := 0.0

var onWall := false

func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var move = 0
	
	velocity.y += gravity*delta
	
	var onFloor = is_on_floor()
	
	#Just touched wall
	var touchedWall = is_on_wall()
	if !onWall and touchedWall:
		onWall = true
		if !onFloor:
			velocity.y = min(velocity.y, 0.0)
	#Just left wall
	elif onWall and !touchedWall:
		canFall = true
	onWall = touchedWall
	
	if onWall and velocity.y > 0:
		gravity = wallSlide.maxSpeed/wallSlide.accelTime
		velocity.y = min(wallSlide.maxSpeed, velocity.y)
		playAnim("wall slide")
		canFall = false
	else:
		gravity = 2*jumpHeight/(jumpTime*jumpTime)
		
	#movement
	if(Input.is_action_pressed("ui_right")):
		#Use 1 for non-analog input
		move += Input.get_action_strength("ui_right")
		#sprite.flip_h = velocity.x < 0
		sprite.flip_h = false
		if onFloor:
			playAnim("run")
	elif Input.is_action_pressed("ui_left"):
		#Use 1 for non-analog input
		move -= Input.get_action_strength("ui_left")
		#sprite.flip_h = velocity.x < 0
		sprite.flip_h = true
		if onFloor:
			playAnim("run")
	else:
		move = 0
		if canIdle:
			playAnim("idle")
		
	if Input.is_action_just_pressed("jump"):
		#Ground jump
		if onFloor:
			velocity.y = -2*jumpHeight/jumpTime
			playAnim("jump")
		#Wall jump
		elif onWall:
			canFall = false
			playAnim("flip")
			velocity.y = -2*jumpHeight/jumpTime
		
	#falling animation
	if !onFloor and velocity.y > 0 and canFall and !onWall:
		playAnim("fall")

	#attack animations
	if Input.is_action_just_pressed("light attack") and canFall:
		#animation runs on a different frame system than the script
		#I set the canFall value in animation and it kept getting cancelled 
		#do state checks in script, not animation, as they are faster here (constant vs variable update)
		#canFall = false
		#canIdle = false
		playAnim("slash 1", false, false)
		#print("Can idle is now ", canIdle)
	
	
	#movement calculations
	var moveTimes = groundMvmtTime if onFloor else airMvmtTime
	
	var accelX : float
	#Calculate acceleration
	#Moving forward
	if velocity.x * move >  0:
		accelX = runSpeed/moveTimes.accel
	#Stopping
	elif move == 0:
		accelX = runSpeed/moveTimes.decel
	#Turning around
	else:
		accelX = runSpeed/moveTimes.turn
	#How fast player wants to go based on input
	var targetSpeed = move*runSpeed
	velocity.x = Utils.moveTowards(velocity.x, targetSpeed, accelX*delta)
	
	# -y is up, +y is down
	velocity = move_and_slide(velocity, Vector2(0, -1))


#func _on_AnimationPlayer_animation_finished(anim_name):
#	canIdle = true
#	canFall = true

#play animation and reset vars
func playAnim(animName: String, fall:=true, idle:=true):
	animP.play(animName)
	canIdle = idle
	canFall = fall