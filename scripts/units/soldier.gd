extends Unit
class_name SoldierUnit

var arrow_scene: PackedScene = preload("res://scenes/arrow.tscn")
var pierce_count: int = 0

func _ready() -> void:
	super._ready()
	if unit_data:
		apply_player_upgrades()

func apply_player_upgrades() -> void:
	var stats: Dictionary = GameState.player_stats
	max_hp = stats.max_hp
	hp = max_hp
	attack = stats.attack
	defense = stats.defense
	attack_speed = stats.attack_speed
	move_speed = stats.speed
	attack_range = 550.0
	_update_hp_bar()

	if GameState.has_skill(&"rapid_fire"):
		attack_speed += 0.3
	if GameState.has_skill(&"pierce_arrow"):
		pierce_count = 1

func _physics_process(_delta: float) -> void:
	if is_dead:
		return

	match current_state:
		State.IDLE, State.WALK:
			_find_target()
			if target and target.is_inside_tree() and not target.is_dead:
				_try_attack()
		State.ATTACK:
			pass

func _find_target() -> void:
	var enemies: Array[Node] = get_tree().get_nodes_in_group("enemies")
	var closest: Unit = null
	var closest_dist: float = attack_range * 2.0
	for enemy in enemies:
		if enemy is Unit and not enemy.is_dead and enemy.is_inside_tree():
			var dist: float = global_position.distance_to(enemy.global_position)
			if dist < closest_dist:
				closest_dist = dist
				closest = enemy
	target = closest

func _try_attack() -> void:
	if not can_attack() or not target:
		return
	if not target.is_inside_tree() or target.is_dead:
		target = null
		return
	var dist: float = global_position.distance_to(target.global_position)
	if dist <= attack_range:
		play_attack(&"attack")
		_fire_arrow()

func _fire_arrow() -> void:
	if not target or not target.is_inside_tree():
		return
	var arrow: Node2D = arrow_scene.instantiate()
	arrow.global_position = global_position + Vector2(20, -20)
	var dir: Vector2 = (target.global_position - global_position).normalized()
	arrow.direction = dir
	arrow.damage = get_attack_damage()
	arrow.pierce_count = pierce_count
	arrow.is_player_arrow = true
	arrow.target_unit = target
	if GameState.has_skill(&"poison_tip"):
		arrow.apply_poison = true
	get_tree().current_scene.get_node("ProjectileContainer").add_child(arrow)
	AudioManager.play_arrow_shoot()
