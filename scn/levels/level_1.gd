extends Node2D

@onready var sun: DirectionalLight2D = $Light/Sun
@onready var point_light_2d: PointLight2D = $Buildings/PointLight2D
@onready var text_day: Label = $CanvasLayer/TextDay
@onready var text_animation_player: AnimationPlayer = $CanvasLayer/TextAnimationPlayer

enum {
	MORNING,
	DAY,
	EVENING,
	NIGHT,
}

var state = MORNING
var day_count: int

func _ready() -> void:
	sun.enabled = true
	morning_state()

func morning_state():
	day_count += 1
	var tween = get_tree().create_tween()
	tween.tween_property(sun, "energy", 0.2, 20)
	var tween_1 = get_tree().create_tween()
	tween_1.tween_property(point_light_2d, "energy", 0, 20)
	
	text_day.text = "DAY" + str(day_count)
	text_animation_player.play("day_fade_in")
	await get_tree().create_timer(3).timeout
	text_animation_player.play("day_fade_out")
	
func evening_state():
	var tween = get_tree().create_tween()
	tween.tween_property(sun, "energy", 0.9, 20)
	var tween_1 = get_tree().create_tween()
	tween_1.tween_property(point_light_2d, "energy", 1.5, 20)

func _on_day_night_timeout() -> void:
	match state:
		MORNING:
			morning_state()
		EVENING:
			evening_state()
	
	if state < 3:
		state += 1
	else:
		state = MORNING
