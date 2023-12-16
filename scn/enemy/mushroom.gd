extends CharacterBody2D

enum {
	IDLE,
	ATTACK,
	CHASE,
}

var state: int = 0:
	set(value):
		state = value
		match state:
			IDLE:
				idle_state()
			ATTACK:
				attack_state()
				

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")
var player
var damege = 20

func _ready() -> void:
	Signals.connect("player_position_update", Callable(self, "_on_player_position_update")) 

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta
	
	if state == CHASE:
		chase_state()
	
	move_and_slide()

func _on_player_position_update(player_pos):
	player = player_pos

func _on_attack_range_body_entered(body: Node2D) -> void:
	state = ATTACK

func idle_state():
	animation_player.play("idle")
	await get_tree().create_timer(1).timeout
	$AttackDirection/AttackRange/CollisionShape2D.disabled = false
	state = CHASE
	
func attack_state():
	animation_player.play("attack")
	await  animation_player.animation_finished
	$AttackDirection/AttackRange/CollisionShape2D.disabled = true
	state = IDLE

func chase_state():
	var direction = (player - self.position).normalized()
	if direction.x < 0:
		animated_sprite_2d.flip_h = true
		$AttackDirection.scale.x = -1
	elif direction.x > 0:
		animated_sprite_2d.flip_h = false
		$AttackDirection.scale.x = 1

func _on_hit_box_area_entered(area: Area2D) -> void:
	Signals.emit_signal("enemy_attack", damege)
