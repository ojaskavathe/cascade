@tool
extends Sprite2D

func _process(delta):
	get_material().set_shader_parameter("zoom", get_viewport_transform().y.y)
