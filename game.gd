extends Node2D

var confetti_preload = preload("res://entity/object/confetti_emitter.tscn")

@onready var first_level: Node2D = $LevelGroups/LG_0/levels/lvl_0_0
@onready var player: CharacterBody2D = $Player
@onready var camera: Camera2D = $Camera

@export var start_scene: int = 0

@onready var checkpoint_loc: Vector2
@onready var currentScene: Node2D

func _ready():
	Signals.kill.connect(_on_kill)
	Signals.new_checkpoint.connect(_new_checkpoint)
	Signals.player_exited_lg.connect(_new_lg)
	
	var first_lg = self.get_node("LevelGroups").get_node("LG_" + str(start_scene))
	first_level = first_lg.get_node("levels").get_node("lvl_" + str(start_scene) + "_0")
	
	checkpoint_loc = first_level.get_node("SpawnJumpPoint").global_position
	currentScene = first_level
	
	camera.zoom = 0.5 * Vector2.ONE
	
	if start_scene > 0:
		_on_new_lg_timeout()
	
	first_level.get_node("BottomKillzone").get_node("KillZone").monitoring = true
	
	player.position = checkpoint_loc
	player.jump_point_position = checkpoint_loc
	player.bash_state = true

func _on_kill():
	player.play_death_sound()
	spawn_confetti(player.position)
	
	player.reset()
	
	player.position = checkpoint_loc
	player.jump_point_position = checkpoint_loc
	player.bash_state = true
	Signals.player_moved.emit(checkpoint_loc)

func spawn_confetti(pos):
	var confetti = confetti_preload.instantiate()
	confetti.set_position(pos)
	add_child.call_deferred(confetti)

func _new_checkpoint(loc, scene):
	#print("new checkpoint: ", loc)
	checkpoint_loc = loc
	
	currentScene = scene
	scene.get_node("BottomKillzone").get_node("KillZone").monitoring = true

func _new_lg():
	$NewLG.start()


func _on_new_lg_timeout() -> void:
	var lg_ref: Node2D = currentScene.get_parent().get_parent()
	# var next_lg_idx: int = lg_ref.name.substr(3).to_int() + 1
	# var next_lg: Node2D = lg_ref.get_parent().get_node("LG_" + str(next_lg_idx));
	
	
	if lg_ref:
		if lg_ref.name != "LG_8":
			Signals.fix_particles.emit(true)
			$FixParticles.start()
			
			var tween = get_tree().create_tween()
			tween.tween_property(lg_ref, "scale", Vector2.ONE * 1, 1.3).set_trans(Tween.TRANS_CUBIC)
	
func _on_fix_particles_timeout():
	Signals.fix_particles.emit(false)
