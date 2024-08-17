extends Node2D

var stack_height = 0
var current = 0 # current height
var unit_height = -720.0
var loaded_levels := []
var level_groups := []

var base_preload = preload("res://game/base.tscn")
var player_preload = preload("res://entity/player/player.tscn")
var camera_preload = preload("res://entity/player/camera.tscn")
var bottom_kill_zone_preload = preload("res://entity/object/bottom_kill_zone.tscn")
var level_entry_preload = preload("res://entity/object/level_entry.tscn")
var level_exit_preload = preload("res://entity/object/level_exit.tscn")
var filler = preload("res://level/filler.tscn")

@onready var permanent := $Permanent
@onready var ephemeral := $Ephemeral

var unpause_flag = false
var delete_flag = false

var current_level_group_index = 0

var kill_zone
var level_entry
var level_exit
var player
var camera

func _ready():
	Signals.kill.connect(_on_kill)
	Signals.can_unlock_next.connect(_on_can_unlock_next)
	Signals.level_exit.connect(_on_level_exit)
	Signals.level_enter.connect(_on_level_enter)
	init()

func _on_kill():
	loaded_levels.clear()
	
	for child in ephemeral.get_children():
		child.queue_free()
	
	stack_height = 0
	current = 0
	
	var level_groups_copy = level_groups.duplicate()
	level_groups.clear()
	
	for level_group in level_groups_copy:
		load_next_level_group(level_group)
	
	unpause_first_level_group()
	
	setup_player()

# FIXED
func unpause_first_level_group():
	var levels_in_first_group = len(level_groups[current_level_group_index])
	var offset = 0 if current_level_group_index == 0 else len(level_groups[0]) + 1
	
	var i = 0
	while i < levels_in_first_group:
		loaded_levels[offset + i].set_process_mode(ProcessMode.PROCESS_MODE_INHERIT)
		i += 1
	

func _on_can_unlock_next():
	unpause_flag = true

# FIXED
func _on_level_exit():
	if unpause_flag and len(level_groups) > current_level_group_index + 1:
		unpause_flag = false
		delete_flag = true
		var current_level_group = level_groups[current_level_group_index]
		var next_level_group = level_groups[current_level_group_index + 1]
		var unpause_start_index = len(current_level_group) + 1
		var unpause_end_index = len(next_level_group)
		
		var i = 0
		while i < unpause_end_index:
			var index_to_unpause = unpause_start_index + i
			loaded_levels[index_to_unpause].set_process_mode(ProcessMode.PROCESS_MODE_INHERIT)
			i += 1

func _on_level_enter():
	if delete_flag:
		load_next_level_group([
			"res://level/debug_3.tscn"
		])
		
		delete_flag = false
		
		current += len(level_groups[current_level_group_index]) + 1
		setup_entry_and_exit()
		
		if current_level_group_index == 1:
			var first_level_group = level_groups[0]
			var levels_in_first_group = len(first_level_group)
			
			var i = 0
			while i < levels_in_first_group + 1:
				var level_to_free = loaded_levels.pop_front()
				if is_instance_valid(level_to_free):
					level_to_free.queue_free()
			
			level_groups.pop_front()
		
		if current_level_group_index == 0:
			current_level_group_index = 1

func init():
	var base = base_preload.instantiate()
	permanent.add_child(base)
	
	kill_zone = bottom_kill_zone_preload.instantiate()
	permanent.add_child(kill_zone)
	
	level_entry = level_entry_preload.instantiate()
	permanent.add_child(level_entry)
	
	level_exit = level_exit_preload.instantiate()
	permanent.add_child(level_exit)
	
	load_next_level_group([
		"res://level/debug_1.tscn"
	])
	
	unpause_first_level_group()
	
	load_next_level_group([
		"res://level/debug_2.tscn"
	])
	
	setup_entry_and_exit()
	
	camera = camera_preload.instantiate()
	camera.set_position(Vector2(640, -400))
	permanent.add_child.call_deferred(camera)
	
	setup_player()

# FIXED
func setup_entry_and_exit():
	var current_level_group = level_groups[current_level_group_index]
	var current_level_height = current + len(current_level_group)
	var current_level_height_plus_one = current_level_height + 1
	var actual_current_level_height = current_level_height * unit_height
	var actual_current_level_height_plus_one = current_level_height_plus_one * unit_height
	level_exit.set_position(Vector2(0, actual_current_level_height))
	level_entry.set_position(Vector2(0, actual_current_level_height_plus_one))

func setup_player():
	var spawn_pos = get_spawn_pos()
	player = player_preload.instantiate()
	player.set_position(spawn_pos)
	ephemeral.add_child.call_deferred(player)
	await player.ready
	
	player.set_first_jump_in_level()
	camera.tracking = spawn_pos
	camera.tracking_flag = true
	camera._on_player_entered_bash_state()

func get_spawn_pos():
	var current_level = loaded_levels[0]
	var spawnpoint = current_level.get_node("SpawnJumpPoint")
	
	if is_instance_valid(spawnpoint):
		var spawnpoint_pos = spawnpoint.get_global_position()
		spawnpoint_pos.y += 32.0
		return spawnpoint_pos
	else:
		return Vector2(640, -400)


func load_next_level_group(level_group):
	level_groups.append(level_group)
	
	for level_to_load in level_group:
		var loaded_level = load(level_to_load)
		load_next_level(loaded_level)
		
	load_next_level(filler)


func load_next_level(loaded_level):
	var loaded_level_instance = loaded_level.instantiate()
	stack_height += 1
	var total_height = unit_height * stack_height
	loaded_level_instance.set_position(Vector2(0, total_height))
	loaded_level_instance.set_process_mode(ProcessMode.PROCESS_MODE_DISABLED)
	ephemeral.add_child(loaded_level_instance)
	loaded_levels.append(loaded_level_instance)
