extends Node

static func apply_button_effects(btn: Button) -> void:
	btn.mouse_entered.connect(_on_hover.bind(btn))
	btn.mouse_exited.connect(_on_unhover.bind(btn))
	btn.button_down.connect(_on_press.bind(btn))
	btn.button_up.connect(_on_release.bind(btn))

static func _on_hover(btn: Button) -> void:
	if btn.disabled:
		return
	var tween := btn.create_tween()
	tween.set_parallel(true)
	tween.tween_property(btn, "scale", Vector2(1.05, 1.05), 0.1)
	tween.tween_property(btn, "modulate", Color(1.2, 1.2, 1.2), 0.1)

static func _on_unhover(btn: Button) -> void:
	var tween := btn.create_tween()
	tween.set_parallel(true)
	tween.tween_property(btn, "scale", Vector2(1.0, 1.0), 0.1)
	tween.tween_property(btn, "modulate", Color.WHITE, 0.1)

static func _on_press(btn: Button) -> void:
	if btn.disabled:
		return
	var tween := btn.create_tween()
	tween.tween_property(btn, "scale", Vector2(0.95, 0.95), 0.05)

static func _on_release(btn: Button) -> void:
	var tween := btn.create_tween()
	tween.tween_property(btn, "scale", Vector2(1.05, 1.05), 0.05)
