extends CanvasLayer

@export var background_folder: String = "res://assets/background/nature_1/"

var layer_defs: Array[Dictionary] = [
	{"file": "sky.png", "z_index": 0},
	{"file": "clouds.png", "z_index": 1, "is_clouds": true},
	{"file": "mountains_far.png", "z_index": 2},
	{"file": "mountains_near.png", "z_index": 3},
	{"file": "trees_back.png", "z_index": 4},
	{"file": "trees_front.png", "z_index": 5},
	{"file": "ground.png", "z_index": 6},
	{"file": "grass.png", "z_index": 7},
]

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

func _build_layers() -> void:
	for ld in layer_defs:
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
