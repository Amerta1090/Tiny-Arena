extends Resource
class_name UpgradeData

@export var id: StringName = &""
@export var display_name: String = ""
@export_multiline var description: String = ""
@export var icon: Texture2D
@export var is_skill: bool = false
@export var required_wave: int = 0

@export_group("Cost")
@export var cost_base: int = 50
@export var cost_multiplier: float = 1.5

@export_group("Effect")
@export var stat_key: String = ""
@export var effect_value: float = 0.0
@export var max_level: int = 10
@export var skill_id: StringName = &""
@export var skill_description: String = ""

func get_cost(current_level: int) -> int:
	return int(cost_base * pow(cost_multiplier, current_level))

func can_upgrade(current_level: int) -> bool:
	return current_level < max_level and GameState.current_wave >= required_wave

func get_effect_at_level(level: int) -> float:
	return effect_value * level
