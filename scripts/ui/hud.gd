extends CanvasLayer

@onready var wave_label: Label = %WaveLabel
@onready var gold_label: Label = %GoldLabel
@onready var hp_label: Label = %HPLabel
@onready var enemy_count_label: Label = %EnemyCountLabel

func _ready() -> void:
	GameState.wave_changed.connect(_on_wave_changed)
	GameState.gold_changed.connect(_on_gold_changed)
	GameState.stats_changed.connect(_on_stats_changed)
	_update_all()

func _update_all() -> void:
	_on_wave_changed(GameState.current_wave)
	_on_gold_changed(GameState.gold)
	_on_stats_changed()

func _on_wave_changed(wave: int) -> void:
	if wave_label:
		wave_label.text = "WAVE %d" % wave

func _on_gold_changed(value: int) -> void:
	if gold_label:
		gold_label.text = "Gold: %d" % value

func _on_stats_changed() -> void:
	if hp_label:
		hp_label.text = "HP: %d/%d" % [GameState.current_hp, GameState.player_stats.max_hp]
	if enemy_count_label:
		var enemies: Array[Node] = get_tree().get_nodes_in_group("enemies")
		var alive: int = 0
		for e in enemies:
			if e is Unit and not e.is_dead:
				alive += 1
		enemy_count_label.text = "Enemies: %d" % alive
