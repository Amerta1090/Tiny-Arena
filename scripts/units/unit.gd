extends CharacterBody2D
class_name Unit

signal died(unit: Unit)
signal health_changed(current: int, maximum: int)
signal attack_started()
signal attack_ended()

enum State { IDLE, WALK, ATTACK, ATTACK2, HURT, DEATH }

@export var unit_data: UnitData

var max_hp: int = 100
var hp: int = 100
var attack: int = 10
var defense: int = 0
var attack_speed: float = 1.0
var move_speed: float = 50.0
var attack_range: float = 50.0

var current_state: State = State.IDLE
var attack_cooldown: float = 0.0
var is_dead: bool = false
var target: Unit = null

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hp_bar: ProgressBar = $HPBar

var attack_timer: Timer
var hurt_timer: Timer

func _ready() -> void:
	attack_timer = Timer.new()
	attack_timer.one_shot = true
	add_child(attack_timer)
	hurt_timer = Timer.new()
	hurt_timer.one_shot = true
	hurt_timer.wait_time = 0.3
	add_child(hurt_timer)
	hurt_timer.timeout.connect(_on_hurt_timer_timeout)
	attack_timer.timeout.connect(_on_attack_timer_timeout)
	if unit_data:
		_setup_sprite()
	_update_hp_bar()

func load_from_data(data: UnitData) -> void:
	unit_data = data
	max_hp = data.max_hp
	hp = max_hp
	attack = data.attack
	defense = data.defense
	attack_speed = data.attack_speed
	move_speed = data.move_speed
	attack_range = data.attack_range
	if is_inside_tree():
		_setup_sprite()

func scale_stats(wave_number: int) -> void:
	if not unit_data:
		return
	var multiplier: float = 1.0 + (wave_number - 1) * 0.15
	max_hp = int(unit_data.max_hp * multiplier)
	hp = max_hp
	attack = int(unit_data.attack * multiplier)
	defense = int(unit_data.defense * multiplier)
	if is_inside_tree():
		_setup_sprite()
		_update_hp_bar()

func _setup_sprite() -> void:
	if not sprite or not unit_data:
		return
	sprite.sprite_frames = SpriteFrames.new()
	sprite.sprite_frames.add_animation(&"idle")
	sprite.sprite_frames.set_animation_speed(&"idle", unit_data.animation_speed)
	sprite.sprite_frames.set_animation_loop(&"idle", true)
	_add_frames(&"idle", unit_data.idle_sheet, unit_data.idle_frames)

	sprite.sprite_frames.add_animation(&"walk")
	sprite.sprite_frames.set_animation_speed(&"walk", unit_data.animation_speed)
	sprite.sprite_frames.set_animation_loop(&"walk", true)
	_add_frames(&"walk", unit_data.walk_sheet, unit_data.walk_frames)

	sprite.sprite_frames.add_animation(&"attack")
	sprite.sprite_frames.set_animation_speed(&"attack", unit_data.animation_speed)
	sprite.sprite_frames.set_animation_loop(&"attack", false)
	_add_frames(&"attack", unit_data.attack_sheet, unit_data.attack_frames)

	if unit_data.attack2_sheet:
		sprite.sprite_frames.add_animation(&"attack2")
		sprite.sprite_frames.set_animation_speed(&"attack2", unit_data.animation_speed)
		sprite.sprite_frames.set_animation_loop(&"attack2", false)
		_add_frames(&"attack2", unit_data.attack2_sheet, unit_data.attack2_frames)

	if unit_data.attack3_sheet:
		sprite.sprite_frames.add_animation(&"attack3")
		sprite.sprite_frames.set_animation_speed(&"attack3", unit_data.animation_speed)
		sprite.sprite_frames.set_animation_loop(&"attack3", false)
		_add_frames(&"attack3", unit_data.attack3_sheet, unit_data.attack3_frames)

	sprite.sprite_frames.add_animation(&"hurt")
	sprite.sprite_frames.set_animation_speed(&"hurt", unit_data.animation_speed)
	sprite.sprite_frames.set_animation_loop(&"hurt", false)
	_add_frames(&"hurt", unit_data.hurt_sheet, unit_data.hurt_frames)

	sprite.sprite_frames.add_animation(&"death")
	sprite.sprite_frames.set_animation_speed(&"death", unit_data.animation_speed * 0.5)
	sprite.sprite_frames.set_animation_loop(&"death", false)
	_add_frames(&"death", unit_data.death_sheet, unit_data.death_frames)

	sprite.play(&"idle")

func _add_frames(anim_name: StringName, sheet: Texture2D, frame_count: int) -> void:
	if not sheet:
		return
	var frame_width: int = unit_data.frame_width
	var frame_height: int = unit_data.frame_height
	for i in frame_count:
		var region := Rect2(i * frame_width, 0, frame_width, frame_height)
		var atlas := AtlasTexture.new()
		atlas.atlas = sheet
		atlas.region = region
		sprite.sprite_frames.add_frame(anim_name, atlas)

func take_damage(amount: int) -> int:
	if is_dead:
		return 0
	var reduction: float = defense * 0.4
	var dmg: int = maxi(1, amount - int(reduction))
	var variance: float = randf_range(0.9, 1.1)
	dmg = int(dmg * variance)
	dmg = maxi(1, dmg)
	hp = maxi(0, hp - dmg)
	health_changed.emit(hp, max_hp)
	_update_hp_bar()
	_show_damage_number(dmg, false)
	if hp <= 0:
		die()
	else:
		play_hurt()
	return dmg

func heal(amount: int) -> void:
	hp = mini(hp + amount, max_hp)
	health_changed.emit(hp, max_hp)
	_update_hp_bar()

func die() -> void:
	if is_dead:
		return
	is_dead = true
	current_state = State.DEATH
	target = null
	AudioManager.play_enemy_death()
	sprite.play(&"death")
	await sprite.animation_finished
	died.emit(self)
	queue_free()

func play_hurt() -> void:
	if current_state == State.DEATH:
		return
	current_state = State.HURT
	var saved_flip: bool = sprite.flip_h
	sprite.play(&"hurt")
	sprite.flip_h = saved_flip
	sprite.modulate = Color.RED
	hurt_timer.start()

func play_attack(anim: StringName = &"attack") -> void:
	if current_state == State.DEATH:
		return
	current_state = State.ATTACK
	attack_started.emit()
	sprite.play(anim)
	var anim_duration: float = sprite.sprite_frames.get_frame_count(anim) / sprite.sprite_frames.get_animation_speed(anim)
	attack_timer.wait_time = anim_duration / attack_speed
	attack_timer.start()

func _on_hurt_timer_timeout() -> void:
	sprite.modulate = Color.WHITE
	if not is_dead and current_state == State.HURT:
		current_state = State.IDLE
		sprite.play(&"idle")

func _on_attack_timer_timeout() -> void:
	if not is_dead and current_state == State.ATTACK:
		current_state = State.IDLE
		attack_ended.emit()
		sprite.play(&"idle")

func _update_hp_bar() -> void:
	if hp_bar:
		hp_bar.max_value = max_hp
		hp_bar.value = hp
		hp_bar.visible = hp < max_hp and hp > 0
		_style_hp_bar()

func _style_hp_bar() -> void:
	if not hp_bar:
		return
	var fill_style: StyleBoxFlat = StyleBoxFlat.new()
	var ratio: float = float(hp) / float(max_hp) if max_hp > 0 else 0.0
	if ratio > 0.5:
		fill_style.bg_color = Color(0.2, 0.8, 0.2)
	elif ratio > 0.25:
		fill_style.bg_color = Color(0.9, 0.7, 0.1)
	else:
		fill_style.bg_color = Color(0.9, 0.2, 0.2)
	fill_style.corner_radius_top_left = 2
	fill_style.corner_radius_top_right = 2
	fill_style.corner_radius_bottom_left = 2
	fill_style.corner_radius_bottom_right = 2
	hp_bar.add_theme_stylebox_override("fill", fill_style)

	var bg_style: StyleBoxFlat = StyleBoxFlat.new()
	bg_style.bg_color = Color(0.15, 0.15, 0.15)
	bg_style.corner_radius_top_left = 2
	bg_style.corner_radius_top_right = 2
	bg_style.corner_radius_bottom_left = 2
	bg_style.corner_radius_bottom_right = 2
	hp_bar.add_theme_stylebox_override("background", bg_style)

func get_attack_damage() -> int:
	var crit_chance: float = 0.05
	var crit_multiplier: float = 1.5
	if is_in_group("player"):
		crit_chance = GameState.player_stats.get("crit_chance", 0.05)
		crit_multiplier = GameState.player_stats.get("crit_multiplier", 1.5)
	var is_crit: bool = randf() < crit_chance
	var dmg: int = attack
	if is_crit:
		dmg = int(dmg * crit_multiplier)
	return dmg

func can_attack() -> bool:
	return attack_timer.is_stopped() and not is_dead and current_state != State.DEATH

func _show_damage_number(amount: int, is_crit: bool = false) -> void:
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
	label.text = str(amount)
	if is_crit:
		label.text += "!"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.position = global_position + Vector2(randf_range(-10, 10), -50)
	if is_crit:
		label.add_theme_font_size_override("font_size", 16)
		label.add_theme_color_override("font_color", Color(1.0, 0.2, 0.2))
	else:
		label.add_theme_font_size_override("font_size", 12)
		label.add_theme_color_override("font_color", Color.WHITE)
	label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.8))
	label.add_theme_constant_override("shadow_offset_x", 1)
	label.add_theme_constant_override("shadow_offset_y", 1)
	floating_layer.add_child(label)
	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(label, "position:y", label.position.y - 30, 0.5).set_ease(Tween.EASE_OUT)
	tween.tween_property(label, "modulate:a", 0.0, 0.5).set_delay(0.15)
	tween.chain().tween_callback(label.queue_free)

func _physics_process(_delta: float) -> void:
	pass
