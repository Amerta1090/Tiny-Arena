extends CanvasLayer

var banner_label: Label
var is_showing: bool = false

func _ready() -> void:
	layer = 20
	
	banner_label = Label.new()
	banner_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	banner_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	banner_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	banner_label.visible = false
	add_child(banner_label)

func show_wave_banner(wave: int, is_boss: bool = false) -> void:
	if is_showing:
		return
	
	is_showing = true
	
	var text: String = "WAVE %d" % wave
	if is_boss:
		text += " — BOSS!"
	
	banner_label.text = text
	banner_label.add_theme_font_size_override("font_size", 32 if is_boss else 24)
	banner_label.add_theme_color_override("font_color", Color(1, 0.2, 0.2) if is_boss else Color(1, 0.85, 0.2))
	banner_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.8))
	banner_label.add_theme_constant_override("shadow_offset_x", 2)
	banner_label.add_theme_constant_override("shadow_offset_y", 2)
	banner_label.scale = Vector2(0.1, 0.1)
	banner_label.modulate.a = 0.0
	banner_label.visible = true
	
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(banner_label, "scale", Vector2(1.2, 1.2), 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(banner_label, "modulate:a", 1.0, 0.2)
	tween.chain().tween_interval(1.5)
	tween.tween_property(banner_label, "modulate:a", 0.0, 0.3)
	tween.tween_callback(_on_banner_finished)

func _on_banner_finished() -> void:
	banner_label.visible = false
	is_showing = false
