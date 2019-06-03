extends KinematicBody2D

export(float) var runSpeed = 220

var velocity = Vector2()
export(float) var jumpHeight = 40
export(float) var jumpTime = 0.3
export(bool) var canIdle = true
#canFall is the ability to play the falling animation
export(bool) var canFall = true
#stores the hitBox direction so it can be flipped when player changes direction
var hitBoxFacesRight = true

func _ready():
	$AnimationPlayer.play("playerIdle")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var move = 0.0
	var gravity = 2*jumpHeight/(jumpTime*jumpTime)

	# -y is up, +y is down
	velocity.y += gravity*delta
	
	#movement
	if(Input.is_action_pressed("ui_right")):
		move += 1
		if(velocity.x > 0):
			$Sprite.flip_h= false
			if(!hitBoxFacesRight):
				#flips the player hitbox
				$playerHitbox/CollisionShape2D.position.x *= -1
				hitBoxFacesRight = true
		if(velocity.x < 0):
			$Sprite.flip_h= true
			if(hitBoxFacesRight):
				#flips the player hitbox
				$playerHitbox/CollisionShape2D.position.x *= -1
				hitBoxFacesRight = false
		if(canFall):
			$AnimationPlayer.play("playerRun")
	
	elif(Input.is_action_pressed("ui_left")):
		move -= 1
		if(velocity.x < 0):
			$Sprite.flip_h= true
			if(hitBoxFacesRight):
				#flips the player hitbox
				$playerHitbox/CollisionShape2D.position.x *= -1
				hitBoxFacesRight = false
		if(canFall):
			$AnimationPlayer.play("playerRun")
	else:
		velocity.x = 0
		if(canIdle):
			$AnimationPlayer.play("playerIdle")
		
	if(Input.is_action_just_pressed("jump") && is_on_floor()):
		$AnimationPlayer.play("playerJump")
		velocity.y = -2*jumpHeight/jumpTime
		
	#walljump
	if(Input.is_action_just_pressed("jump") && is_on_floor() == false && is_on_wall()):
		canFall = false
		$AnimationPlayer.play("playerFlip")
		velocity.y = -2*jumpHeight/jumpTime
		
	#attack animations
		#used to be a canFall check in the if statement that stopped attack from being usable on spawn
	if(Input.is_action_just_pressed("light attack")):
		#animation runs on a different frame system than the script
		#I set the canFall value in animation and it kept getting cancelled 
		#do state checks in script, not animation, as they are faster here (constant vs variable update)
		canFall = false
		canIdle = false
		$AnimationPlayer.play("playerLightAttack")

	#movement calculations
	velocity.x = move * runSpeed
	velocity = move_and_slide(velocity, Vector2(0, -1))



