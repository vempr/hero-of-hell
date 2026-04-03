extends CanvasLayer

@onready var player: CharacterBody3D = %Player


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	$Label.text = "form: " + str(player.current_form) + "\n"
	$Label.text += "max stamina: " + str(player.max_stamina) + "\n"
	$Label.text += "stamina: " + str(player.stamina) + "\n"
