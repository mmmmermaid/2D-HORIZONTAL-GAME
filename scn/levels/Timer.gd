extends Timer


var gold = preload("res://scn/collectibles/gold.tscn")


func _on_timeout() -> void:
	var goldTemp = gold.instantiate()
	var rng = RandomNumberGenerator.new()
	var randint = randf_range(50, 500)
	goldTemp.position = Vector2(randint, 530)
	add_child(goldTemp)
