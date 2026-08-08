class_name Character
extends CharacterBody3D

@export var playerId : int = 0
@export var team : int = 0
@export var moveSpeed : float = 5.0
@export var jumpVelocity : float = 10.0
@export var fallSpeed : float = 15.0

@onready var ballHold : Node3D = $BallHold

var heldBall : Ball

func _physics_process(delta : float) -> void:
	if playerId > -1:
		move_player_process(delta)

func move_player_process(delta : float) -> void:
	var idStr : String = str(playerId + 1)
	
	if !is_on_floor():
		velocity.y -= fallSpeed * delta
	
	var input = Input.get_vector(
		"move_left_p" + idStr,
		"move_right_p" + idStr,
		"move_up_p" + idStr,
		"move_down_p" + idStr
	)
	
	var direction = Vector3(input.x, 0.0, input.y)
	
	velocity.x = direction.x * moveSpeed * get_horizontal_speed_factor()
	velocity.z = direction.z * moveSpeed * get_horizontal_speed_factor()
	
	if Input.is_action_just_pressed("jump_p" + idStr) and is_on_floor():
		velocity.y = jumpVelocity
	
	move_and_slide()

func get_horizontal_speed_factor() -> float:
	var toReturn : float = 1.0
	
	if !is_on_floor():
		toReturn *= 0.5
	
	return toReturn

func _on_ball_area_entered(area : Area3D) -> void:
	hold_ball(area.get_parent())

func hold_ball(ball : Ball):
	ball.held = true
	ball.reparent(ballHold)
	ball.position = Vector3(0, 0, 0.01)

func release_ball():
	heldBall.reparent(get_parent())
