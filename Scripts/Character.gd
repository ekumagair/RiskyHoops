class_name Character
extends CharacterBody3D

@export var playerId : int = 0
@export var team : int = 0
@export var moveSpeed : float = 5.0
@export var jumpVelocity : float = 10.0
@export var fallSpeed : float = 15.0

@onready var ballHold : Node3D = $BallHold

var heldBall : Ball
var charDirection : Vector3 = Vector3(1, 1, 0)
var charDirectionPressed : Vector3 = Vector3(0, 0, 0)

func _process(delta : float) -> void:
	if playerId > -1:
		player_actions_process(delta)
	
	update_direction()

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
	
	if direction.x != 0:
		charDirectionPressed.x += delta
	elif charDirectionPressed.x > 0:
		charDirectionPressed.x = 0
	
	if direction.z != 0:
		charDirectionPressed.z += delta
	elif charDirectionPressed.z > 0:
		charDirectionPressed.z = 0
	
	move_and_slide()

func player_actions_process(delta : float) -> void:
	var idStr : String = str(playerId + 1)
	
	if Input.is_action_just_pressed("ball_p" + idStr) and heldBall != null:
		if is_on_floor():
			var force : Vector3 = Vector3(9 * charDirection.x, 8, 9 * charDirection.z)
			force.x *= 1 if charDirectionPressed.x > 0 else 0
			force.z *= 1 if charDirectionPressed.z > 0 else 0
			
			release_ball(force)
		else:
			var targetBasket : int = global.get_opposite_team(team)
			var originPos : Vector3 = global_position
			var targetPos : Vector3 = global.gManager.get_basket(targetBasket).ballTarget.global_position
			
			var force : Vector3 = get_release_ball_force_towards(targetPos)
			force.x *= 1 if charDirectionPressed.x > 0 and is_facing_position(originPos.x, charDirection.x, targetPos.x) else 0
			force.z *= 1 if charDirectionPressed.z > 0 and is_facing_position(originPos.z, charDirection.z, targetPos.z) else 0
			force.y += 10
			
			release_ball(Vector3(1.5 * force.x * charDirection.x, force.y, 1.5 * force.z * charDirection.z))

func get_horizontal_speed_factor() -> float:
	var toReturn : float = 1.0
	
	if !is_on_floor():
		toReturn *= 0.5
	
	return toReturn

func update_direction():
	if velocity.x > 0:
		charDirection.x = 1
	elif velocity.x < 0:
		charDirection.x = -1
	
	if velocity.y > 0:
		charDirection.y = 1
	elif velocity.y < 0:
		charDirection.y = -1
	
	if velocity.z > 0:
		charDirection.z = 1
	elif velocity.z < 0:
		charDirection.z = -1

func _on_ball_area_entered(area : Area3D) -> void:
	hold_ball(area.get_parent())

func hold_ball(ball : Ball):
	if heldBall != null or ball.forbidCharacter == self or ball.held or ball.scoring:
		return
	
	ball.held = true
	ball.reparent(ballHold)
	ball.position = Vector3(0, 1, 0.01)
	heldBall = ball

func release_ball(newVelocity : Vector3):
	if heldBall == null:
		return
	
	heldBall.forbidCharacter = self
	heldBall.held = false
	heldBall.reparent(global.gManager.environment)
	heldBall.position = heldBall.global_position
	heldBall.velocity = newVelocity
	heldBall = null

func get_release_ball_force_towards(targetPos : Vector3) -> Vector3:
	var toReturn : Vector3
	
	toReturn.x = targetPos.x - global_position.x
	toReturn.z = targetPos.z - global_position.z
	toReturn.z *= 0.75
	
	if abs(toReturn.x) > 0 and abs(toReturn.x) < 4:
		toReturn.x = 4
	if abs(toReturn.z) > 0 and abs(toReturn.z) < 3:
		toReturn.z = 3
	
	return abs(toReturn)

func is_facing_position(originPos : float, originDir : float, targetPos : float) -> bool:
	if targetPos < originPos and originDir < 0:
		return true
	if targetPos > originPos and originDir > 0:
		return true
	
	return false
	
