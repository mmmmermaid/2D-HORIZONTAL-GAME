extends CharacterBody2D

var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")

var speed = 100
var chase = false
var alive = true

@onready var player: CharacterBody2D = $"../../Player/Player"
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
		
	var direction = (player.position - self.position).normalized()
	if alive:
		if chase == true:
			velocity.x = direction.x * speed
			animated_sprite_2d.play("run")
		else:
			velocity.x = 0
			animated_sprite_2d.play("idle")
		
		if direction.x < 0:
			animated_sprite_2d.flip_h = true
		elif direction.x > 0:
			animated_sprite_2d.flip_h = false
	
	move_and_slide()

func _on_chase_detector_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		chase = true

func _on_achase_detector_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		chase = false

func _on_hit_detector_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		body.velocity.y -= 300
		death()

func death():
	alive = false
	animated_sprite_2d.play("death")
	await animated_sprite_2d.animation_finished
	queue_free()

func _on_attack_detector_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		if alive:
			body.health -= 40
		death()
