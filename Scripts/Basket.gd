class_name Basket
extends Node3D

@export var team : int = 0
@export var positions : Array[Node3D]

@onready var ballTarget : Node3D = $Target

func _on_ball_area_entered(area: Area3D) -> void:
	var ball : Ball = area.get_parent()
	
	if ball.held or ball.scoring or ball.velocity.y > 0:
		return
	
	global.gManager.release_ball(ball)
	global.gManager.add_score(2 if ball.twoPoint else 3, global.get_opposite_team(team))
	
	ball.forbidCharacter = null
	ball.held = false
	ball.scoring = true
	ball.velocity = Vector3(0, 0, 0)
	ball.global_position = Vector3(ballTarget.global_position.x, ballTarget.global_position.y - 0.1, ballTarget.global_position.z - 0.5)
	
	global.gManager.organize_to_basket(team)
	audio.play_sound(Audio.Sound.IMPACT_CRUNCH, ballTarget.global_position)

func _on_points_area_entered(body: Node3D) -> void:
	var char : Character = body as Character
	
	if char == null:
		return
	
	char.twoPoint = true

func _on_points_area_exited(body: Node3D) -> void:
	var char : Character = body as Character
	
	if char == null:
		return
	
	char.twoPoint = false
