extends Node

onready var music_track_1 = $Music/Track1
onready var music_track_2 = $Music/Track2
onready var ambiance_track_1 = $Ambiance/Ambiance
onready var sound_track_1 = $SoundEffects/Sound1
onready var sound_track_2 = $SoundEffects/Sound2
onready var sound_track_3 = $SoundEffects/Sound3
onready var sound_track_4 = $SoundEffects/Sound4
onready var sound_track_5 = $SoundEffects/Sound5

const CROSSFADE_SPEED = 0.005

export var is_mute: bool = false
export var music_volume_db: float = 0.0
export var ambient_volume_db: float = 0.0
export var sounds_volume_db: float = 0.0

var is_crossfading: bool = false
var crossfade_from: AudioStreamPlayer2D = music_track_1
var crossfade_to: AudioStreamPlayer2D = music_track_2
var crossfade_to_volume_db: float = 0.0
var min_volume_db:float = -30.0
var ambiance_to:float = 0.0
var ambiance_change_speed:float = 0.05
var rng = RandomNumberGenerator.new()

func _ready():
	set_volume()

func _physics_process(delta):
	check_crossfade()
	check_ambiance()

func play_music(track, volume_db = 0):
	if is_mute:
		return

	var fade_from	= music_track_1
	var fade_to		= music_track_2
	
	if music_track_1.playing:
		fade_to 	= music_track_2
		fade_from 	= music_track_1
		
	fade_to.stream = load(track)
	
	crossfade_music(fade_from, fade_to, volume_db)

func play_sound(sound: AudioStream, volume_db: float = 0):
	if is_mute:
		return null
			
	if !sound_track_1.playing:
		sound_track_1.stream = sound
		sound_track_1.play()
		return sound_track_1
		
	if !sound_track_2.playing:
		sound_track_2.stream = sound
		sound_track_2.play()
		return sound_track_2
		
	if !sound_track_3.playing:
		sound_track_3.stream = sound
		sound_track_3.play()
		return sound_track_3	
		
	if !sound_track_4.playing:
		sound_track_4.stream = sound
		sound_track_4.play()
		return sound_track_4	
		
	if !sound_track_5.playing:
		sound_track_5.stream = sound
		sound_track_5.play()
		return sound_track_5					
		
func play_random_sound(tracks: Array, volume_db:float = 0):
	randomize()
	var track = tracks[rng.randi_range(0,tracks.size()-1)]
	play_sound(load(track), volume_db)	

func play_ambiance(track, volume_db = 0):
	if is_mute:
		return
			
	ambiance_track_1.volume_db = volume_db
	ambiance_track_1.play()

func crossfade_music(track1, track2, volume_db = 0):
	crossfade_to_volume_db = volume_db
	is_crossfading = true
	crossfade_from = track1
	crossfade_to = track2
	crossfade_to.volume_db = min_volume_db
	crossfade_to.play()

func check_crossfade():
	if is_crossfading:
		if crossfade_from.playing:
			crossfade_from.volume_db = lerp(crossfade_from.volume_db, min_volume_db, CROSSFADE_SPEED)
		crossfade_to.volume_db = lerp(crossfade_to.volume_db, crossfade_to_volume_db, CROSSFADE_SPEED)
		if abs(crossfade_to.volume_db) - abs(crossfade_to_volume_db) < 0.1:
			is_crossfading = false
			crossfade_to.volume_db = crossfade_to.volume_db
		
func set_bus_volume(bus, volume_db):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(bus), volume_db)

func set_volume(music_db = Config.default_volume_db, ambient_db = Config.default_volume_db, sounds_db = Config.default_volume_db):
	set_bus_volume("Music", music_db)
	set_bus_volume("Ambient", music_db)
	set_bus_volume("Sounds", music_db)
	self.music_volume_db = music_db
	self.ambient_volume_db = ambient_db
	self.sounds_volume_db = sounds_db
	
func get_random_volume_db(low: float = -20, high: float = 0):
	randomize()
	return rng.randf_range(low, high)

func check_ambiance():
	if abs(ambiance_track_1.volume_db - ambiance_to) > 0.2:
		ambiance_track_1.volume_db = lerp(ambiance_track_1.volume_db, ambiance_to, ambiance_change_speed)	
	else:
		ambiance_track_1.volume_db = ambiance_to
		ambiance_to = get_random_volume_db()
