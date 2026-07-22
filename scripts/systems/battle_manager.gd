extends Node

signal battle_won()
signal battle_lost()

var soldier_scene: PackedScene = preload("res://scenes/soldier.tscn")
var wave_spawner: Node
var soldier: Unit
var is_battle_active: bool = false
var all_spawned: bool = false
var check_timer: Timer

func _ready() -> void:
	wave_spawner = get_node_or_null("../WaveSpawner")
	check_timer = Timer.new()
	check_timer.wait_time = 0.3
	check_timer.one_shot = false
	add_child(check_timer)
	check_timer.timeout.connect(_on_check_tick)

func start_battle() -> void:
	GameState.start_battle()
	is_battle_active = true
	all_spawned = false
	_spawn_soldier()
	if wave_spawner:
		wave_spawner.all_enemies_spawned.connect(_on_all_spawned)
		wave_spawner.start_wave(GameState.current_wave)
	check_timer.start()

func _on_all_spawned() -> void:
	all_spawned = true

func _spawn_soldier() -> void:
	soldier = soldier_scene.instantiate()
	soldier.global_position = Vector2(80, 288)
	soldier.died.connect(_on_soldier_died)
	get_tree().current_scene.add_child(soldier)

func _on_check_tick() -> void:
	if not is_battle_active:
		return
	if not all_spawned:
		return
	var enemies: Array[Node] = get_tree().get_nodes_in_group("enemies")
	var alive_enemies: Array[Node] = enemies.filter(func(e): return e is Unit and not e.is_dead)
	if alive_enemies.is_empty():
		_on_wave_cleared()

func _on_wave_cleared() -> void:
	is_battle_active = false
	check_timer.stop()
	GameState.end_battle(true)
	battle_won.emit()
	AudioManager.play_wave_complete()

func _on_soldier_died(_unit: Unit) -> void:
	is_battle_active = false
	check_timer.stop()
	GameState.end_battle(false)
	battle_lost.emit()
