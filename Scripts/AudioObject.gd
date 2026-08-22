class_name AudioObject
extends AudioStreamPlayer3D

@export var sounds : Array[AudioStream]
@export var pitchMin : float = 1.0
@export var pitchMax : float = 1.0

var followActiveCamera : bool = false

func _ready() -> void:
	stream = sounds.pick_random()
	
	# If there's no sound to be played, don't do anything.
	if stream == null:
		on_finish()
		return
	
	# Set a random pitch.
	pitch_scale = randf_range(pitchMin, pitchMax)
	
	# Play the chosen sound.
	play()
	
	await get_tree().create_timer(stream.get_length(), false).timeout
	
	# After finishing the sound.
	on_finish()

func _process(delta : float) -> void:
	if followActiveCamera and global.gManager.activeCamAngle != null:
		global_position = global.gManager.camera.global_position

func on_finish() -> void:
	queue_free()
