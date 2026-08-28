class_name UIScreen
extends Control

@export var defaultColor : Color = Color(1, 1, 1, 1)
@export var defaultButton : Button
@export var cursor : Control

@onready var animPlayer : AnimationPlayer = get_node_or_null("AnimationPlayer")
@onready var inputRoot : Control = get_node_or_null("Input")

var isOpen : bool = false

signal on_open
signal on_open_finish
signal on_close
signal on_close_finish

func reset():
	if animPlayer != null:
		animPlayer.play("RESET")
	
	modulate = defaultColor

func open():
	reset()
	show()
	release_focus()
	
	isOpen = false
	on_open.emit()
	
	await play_animation("open")
	
	isOpen = true
	on_open_finish.emit()
	
	if defaultButton != null:
		global.give_focus_to(defaultButton)
	else:
		global.release_focus()

func close():
	if !isOpen:
		return
	
	isOpen = false
	on_close.emit()
	
	release_focus()
	
	await play_animation("close")
	
	on_close_finish.emit()
	hide()

func _on_visibility_changed() -> void:
	if !visible:
		isOpen = false

func hide_input_node():
	if inputRoot != null:
		inputRoot.hide()

func show_input_node():
	if inputRoot != null:
		inputRoot.show()

func play_animation(animName : String):
	if animPlayer != null:
		animPlayer.play(animName)
		await animPlayer.animation_finished
