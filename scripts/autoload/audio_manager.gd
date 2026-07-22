extends Node

var music_volume: float = 0.8
var sfx_volume: float = 1.0

var _sfx_players: Array[AudioStreamPlayer] = []
const MAX_SFX_PLAYERS: int = 8

var sfx_ui_click: AudioStream = preload("res://assets/audio/sfx/ui_click.ogg")
var sfx_hit: AudioStream = preload("res://assets/audio/sfx/hit.ogg")
var sfx_arrow_shoot: AudioStream = preload("res://assets/audio/sfx/arrow_shoot.ogg")
var sfx_enemy_death: AudioStream = preload("res://assets/audio/sfx/enemy_death.ogg")
var sfx_wave_complete: AudioStream = preload("res://assets/audio/sfx/wave_complete.ogg")
var sfx_purchase: AudioStream = preload("res://assets/audio/sfx/purchase.ogg")

func _ready() -> void:
	for i in MAX_SFX_PLAYERS:
		var player := AudioStreamPlayer.new()
		player.bus = "Master"
		add_child(player)
		_sfx_players.append(player)

func play_sfx(stream: AudioStream, volume_db: float = 0.0) -> void:
	if not stream:
		return
	for player in _sfx_players:
		if not player.playing:
			player.stream = stream
			player.volume_db = volume_db + linear_to_db(sfx_volume)
			player.play()
			return

func play_ui_click() -> void:
	play_sfx(sfx_ui_click, -6.0)

func play_hit() -> void:
	play_sfx(sfx_hit, -10.0)

func play_arrow_shoot() -> void:
	play_sfx(sfx_arrow_shoot, -4.0)

func play_enemy_death() -> void:
	play_sfx(sfx_enemy_death, -20.0)

func play_wave_complete() -> void:
	play_sfx(sfx_wave_complete, 4.0)

func play_purchase() -> void:
	play_sfx(sfx_purchase, -3.0)
