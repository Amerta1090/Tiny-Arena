extends CanvasLayer

var color_rect: ColorRect
var is_transitioning: bool = false

func _ready() -> void:
	layer = 100
	
	color_rect = ColorRect.new()
	color_rect.color = Color.BLACK
	color_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	color_rect.modulate.a = 0.0
	add_child(color_rect)

func fade_to_black(callback: Callable, duration: float = 0.5) -> void:
	if is_transitioning:
		return
	is_transitioning = true
	color_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	
	var tween := create_tween()
	tween.tween_property(color_rect, "modulate:a", 1.0, duration / 2.0)
	tween.tween_callback(callback)
	tween.tween_property(color_rect, "modulate:a", 0.0, duration / 2.0)
	tween.tween_callback(_on_transition_complete)

func _on_transition_complete() -> void:
	is_transitioning = false
	color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE

func change_scene(path: String) -> void:
	fade_to_black(func(): get_tree().change_scene_to_file(path))
