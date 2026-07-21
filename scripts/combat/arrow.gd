extends Node2D

var direction: Vector2 = Vector2.RIGHT
var speed: float = 350.0
var damage: int = 10
var pierce_count: int = 0
var is_player_arrow: bool = true
var apply_poison: bool = false
var hits: Array = []
var target_unit: Unit = null

@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	rotation = direction.angle()

func _physics_process(delta: float) -> void:
	if target_unit and is_instance_valid(target_unit) and not target_unit.is_dead:
		direction = (target_unit.global_position + Vector2(0, -20) - global_position).normalized()
		rotation = direction.angle()

	position += direction * speed * delta

	if position.x > 700 or position.x < -100 or position.y > 400 or position.y < -100:
		queue_free()
		return

	if is_player_arrow:
		_check_enemy_hits()

func _check_enemy_hits() -> void:
	var enemies: Array[Node] = get_tree().get_nodes_in_group("enemies")
	for enemy_node in enemies:
		if enemy_node is Unit and not enemy_node.is_dead and enemy_node not in hits:
			var enemy_center: Vector2 = enemy_node.global_position + Vector2(0, -20)
			var dist: float = global_position.distance_to(enemy_center)
			if dist < 20.0:
				hits.append(enemy_node)
				enemy_node.take_damage(damage)
				if apply_poison:
					_apply_poison_effect(enemy_node)
				if pierce_count <= 0:
					queue_free()
					return
				else:
					pierce_count -= 1

func _apply_poison_effect(target: Unit) -> void:
	var poison_damage: int = 3
	var duration: float = 3.0
	var tick_interval: float = 1.0
	var elapsed: float = 0.0
	while elapsed < duration:
		await get_tree().create_timer(tick_interval).timeout
		elapsed += tick_interval
		if is_instance_valid(target) and not target.is_dead:
			target.take_damage(poison_damage)
		else:
			break
