extends CharacterBody2D

enum {
	MOVE,
	SLIDE,
	BLOCK,
	ATTACK_1,
	ATTACK_2,
	ATTACK_3,
}

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")

var health = 100
var gold = 0
var state = MOVE
var walk_speed = 1
var combo = false
var attack_cooldown = false

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var player_pos

func _physics_process(delta: float) -> void:
	match state:
		MOVE:
			move_state()
			
		SLIDE:
			slide_state()
			
		BLOCK:
			block_state()
			
		ATTACK_1:
			attack_1_statr()
			
		ATTACK_2:
			attack_2_statr()
			
		ATTACK_3:
			attack_3_statr()
		
	if not is_on_floor():
		velocity.y += gravity * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		animation_player.play("jump")
		
	if velocity.y > 0:
		animation_player.play("fall")
		
	if health <= 0:
		health = 0
		animation_player.play("death")
		await animation_player.animation_finished
		queue_free()
		get_tree().change_scene_to_file("res://start_memu.tscn") 
		
	move_and_slide()
	
	player_pos = self.position
	Signals.emit_signal("player_position_update", player_pos)

func move_state():
	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED * walk_speed
		if velocity.y == 0:
			if walk_speed == 1:
				animation_player.play("run")
			elif walk_speed == 0.5:
				animation_player.play("walk")
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		if velocity.y == 0:
			animation_player.play("idle")

	if direction == -1:
		animated_sprite_2d.flip_h = true
	elif direction == 1:
		animated_sprite_2d.flip_h = false
		
	if Input.is_action_pressed("walk"):
		walk_speed = 0.5
	else :
		walk_speed = 1
	
	if Input.is_action_pressed("block"):
		state = BLOCK
		
	if Input.is_action_pressed("slide"):
		state = SLIDE
		
	if Input.is_action_pressed("attack") and attack_cooldown == false:
		state = ATTACK_1

func block_state():
	velocity.x = 0
	animation_player.play("block")
	if Input.is_action_just_released("block"):
		state = MOVE

func slide_state():
	animation_player.play("slide")
	await animation_player.animation_finished
	state = MOVE

func attack_1_statr():
	if Input.is_action_just_pressed("attack") and combo:
		state = ATTACK_2
	velocity.x = 0
	animation_player.play("attack_1")
	await animation_player.animation_finished
	attack_freeze()
	state = MOVE

func combo_1():
	combo = true
	await animation_player.animation_finished
	combo = false

func attack_2_statr():
	if Input.is_action_just_pressed("attack") and combo:
		state = ATTACK_3
	animation_player.play("attack_2")
	await animation_player.animation_finished
	state = MOVE

func attack_3_statr():
	animation_player.play("attack_3")
	await animation_player.animation_finished
	state = MOVE

func attack_freeze():
	attack_cooldown = true
	await get_tree().create_timer(0.3).timeout
	attack_cooldown = false
