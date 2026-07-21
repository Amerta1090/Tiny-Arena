extends Node

signal wave_started(wave_num: int)
signal all_enemies_spawned()
signal enemy_spawned(enemy: Unit)

var orc_grunt: PackedScene = preload("res://scenes/orc.tscn")
var spawning_complete: bool = false

func start_wave(wave_number: int) -> void:
	spawning_complete = false
	wave_started.emit(wave_number)
	var groups: Array[Dictionary] = _get_wave_groups(wave_number)
	var spawn_queue: Array[Dictionary] = []
	for group in groups:
		var count: int = group.get("count", 1)
		var unit_id: StringName = group.get("unit_id", &"orc_grunt")
		for i in count:
			spawn_queue.append({"unit_id": unit_id, "delay": group.get("delay", 0.8)})
	spawn_queue.shuffle()
	_spawn_next(spawn_queue, 0)

func _spawn_next(queue: Array[Dictionary], index: int) -> void:
	if index >= queue.size():
		spawning_complete = true
		all_enemies_spawned.emit()
		return
	var entry: Dictionary = queue[index]
	var delay: float = entry.get("delay", 0.8)
	await get_tree().create_timer(delay).timeout
	var enemy: Unit = _spawn_enemy(entry.get("unit_id", &"orc_grunt"))
	if enemy:
		GameState.enemies_alive += 1
		enemy_spawned.emit(enemy)
	_spawn_next(queue, index + 1)

func _spawn_enemy(unit_id: StringName) -> Unit:
	var enemy: Unit = orc_grunt.instantiate()
	match unit_id:
		&"orc_brute":
			enemy.unit_data = load("res://resources/unit_data/orc_brute.tres")
		&"orc_boss":
			enemy.unit_data = load("res://resources/unit_data/orc_boss.tres")
		_:
			enemy.unit_data = load("res://resources/unit_data/orc_grunt.tres")
	enemy.scale_stats(GameState.current_wave)
	var spawn_x: float = randf_range(520, 620)
	var spawn_y: float = 240
	enemy.global_position = Vector2(spawn_x, spawn_y)
	get_tree().current_scene.add_child(enemy)
	return enemy

func _get_wave_groups(wave: int) -> Array[Dictionary]:
	var groups: Array[Dictionary] = []
	var is_boss: bool = wave % 5 == 0
	if is_boss:
		groups.append({"unit_id": &"orc_boss", "count": 1, "delay": 1.0})
		groups.append({"unit_id": &"orc_grunt", "count": maxi(1, wave / 5), "delay": 0.6})
	else:
		var grunt_count: int = 2 + wave / 3
		groups.append({"unit_id": &"orc_grunt", "count": grunt_count, "delay": 0.8})
		if wave >= 3:
			var brute_count: int = wave / 4
			groups.append({"unit_id": &"orc_brute", "count": brute_count, "delay": 1.0})
	return groups
