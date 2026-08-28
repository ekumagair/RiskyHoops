class_name ButtonCharacter
extends Control

@export var character : GameConstants.Characters

@onready var btn : ButtonComplement = $ButtonGeneric
@onready var img : TextureRect = $CharacterImage

var chosen : bool = false

signal pressed(char : GameConstants.Characters)

func _process(delta : float) -> void:
	btn.disabled = global.charIds.has(character) and !options.duplicateChars
	
	if btn.disabled:
		img.modulate = Color(0.7, 0.7, 0.7, 0.7)
	else:
		img.modulate = Color(1, 1, 1, 1)

func pressed_character_button():
	chosen = true
	pressed.emit(character)
