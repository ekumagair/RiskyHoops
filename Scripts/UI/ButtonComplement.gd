class_name ButtonComplement
extends Button

signal on_left
signal on_right

func _ready() -> void:
	pass

func _process(delta : float) -> void:
	process_back_next()

func process_back_next() -> void:
	if global.get_focus_owner() == self:
		if Input.is_action_just_pressed("ui_left"):
			on_left.emit()
		elif Input.is_action_just_pressed("ui_right"):
			on_right.emit()
