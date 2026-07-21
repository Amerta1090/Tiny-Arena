extends Resource
class_name UnitData

@export var id: StringName = &""
@export var display_name: String = ""
@export var max_hp: int = 100
@export var attack: int = 10
@export var defense: int = 0
@export var attack_speed: float = 1.0
@export var move_speed: float = 50.0
@export var attack_range: float = 50.0
@export var is_ranged: bool = false
@export var gold_reward: int = 10
@export var xp_reward: int = 5

@export_group("Sprites")
@export var spritesheet: Texture2D
@export var idle_sheet: Texture2D
@export var walk_sheet: Texture2D
@export var attack_sheet: Texture2D
@export var attack2_sheet: Texture2D
@export var attack3_sheet: Texture2D
@export var hurt_sheet: Texture2D
@export var death_sheet: Texture2D

@export_group("Frame Data")
@export var frame_width: int = 100
@export var frame_height: int = 100
@export var idle_frames: int = 6
@export var walk_frames: int = 8
@export var attack_frames: int = 6
@export var attack2_frames: int = 6
@export var attack3_frames: int = 0
@export var hurt_frames: int = 4
@export var death_frames: int = 4
@export var animation_speed: float = 8.0

@export_group("AI")
@export var aggro_range: float = 300.0
@export var spawn_delay: float = 0.0
