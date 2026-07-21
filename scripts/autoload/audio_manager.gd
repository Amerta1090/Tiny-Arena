extends Node

var music_volume: float = 0.8
var sfx_volume: float = 1.0

var _sfx_players: Array[AudioStreamPlayer] = []
const MAX_SFX_PLAYERS: int = 8

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
	pass

func play_hit() -> void:
	pass

func play_arrow_shoot() -> void:
	pass

func play_enemy_death() -> void:
	pass

func play_wave_complete() -> void:
	pass

func play_purchase() -> void:
	pass
