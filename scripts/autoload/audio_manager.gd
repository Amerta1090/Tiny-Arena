extends Node

var music_volume: float = 0.25
var sfx_volume: float = 0.75

var _sfx_players: Array[AudioStreamPlayer] = []
const MAX_SFX_PLAYERS: int = 8

var sfx_ui_click: AudioStream = preload("res://assets/audio/sfx/ui_click.ogg")
var sfx_hit: AudioStream = preload("res://assets/audio/sfx/hit.ogg")
var sfx_arrow_shoot: AudioStream = preload("res://assets/audio/sfx/arrow_shoot.ogg")
var sfx_enemy_death: AudioStream = preload("res://assets/audio/sfx/enemy_death.ogg")
var sfx_wave_complete: AudioStream = preload("res://assets/audio/sfx/wave_complete.ogg")
var sfx_purchase: AudioStream = preload("res://assets/audio/sfx/purchase.ogg")

var music_menu: AudioStream = preload("res://assets/audio/music/menu.ogg")
var music_battle: AudioStream = preload("res://assets/audio/music/battle.ogg")
var music_shop: AudioStream = preload("res://assets/audio/music/shop.ogg")

var _music_a: AudioStreamPlayer
var _music_b: AudioStreamPlayer
var _active_music: AudioStreamPlayer
var _inactive_music: AudioStreamPlayer
var _current_track: AudioStream = null

const FADE_DURATION: float = 0.5

func _setup_buses() -> void:
	if AudioServer.get_bus_index("Music") == -1:
		var idx := AudioServer.bus_count
		AudioServer.add_bus(idx)
		AudioServer.set_bus_name(idx, "Music")
		AudioServer.set_bus_send(idx, "Master")
	if AudioServer.get_bus_index("SFX") == -1:
		var idx := AudioServer.bus_count
		AudioServer.add_bus(idx)
		AudioServer.set_bus_name(idx, "SFX")
		AudioServer.set_bus_send(idx, "Master")

func _ready() -> void:
	_setup_buses()

	for i in MAX_SFX_PLAYERS:
		var player := AudioStreamPlayer.new()
		player.bus = "SFX"
		add_child(player)
		_sfx_players.append(player)

	_music_a = AudioStreamPlayer.new()
	_music_a.bus = "Music"
	add_child(_music_a)

	_music_b = AudioStreamPlayer.new()
	_music_b.bus = "Music"
	add_child(_music_b)

	_active_music = _music_a
	_inactive_music = _music_b

func _process(delta: float) -> void:
	if _active_music.playing:
		_active_music.volume_db = linear_to_db(music_volume)
	if _inactive_music.playing:
		var vol := _inactive_music.volume_db - delta * (80.0 / FADE_DURATION)
		if vol <= -80.0:
			_inactive_music.stop()
			_inactive_music.volume_db = linear_to_db(music_volume)
		else:
			_inactive_music.volume_db = vol

func play_music(track: AudioStream, fade_time: float = FADE_DURATION) -> void:
	if track == _current_track and _active_music.playing:
		return
	_current_track = track
	# Swap active/inactive
	var temp := _active_music
	_active_music = _inactive_music
	_inactive_music = temp
	# Start new track
	_active_music.stream = track
	_active_music.volume_db = linear_to_db(music_volume)
	_active_music.play()
	# Fade out old track handled in _process

func stop_music(fade_time: float = FADE_DURATION) -> void:
	_current_track = null
	# Let _process fade out active track
	if _active_music.playing:
		# Swap so _process fades the now-inactive one
		var temp := _active_music
		_active_music = _inactive_music
		_inactive_music = temp

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
	play_sfx(sfx_hit, -6.0)

func play_arrow_shoot() -> void:
	play_sfx(sfx_arrow_shoot, -4.0)

func play_enemy_death() -> void:
	play_sfx(sfx_enemy_death, -6.0)

func play_wave_complete() -> void:
	play_sfx(sfx_wave_complete, 4.0)

func play_purchase() -> void:
	play_sfx(sfx_purchase, -3.0)
