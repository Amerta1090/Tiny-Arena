extends Node

var shake_camera: Camera2D = null
var original_offset: Vector2 = Vector2.ZERO

func setup_camera(camera: Camera2D) -> void:
	shake_camera = camera
	original_offset = camera.offset

func shake(intensity: float = 3.0, duration: float = 0.15) -> void:
	if not shake_camera:
		return
	
	var tween := create_tween()
	var steps: int = 6
	var step_duration: float = duration / steps
	
	for i in steps:
		var random_offset := Vector2(randf_range(-intensity, intensity), randf_range(-intensity, intensity))
		tween.tween_property(shake_camera, "offset", original_offset + random_offset, step_duration)
	
	tween.tween_property(shake_camera, "offset", original_offset, 0.05)

func shake_hit() -> void:
	shake(2.0, 0.1)

func shake_kill() -> void:
	shake(4.0, 0.15)

func shake_boss() -> void:
	shake(8.0, 0.3)
