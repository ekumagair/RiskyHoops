class_name Audio
extends Node

enum Sound
{
	NONE = -1,
	BELL = 0,
}

var soundObjs = {
	-1: null,
	00: preload("res://Audio/Objects/snd_obj_bell.tscn"),
}

enum Music
{
	NONE = -1,
	SILENCE = 0,
	MAIN_MENU_HOOPS1 = 1,
	MAIN_MENU_HOOPS2 = 2,
	MAIN_MENU_RISKY = 3,
	MATCH_HOOPS1_A = 4,
	MATCH_HOOPS1_B = 5,
	MATCH_HOOPS1_C = 6,
}

var musicFiles = {
	-1: null,
	00: null,
	01: preload("res://Audio/Music/MainMenu1.ogg"),
	02: preload("res://Audio/Music/MainMenu2.ogg"),
	03: preload("res://Audio/Music/MainMenu3.ogg"),
	04: preload("res://Audio/Music/MatchTheme1.ogg"),
	05: preload("res://Audio/Music/MatchTheme2.ogg"),
	06: preload("res://Audio/Music/MatchTheme3.ogg"),
}

var sfxBusName : String = "SFX"
var sfxBusIndex : int

var musicBusName : String = "Music"
var musicBusIndex : int
var musicObj = preload("res://Audio/Objects/mus_obj.tscn")
var musicStream : AudioStreamPlayer
var musicCurrent : Music = Music.SILENCE

const GLOBAL_SFX_POS : Vector3 = Vector3(0, -1000, 0)

func _ready() -> void:
	sfxBusIndex = AudioServer.get_bus_index(sfxBusName)
	musicBusIndex = AudioServer.get_bus_index(musicBusName)
	
	musicStream = musicObj.instantiate()
	audio.add_child(musicStream)

#region Sound
func play_sound(sound : Audio.Sound, pos : Vector3 = GLOBAL_SFX_POS):
	if sound == Audio.Sound.NONE:
		return
	
	var instance = soundObjs[int(sound)].instantiate()
	
	if global.gManager != null and global.gManager.environment != null:
		global.gManager.environment.add_child(instance)
	elif global.gManager != null:
		global.gManager.add_child(instance)
	else:
		audio.add_child(instance)
	
	if pos == GLOBAL_SFX_POS:
		# Global sound.
		if global.gManager != null and global.gManager.camera != null:
			instance.global_position = global.gManager.camera.global_position
			instance.followActiveCamera = true
		else:
			instance.global_position = Vector3.ZERO
		
		instance.attenuation_model = 3
		instance.panning_strength = 0.0
	else:
		# Spatial sound.
		instance.global_position = pos
		instance.followActiveCamera = false
#endregion

#region Music
func play_music(music : Music):
	if music == Music.NONE:
		# NONE = Don't change the music that's currently playing.
		return
	elif music == musicCurrent:
		return
	
	# Fade the old music out before playing the new one.
	if musicStream.playing and musicCurrent != Music.SILENCE:
		var tweenOut = create_tween()
		tweenOut.tween_property(musicStream, "volume_db", -80.0, 0.5)
		
		await tweenOut.finished
		musicStream.stop()
	
	# Set the current music variable.
	musicCurrent = music
	
	if music == Music.SILENCE:
		# SILENCE = Stop the music, no matter what.
		musicStream.stop()
		return
	
	musicStream.stream = musicFiles[int(music)]
	musicStream.play()
	
	var tweenIn = create_tween()
	tweenIn.tween_property(musicStream, "volume_db", 0.0, 0.5)
	
	await tweenIn.finished

func clear_music_effects():
	for i in AudioServer.get_bus_effect_count(musicBusIndex):
		AudioServer.remove_bus_effect(musicBusIndex, 0)

func fade_music_to_silence():
	play_music(Audio.Music.SILENCE)

func cut_music():
	musicStream.stop()
#endregion
