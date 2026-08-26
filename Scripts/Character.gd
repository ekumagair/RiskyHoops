class_name Character
extends CharacterBody3D

@export var playerId : int = 0
@export var team : int = 0
@export var moveSpeed : float = 5.0
@export var jumpVelocity : float = 10.0
@export var fallSpeed : float = 15.0
@export var attackType : GameConstants.AttackTypes = GameConstants.AttackTypes.NONE
@export var attackPrefab : GameConstants.Attacks = GameConstants.Attacks.NONE
@export var attackDuration : float = 0.25

@onready var ballHold : Node3D = $BallHold
@onready var model : Node3D = $Model
@onready var modelAnim : AnimationPlayer = $Model/AnimationPlayer

var heldBall : Ball
var teammate : Character
var friendlyBasket : Basket
var oppositeBasket : Basket
var charDirection : Vector3 = Vector3(1, 1, 0)
var charDirectionPressed : Vector3 = Vector3(0, 0, 0)
var targetWalkPos : Vector3 = Vector3(0, 0, 0)
var targetWalkPosRange : float
var attacking : bool = false
var stunned : bool = false

func _ready() -> void:
	targetWalkPosRange = moveSpeed * 0.09
	teammate = get_teammate()
	friendlyBasket = global.gManager.get_basket(team)
	oppositeBasket = global.gManager.get_basket(global.get_opposite_team(team))

func _process(delta : float) -> void:
	if playerId > -1:
		player_actions_process(delta)
	else:
		bot_actions_process(delta)
		bot_search_target_pos()
	
	set_char_dir_from_velocity()
	update_animation()

func _physics_process(delta : float) -> void:
	move_common_process(delta)
	
	if playerId > -1:
		move_player_process(delta)
	else:
		move_bot_process(delta)

#region Common Logic
func move_common_process(delta : float) -> void:
	if !is_on_floor():
		velocity.y -= fallSpeed * delta

func jump_action() -> void:
	if !is_on_floor():
		return
	
	velocity.y = jumpVelocity

func ball_action() -> void:
	if heldBall == null:
		return
	
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
		force.y += 9
		
		if force.x > 0 and force.z == 0:
			force.x *= 1.25
		elif force.x > 0 and force.z > 0:
			force.x *= 1.5
			force.z *= 2.5
		elif force.x == 0 and force.z > 0:
			force.z *= 2.0
		
		if force.y > 0 and global_position.y > targetPos.y * 0.75 and global_position.distance_to(targetPos) < 4:
			force.y *= 0.5
		
		release_ball(Vector3(force.x * charDirection.x, force.y, force.z * charDirection.z))

func get_teammate() -> Character:
	var chars = global.gManager.characters
	
	for i in len(chars):
		if chars[i].team == team:
			return chars[i]
	
	return null
#endregion

#region Player Logic
func move_player_process(delta : float) -> void:
	var idStr : String = str(playerId + 1)
	
	var input = Input.get_vector(
		"move_left_p" + idStr,
		"move_right_p" + idStr,
		"move_up_p" + idStr,
		"move_down_p" + idStr
	)
	
	var direction = Vector3(input.x, 0.0, input.y)
	
	velocity.x = direction.x * moveSpeed * get_horizontal_speed_factor()
	velocity.z = direction.z * moveSpeed * get_horizontal_speed_factor()
	
	if Input.is_action_just_pressed("jump_p" + idStr):
		jump_action()
	
	set_char_dir_from_input(delta, direction)
	
	move_and_slide()

func player_actions_process(delta : float) -> void:
	var idStr : String = str(playerId + 1)
	
	if Input.is_action_just_pressed("ball_p" + idStr):
		ball_action()
	
	if Input.is_action_just_pressed("attack_p" + idStr):
		attack_action()
#endregion

#region Bot Logic
func move_bot_process(delta : float) -> void:
	var input : Vector3 = Vector3(0, 0, 0)
	
	if targetWalkPos.x > global_position.x and targetWalkPos.x - global_position.x > targetWalkPosRange:
		input.x = 1
	elif targetWalkPos.x < global_position.x and global_position.x - targetWalkPos.x > targetWalkPosRange:
		input.x = -1
	
	if targetWalkPos.z > global_position.z and targetWalkPos.z - global_position.z > targetWalkPosRange:
		input.z = 1
	elif targetWalkPos.z < global_position.z and global_position.z - targetWalkPos.z > targetWalkPosRange:
		input.z = -1
	
	var direction = Vector3(input.x, 0.0, input.z)
	
	velocity.x = direction.x * moveSpeed * get_horizontal_speed_factor()
	velocity.z = direction.z * moveSpeed * get_horizontal_speed_factor()
	
	set_char_dir_from_input(delta, direction)
	
	move_and_slide()

func bot_actions_process(delta : float) -> void:
	if global.gManager.ball.holder == self:
		if global_position.distance_to(oppositeBasket.ballTarget.global_position) < 10 and randi_range(0, 10) == 0:
			bot_shoot_ball()

func bot_shoot_ball():
	if global.gManager.ball.holder != self or !is_on_floor():
		return
	
	jump_action()
	await get_tree().create_timer(randf_range(0.1, 0.3)).timeout
	ball_action()

func bot_search_target_pos() -> void:
	var newTargetWalkPos : Vector3
	var ball : Ball = global.gManager.ball
	var holder : Character = ball.holder
	
	if holder != null:
		if holder != self:
			if holder.team != team:
				newTargetWalkPos.x = holder.global_position.x + (2 * holder.charDirection.x)
				newTargetWalkPos.z = holder.global_position.z * randf_range(-1.1, 1.1)
			else:
				newTargetWalkPos.x = holder.global_position.x
				newTargetWalkPos.z = holder.global_position.z * -1
		else:
			newTargetWalkPos.x = oppositeBasket.ballTarget.global_position.x
			newTargetWalkPos.z = oppositeBasket.ballTarget.global_position.z
	else:
		newTargetWalkPos = ball.global_position
	
	if abs(newTargetWalkPos.x - targetWalkPos.x) > 0.5 and abs(global_position.x - targetWalkPos.x) < 0.5:
		newTargetWalkPos.x = clampf(newTargetWalkPos.x * randf_range(0.8, 1.2), global.gManager.charPosLimit.x * -1, global.gManager.charPosLimit.x)
		targetWalkPos.x = newTargetWalkPos.x
	if abs(newTargetWalkPos.z - targetWalkPos.z) > 0.5 and abs(global_position.z - targetWalkPos.z) < 0.5:
		newTargetWalkPos.z = clampf(newTargetWalkPos.z * randf_range(0.8, 1.2), global.gManager.charPosLimit.z * -1, global.gManager.charPosLimit.z)
		targetWalkPos.z = newTargetWalkPos.z

func bot_cancel_target_pos() -> void:
	targetWalkPos = global_position
#endregion

#region Speed
func get_horizontal_speed_factor() -> float:
	var toReturn : float = 1.0
	
	if !is_on_floor():
		toReturn *= 0.5
	if attacking and is_on_floor():
		toReturn *= 0.0
	if stunned:
		toReturn *= 0.0 if !is_on_floor() else 0.4
	
	return toReturn
#endregion

#region Direction
func set_char_dir_from_input(delta : float, direction : Vector3) -> void:
	if direction.x != 0:
		charDirectionPressed.x += delta
	elif charDirectionPressed.x > 0:
		charDirectionPressed.x = 0
	
	if direction.z != 0:
		charDirectionPressed.z += delta
	elif charDirectionPressed.z > 0:
		charDirectionPressed.z = 0

func set_char_dir_from_velocity():
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

func is_facing_position(originPos : float, originDir : float, targetPos : float) -> bool:
	if targetPos < originPos and originDir < 0:
		return true
	if targetPos > originPos and originDir > 0:
		return true
	
	return false
#endregion

#region Ball
func _on_ball_area_entered(area : Area3D) -> void:
	hold_ball(area.get_parent())

func hold_ball(ball : Ball):
	if heldBall != null or ball.forbidCharacter == self or ball.held or ball.scoring or attacking or stunned:
		return
	
	ball.held = true
	ball.holder = self
	call_deferred("reparent_ball", ball)

func reparent_ball(ball : Ball):
	ball.reparent(ballHold)
	ball.position = Vector3(0, 1.0, 0.6)
	heldBall = ball

func release_ball(newVelocity : Vector3):
	if heldBall == null:
		return
	
	heldBall.forbidCharacter = self
	heldBall.held = false
	heldBall.holder = null
	heldBall.holderPrev = self
	heldBall.releasePos = global_position
	heldBall.position = Vector3(0, 1.0, 0)
	heldBall.reparent(global.gManager.objects)
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
#endregion

#region Animation
func update_animation():
	if charDirection.x >= 0:
		model.scale.x = 1
	else:
		model.scale.x = -1
	
	if !is_on_floor():
		if !attacking:
			play_animation("jump")
		else:
			play_animation("jump_attack")
	else:
		if velocity.x != 0 or velocity.z != 0:
			play_animation("walk")
		else:
			if !attacking:
				play_animation("idle")
			else:
				play_animation("attack")

func play_animation(anim : String):
	if modelAnim.has_animation(anim):
		modelAnim.play(anim)
#endregion

#region Attack
func attack_action():
	if attacking or stunned:
		return
	if attackType == GameConstants.AttackTypes.NONE or attackPrefab == GameConstants.Attacks.NONE:
		return
	if heldBall != null:
		return
	
	var speed : float = 0
	var dir : Vector3 = charDirection
	
	match attackPrefab:
		GameConstants.Attacks.KNIFE:
			speed = 15
			dir.y = 0
			dir.z = 0
	
	var instance = global.gManager.get_attack_prefab(attackPrefab).instantiate()
	
	if attackType == GameConstants.AttackTypes.PROJECTILE:
		var instanceP : Projectile = instance as Projectile
		instanceP.velocity = dir * speed
	
	global.gManager.objects.add_child(instance)
	instance.global_position = global_position + Vector3(0, 1, 0)
	instance.originBody = self
	instance.originTeam = team
	
	if dir.x >= 0:
		instance.model.scale.x = 1
	else:
		instance.model.scale.x = -1
	
	attack_delay()

func attack_delay():
	attacking = true
	
	await get_tree().create_timer(attackDuration).timeout
	
	attacking = false

func stun():
	if stunned:
		return
	
	stunned = true
	
	if heldBall != null:
		var force : Vector3 = Vector3(randf_range(-10, 10), randf_range(10, 12), randf_range(-10, 10))
		release_ball(force)
	
	velocity = Vector3(0, 6, 0)
	
	for i in 10:
		model.hide()
		await get_tree().create_timer(0.1).timeout
		model.show()
		await get_tree().create_timer(0.1).timeout
	
	model.show()
	stunned = false
#endregion
