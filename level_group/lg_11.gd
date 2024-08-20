extends Node2D

var dragon_model = preload("res://entity/player/dragon_model.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_area_2d_body_entered(body):
	if body.is_in_group("player"):
		body.GRAVITY = 0
		body.MEGA_VELOCITY = -16000
		body.get_node("PlayerModel").set_visible(false)
		var dragon_model_instance = dragon_model.instantiate()
		body.add_child(dragon_model_instance)


func _on_area_2d_2_body_entered(body):
	if body.is_in_group("player"):
		$CanvasLayer.set_visible(true)
		Engine.time_scale = 0.0
