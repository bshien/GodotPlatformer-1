extends KinematicBody2D
#enemy runSpeed
export (float) var runSpeed = 80
var velocity = Vector2()
export(float) var jumpHeight = 40
export(float) var jumpTime = 0.3

var dead := false

export var maxHealth := 3
onready var currentHealth := maxHealth
#only spawn a skeleton once when the player enters near him
var skeletonCanSpawn = true
var spriteFacingRight = true 

onready var skeletonSpawn_resource = preload("res://Objects/Enemy.tscn")
onready var player = get_node("../Player")

# Called when the node enters the scene tree for the first time.
func _ready():
	#should spawn one skeleton at the boss location
	skeletonSpawn_resource
	#instance lets us use the preload
	var skeletonSpawn = skeletonSpawn_resource.instance()
	skeletonSpawn.player = player as KinematicBody2D
	#nodePath is a string
	skeletonSpawn.position = $"spawnPoint".position
	add_child(skeletonSpawn)
	
func takeDamage(damage : int):
	currentHealth -= damage
	if(currentHealth <= 0):
		dead = true
		$AnimationPlayer.play("onDeath")
	
func _physics_process(delta):
	var move = 0.0
	var gravity = 2*jumpHeight/(jumpTime*jumpTime)

	velocity.y += gravity*delta
	#checks if guy is dead so no longer plays run animation
	if(dead):
		return
		
	if(position.x < player.position.x - 15):
		move += 1
		$AnimationPlayer.play("spiderRun")
			
	if(position.x > player.position.x - 20):
		if(velocity.x < 0):
			spriteFacingRight = false
		else:
			spriteFacingRight = true
		if(!spriteFacingRight):
			$Sprite.flip_h = true
		move -= 1
		$AnimationPlayer.play("spiderRun")
	else:
		#print("skeleton is defensive ", skeletonMode)
		pass
		
	
	
	velocity.x = move * runSpeed
	# -y is up, +y is down
	velocity = move_and_slide(velocity, Vector2(0, -1))
