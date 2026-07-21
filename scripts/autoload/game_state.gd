extends Node

signal gold_changed(value: int)
signal wave_changed(wave: int)
signal stats_changed()
signal game_over(won: bool)
signal battle_started()
signal battle_ended(won: bool)
signal shop_entered()
signal shop_exited()

const SAVE_VERSION: int = 1
const SAVE_PATH: String = "user://save.json"

var current_wave: int = 0
var gold: int = 0
var total_gold_earned: int = 0

var player_stats: Dictionary = {
	"max_hp": 100,
	"attack": 15,
	"defense": 5,
	"speed": 60.0,
	"attack_speed": 1.0,
	"crit_chance": 0.05,
	"crit_multiplier": 1.5,
}

var current_hp: int = 100

var upgrade_levels: Dictionary = {}
var unlocked_skills: Array[String] = []

var is_battle_active: bool = false
var enemies_alive: int = 0

func _ready() -> void:
	load_game()

func add_gold(amount: int) -> void:
	gold += amount
	total_gold_earned += amount
	gold_changed.emit(gold)

func spend_gold(amount: int) -> bool:
	if gold >= amount:
		gold -= amount
		gold_changed.emit(gold)
		return true
	return false

func get_upgrade_level(upgrade_id: String) -> int:
	return upgrade_levels.get(upgrade_id, 0)

func apply_upgrade(upgrade_id: String, stat_key: String, value: float) -> void:
	upgrade_levels[upgrade_id] = get_upgrade_level(upgrade_id) + 1
	if stat_key in player_stats:
		player_stats[stat_key] += value
	stats_changed.emit()

func unlock_skill(skill_id: String) -> void:
	if skill_id not in unlocked_skills:
		unlocked_skills.append(skill_id)
		stats_changed.emit()

func has_skill(skill_id: String) -> bool:
	return skill_id in unlocked_skills

func start_battle() -> void:
	current_wave += 1
	is_battle_active = true
	current_hp = player_stats.max_hp
	wave_changed.emit(current_wave)
	battle_started.emit()

func end_battle(won: bool) -> void:
	is_battle_active = false
	if won:
		add_gold(calculate_wave_reward())
	battle_ended.emit(won)
	game_over.emit(won)

func calculate_wave_reward() -> int:
	return 10 + (current_wave * 5)

func take_damage(amount: int) -> int:
	var reduction: float = player_stats.defense * 0.4
	var dmg: int = maxi(1, amount - int(reduction))
	var variance: float = randf_range(0.9, 1.1)
	dmg = int(dmg * variance)
	current_hp = maxi(0, current_hp - dmg)
	stats_changed.emit()
	return dmg

func heal(amount: int) -> void:
	current_hp = mini(current_hp + amount, player_stats.max_hp)
	stats_changed.emit()

func reset_game() -> void:
	current_wave = 0
	gold = 0
	total_gold_earned = 0
	player_stats = {
		"max_hp": 100,
		"attack": 15,
		"defense": 5,
		"speed": 60.0,
		"attack_speed": 1.0,
		"crit_chance": 0.05,
		"crit_multiplier": 1.5,
	}
	current_hp = 100
	upgrade_levels = {}
	unlocked_skills = []
	is_battle_active = false
	enemies_alive = 0

func save_game() -> void:
	var data: Dictionary = {
		"version": SAVE_VERSION,
		"current_wave": current_wave,
		"gold": gold,
		"total_gold_earned": total_gold_earned,
		"player_stats": player_stats.duplicate(),
		"current_hp": current_hp,
		"upgrade_levels": upgrade_levels.duplicate(),
		"unlocked_skills": unlocked_skills.duplicate(),
	}
	var tmp_path: String = SAVE_PATH + ".tmp"
	var file := FileAccess.open(tmp_path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data, "\t"))
		file.flush()
		file.close()
		DirAccess.rename_absolute(tmp_path, SAVE_PATH)

func load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		return
	var json := JSON.new()
	var err: int = json.parse(file.get_as_text())
	file.close()
	if err != OK:
		return
	var data: Dictionary = json.data
	if not data is Dictionary:
		return
	var version: int = data.get("version", 0)
	if version > SAVE_VERSION:
		return
	current_wave = data.get("current_wave", 0)
	gold = data.get("gold", 0)
	total_gold_earned = data.get("total_gold_earned", 0)
	current_hp = data.get("current_hp", 100)
	var loaded_stats: Dictionary = data.get("player_stats", {})
	for key in loaded_stats:
		if key in player_stats:
			player_stats[key] = loaded_stats[key]
	upgrade_levels = data.get("upgrade_levels", {})
	var loaded_skills: Array = data.get("unlocked_skills", [])
	unlocked_skills.clear()
	for s in loaded_skills:
		unlocked_skills.append(str(s))

func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)
