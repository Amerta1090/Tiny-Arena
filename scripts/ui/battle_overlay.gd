extends CanvasLayer

var overlay_label: Label
var is_showing: bool = false

func _ready() -> void:
	layer = 15
	
	overlay_label = Label.new()
	overlay_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	overlay_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	overlay_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay_label.visible = false
	add_child(overlay_label)

func show_victory() -> void:
	_show_overlay("VICTORY", Color(1, 0.85, 0.2))

func show_defeat() -> void:
	_show_overlay("DEFEAT", Color(1, 0.2, 0.2))

func _show_overlay(text: String, color: Color) -> void:
	if is_showing:
		return
	
	is_showing = true
	
	overlay_label.text = text
	overlay_label.add_theme_font_size_override("font_size", 48)
	overlay_label.add_theme_color_override("font_color", color)
	overlay_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.8))
	overlay_label.add_theme_constant_override("shadow_offset_x", 3)
	overlay_label.add_theme_constant_override("shadow_offset_y", 3)
	overlay_label.scale = Vector2(0.1, 0.1)
	overlay_label.modulate.a = 0.0
	overlay_label.visible = true
	
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(overlay_label, "scale", Vector2(1.3, 1.3), 0.4).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(overlay_label, "modulate:a", 1.0, 0.3)
	tween.chain().tween_interval(2.0)
	tween.tween_property(overlay_label, "modulate:a", 0.0, 0.5)
	tween.tween_callback(_on_overlay_finished)

func _on_overlay_finished() -> void:
	overlay_label.visible = false
	is_showing = false
