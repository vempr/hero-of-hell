extends Node3D


func _ready() -> void:
	pass # Replace with function body.


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		var paused = get_tree().paused
		get_tree().paused = !paused
