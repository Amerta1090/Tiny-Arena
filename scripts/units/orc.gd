extends Unit
class_name OrcUnit

var attack_pattern: int = 0

func _ready() -> void:
	super._ready()
	add_to_group("enemies")
	died.connect(_on_orc_died)

func _physics_process(delta: float) -> void:
	if is_dead:
		return

	match current_state:
		State.IDLE:
			_start_walking()
		State.WALK:
			_move_toward_player(delta)
			_check_attack_range()
		State.ATTACK:
			pass

func _start_walking() -> void:
	current_state = State.WALK
	sprite.play(&"walk")

func _move_toward_player(_delta: float) -> void:
	var soldier: Array[Node] = get_tree().get_nodes_in_group("player")
	if soldier.is_empty():
		return
	var target_unit: Unit = soldier[0] as Unit
	if not target_unit or target_unit.is_dead:
		return
	var dir_x: float = sign(target_unit.global_position.x - global_position.x)
	velocity = Vector2(dir_x * move_speed, 0)
	move_and_slide()

	if dir_x < 0:
		sprite.flip_h = true
	elif dir_x > 0:
		sprite.flip_h = false

func _check_attack_range() -> void:
	var soldier: Array[Node] = get_tree().get_nodes_in_group("player")
	if soldier.is_empty():
		return
	var target_unit: Unit = soldier[0] as Unit
	if not target_unit or target_unit.is_dead:
		return
	var dist: float = global_position.distance_to(target_unit.global_position)
	if dist <= attack_range:
		_do_attack(target_unit)

func _do_attack(target_unit: Unit) -> void:
	if not can_attack():
		return
	current_state = State.ATTACK
	var anim: StringName = &"attack"
	if attack_pattern == 1 and unit_data.attack2_sheet:
		anim = &"attack2"
	attack_pattern = (attack_pattern + 1) % 2
	play_attack(anim)
	AudioManager.play_hit()
	await sprite.animation_finished
	if not is_dead and is_instance_valid(target_unit) and not target_unit.is_dead:
		var dmg: int = get_attack_damage()
		target_unit.take_damage(dmg)

func _on_orc_died(unit: Unit) -> void:
	remove_from_group("enemies")
	GameState.enemies_alive -= 1
	if unit.unit_data:
		GameState.add_gold(unit.unit_data.gold_reward)
		_show_gold_number(unit.unit_data.gold_reward)

func _show_gold_number(amount: int) -> void:
	var scene: Node = get_tree().current_scene
	if not scene:
		return
	var floating_layer: CanvasLayer = scene.get_node_or_null("FloatingTextLayer")
	if not floating_layer:
		floating_layer = CanvasLayer.new()
		floating_layer.name = "FloatingTextLayer"
		floating_layer.layer = 8
		scene.add_child(floating_layer)
	var label := Label.new()
	label.text = "+%dG" % amount
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.position = global_position + Vector2(randf_range(-5, 5), -65)
	label.add_theme_font_size_override("font_size", 14)
	label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2))
	label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.8))
	label.add_theme_constant_override("shadow_offset_x", 1)
	label.add_theme_constant_override("shadow_offset_y", 1)
	floating_layer.add_child(label)
	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(label, "position:y", label.position.y - 40, 0.8).set_ease(Tween.EASE_OUT)
	tween.tween_property(label, "modulate:a", 0.0, 0.8).set_delay(0.3)
	tween.chain().tween_callback(label.queue_free)
