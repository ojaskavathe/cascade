extends Node2D


func _ready():
	Signals.fade_logo.connect(_on_fade_logo)


func _on_fade_logo():
	var tween = get_tree().create_tween()
	tween.tween_property($Logo, "modulate", Color(1.0, 1.0, 1.0, 0.0), 0.2).set_trans(Tween.TRANS_SINE)
