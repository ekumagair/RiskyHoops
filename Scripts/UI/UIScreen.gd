class_name UIScreen
extends Control

@onready var animPlayer : AnimationPlayer = get_node_or_null("AnimationPlayer")
@onready var inputRoot : Control = get_node_or_null("Input")

var isOpen : bool = false

signal on_open
signal on_open_finish
signal on_close
signal on_close_finish

func open():
	show()
	on_open.emit()
	
	if animPlayer != null:
		animPlayer.play("open")
		await animPlayer.animation_finished
	
	isOpen = true
	on_open_finish.emit()

func close():
	isOpen = false
	on_close.emit()
	
	if animPlayer != null:
		animPlayer.play("close")
		await animPlayer.animation_finished
	
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
