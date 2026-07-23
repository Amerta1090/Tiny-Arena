extends CanvasLayer

@export var background_folder: String = "res://assets/background/nature_1/"

var cloud_a: Sprite2D
var cloud_b: Sprite2D
var viewport_size: Vector2
var cloud_speed: float = 10.0

func _ready() -> void:
	layer = -1
	viewport_size = Vector2(
		ProjectSettings.get_setting("display/window/size/viewport_width"),
		ProjectSettings.get_setting("display/window/size/viewport_height")
	)
	_build_layers()

func set_background(folder: String) -> void:
	background_folder = folder
	for child in get_children():
		child.queue_free()
	cloud_a = null
	cloud_b = null
	_build_layers()

func _build_layers() -> void:
	var layers: Array[Dictionary] = _detect_layers()
	for ld in layers:
		var tex: Texture2D = load(background_folder + ld["file"])
		if not tex:
			push_warning("ParallaxBG: failed to load " + ld["file"])
			continue

		if ld.get("is_clouds", false):
			_create_cloud_pair(tex, ld["z_index"])
		else:
			var sprite := Sprite2D.new()
			sprite.texture = tex
			sprite.centered = false
			sprite.z_index = ld["z_index"]
			var ts: Vector2 = tex.get_size()
			sprite.scale = Vector2(viewport_size.x / ts.x, viewport_size.y / ts.y)
			add_child(sprite)

func _detect_layers() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var dir: DirAccess = DirAccess.open(background_folder)
	if not dir:
		push_warning("ParallaxBG: cannot open folder " + background_folder)
		return result

	dir.list_dir_begin()
	var file_name: String = dir.get_next()
	while file_name != "":
		if file_name.ends_with(".png") and not file_name.begins_with("orig"):
			var lower: String = file_name.to_lower()
			if "kosongan" in lower:
				file_name = dir.get_next()
				continue

			var z_idx: int = _extract_layer_number(file_name)
			if z_idx < 0:
				file_name = dir.get_next()
				continue

			var is_clouds: bool = "clouds" in lower or "awan" in lower
			result.append({"file": file_name, "z_index": z_idx, "is_clouds": is_clouds})
		file_name = dir.get_next()
	dir.list_dir_end()

	result.sort_custom(func(a, b): return a["z_index"] < b["z_index"])
	return result

func _extract_layer_number(filename: String) -> int:
	var lower: String = filename.to_lower()
	var idx: int = lower.find("layer ")
	if idx < 0:
		return -1
	var after_layer: String = lower.substr(idx + 6)
	var num_str: String = ""
	for c in after_layer:
		if c >= "0" and c <= "9":
			num_str += c
		else:
			break
	if num_str.is_empty():
		return -1
	return num_str.to_int()

func _create_cloud_pair(tex: Texture2D, z_idx: int) -> void:
	var ts: Vector2 = tex.get_size()
	var sc: Vector2 = Vector2(viewport_size.x / ts.x, viewport_size.y / ts.y)
	var tex_w: float = ts.x * sc.x

	cloud_a = Sprite2D.new()
	cloud_a.texture = tex
	cloud_a.centered = false
	cloud_a.scale = sc
	cloud_a.position = Vector2.ZERO
	cloud_a.z_index = z_idx
	add_child(cloud_a)

	cloud_b = Sprite2D.new()
	cloud_b.texture = tex
	cloud_b.centered = false
	cloud_b.scale = sc
	cloud_b.position = Vector2(tex_w, 0)
	cloud_b.z_index = z_idx
	add_child(cloud_b)

func _process(delta: float) -> void:
	if not cloud_a or not cloud_b:
		return

	var ts: Vector2 = cloud_a.texture.get_size()
	var tex_w: float = ts.x * cloud_a.scale.x

	cloud_a.position.x -= cloud_speed * delta
	cloud_b.position.x -= cloud_speed * delta

	if cloud_a.position.x <= -tex_w:
		cloud_a.position.x = cloud_b.position.x + tex_w
	if cloud_b.position.x <= -tex_w:
		cloud_b.position.x = cloud_a.position.x + tex_w
