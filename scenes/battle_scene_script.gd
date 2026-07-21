extends Node2D

var battle_manager: Node
var wave_spawner: Node
var is_battle_over: bool = false
var current_wave: int = 0

@onready var start_timer: Timer = $StartTimer

var all_upgrades: Array[UpgradeData] = []
var shop_visible: bool = false

func _ready() -> void:
	battle_manager = $BattleManager
	wave_spawner = $WaveSpawner
	battle_manager.battle_won.connect(_on_battle_won)
	battle_manager.battle_lost.connect(_on_battle_lost)
	start_timer.timeout.connect(_on_start_timer)
	_load_upgrades()

func _on_start_timer() -> void:
	battle_manager.start_battle()

func _on_battle_won() -> void:
	is_battle_over = true
	await get_tree().create_timer(1.0).timeout
	_open_shop()

func _on_battle_lost() -> void:
	is_battle_over = true
	await get_tree().create_timer(1.5).timeout
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _load_upgrades() -> void:
	all_upgrades = [
		load("res://resources/upgrade_data/upgrade_hp.tres"),
		load("res://resources/upgrade_data/upgrade_atk.tres"),
		load("res://resources/upgrade_data/upgrade_def.tres"),
		load("res://resources/upgrade_data/upgrade_atk_speed.tres"),
		load("res://resources/upgrade_data/upgrade_crit.tres"),
		load("res://resources/upgrade_data/skill_pierce.tres"),
		load("res://resources/upgrade_data/skill_rapid_fire.tres"),
		load("res://resources/upgrade_data/skill_poison.tres"),
	]

func _open_shop() -> void:
	shop_visible = true
	_build_shop_ui()

func _build_shop_ui() -> void:
	var existing := get_node_or_null("ShopLayer")
	if existing:
		existing.queue_free()

	var layer := CanvasLayer.new()
	layer.name = "ShopLayer"
	layer.layer = 10
	add_child(layer)

	var dimmer := ColorRect.new()
	dimmer.color = Color(0, 0, 0, 0.65)
	dimmer.set_anchors_preset(Control.PRESET_FULL_RECT)
	dimmer.mouse_filter = Control.MOUSE_FILTER_STOP
	layer.add_child(dimmer)

	var panel := PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.custom_minimum_size = Vector2(420, 320)
	panel.offset_left = -210
	panel.offset_top = -160
	panel.offset_right = 210
	panel.offset_bottom = 160
	layer.add_child(panel)

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.12, 0.12, 0.18, 0.95)
	style.border_color = Color(0.8, 0.7, 0.3)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	style.content_margin_left = 16
	style.content_margin_top = 12
	style.content_margin_right = 16
	style.content_margin_bottom = 12
	panel.add_theme_stylebox_override("panel", style)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	panel.add_child(vbox)

	var title := Label.new()
	title.text = "WAVE %d CLEARED!" % GameState.current_wave
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 20)
	title.add_theme_color_override("font_color", Color(1, 0.85, 0.2))
	vbox.add_child(title)

	var gold_label := Label.new()
	gold_label.text = "Gold: %d" % GameState.gold
	gold_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	gold_label.add_theme_font_size_override("font_size", 15)
	gold_label.add_theme_color_override("font_color", Color(1, 0.85, 0.2))
	vbox.add_child(gold_label)

	var sep := HSeparator.new()
	vbox.add_child(sep)

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.custom_minimum_size = Vector2(0, 160)
	vbox.add_child(scroll)

	var upgrade_container := VBoxContainer.new()
	upgrade_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	upgrade_container.add_theme_constant_override("separation", 3)
	scroll.add_child(upgrade_container)

	for upgrade: UpgradeData in all_upgrades:
		var level: int = GameState.get_upgrade_level(upgrade.id)
		var can_buy: bool = upgrade.can_upgrade(level) and GameState.gold >= upgrade.get_cost(level)
		var visible_row: bool = GameState.current_wave >= upgrade.required_wave or upgrade.required_wave == 0
		if not visible_row:
			continue

		var row := HBoxContainer.new()

		var name_label := Label.new()
		name_label.text = upgrade.display_name
		if upgrade.is_skill:
			name_label.add_theme_color_override("font_color", Color(0.4, 0.8, 1.0))
		if upgrade.skill_id != &"" and GameState.has_skill(upgrade.skill_id):
			name_label.add_theme_color_override("font_color", Color(0.2, 1.0, 0.2))
		name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(name_label)

		var level_label := Label.new()
		if upgrade.is_skill:
			level_label.text = "SKILL"
		else:
			level_label.text = "Lv.%d/%d" % [level, upgrade.max_level]
		level_label.add_theme_font_size_override("font_size", 11)
		row.add_child(level_label)

		var cost: int = upgrade.get_cost(level)
		var btn := Button.new()
		btn.custom_minimum_size = Vector2(70, 24)
		if upgrade.skill_id != &"" and GameState.has_skill(upgrade.skill_id):
			btn.text = "DONE"
			btn.disabled = true
		elif not upgrade.can_upgrade(level):
			btn.text = "MAX"
			btn.disabled = true
		else:
			btn.text = "%d G" % cost
			btn.disabled = not can_buy
			btn.pressed.connect(_on_upgrade_pressed.bind(upgrade, gold_label))
		row.add_child(btn)

		upgrade_container.add_child(row)

	var btn_row := HBoxContainer.new()
	btn_row.alignment = BoxContainer.ALIGNMENT_CENTER
	btn_row.add_theme_constant_override("separation", 12)
	vbox.add_child(btn_row)

	var next_btn := Button.new()
	next_btn.text = "NEXT WAVE"
	next_btn.custom_minimum_size = Vector2(160, 40)
	next_btn.pressed.connect(_on_next_wave_pressed)
	btn_row.add_child(next_btn)

func _on_upgrade_pressed(upgrade: UpgradeData, gold_label: Label) -> void:
	var level: int = GameState.get_upgrade_level(upgrade.id)
	var cost: int = upgrade.get_cost(level)
	if GameState.spend_gold(cost):
		if upgrade.is_skill:
			GameState.unlock_skill(upgrade.skill_id)
		else:
			GameState.apply_upgrade(upgrade.id, upgrade.stat_key, upgrade.effect_value)
		AudioManager.play_purchase()
		GameState.save_game()
		_open_shop()

func _on_next_wave_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/battle.tscn")
