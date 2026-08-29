class_name Projectile
extends Attack

@export var fallSpeed : float = 0.0

var velocity : Vector3 = Vector3(0, 0, 0)

func _process(delta: float) -> void:
	process_auto_delete()

func _physics_process(delta : float) -> void:
	gravity(delta)
	translate(velocity * delta)

func gravity(delta : float):
	if fallSpeed == 0.0:
		return
	
	if !is_on_floor():
		velocity.y -= fallSpeed * delta
	else:
		velocity.y = 0
		queue_free()

func is_on_floor():
	return global_position.y <= 0.0

func process_auto_delete() -> void:
	if velocity.x > 0 and global_position.x > global.gManager.charPosLimit.x * 2:
		queue_free()
	elif velocity.x < 0 and global_position.x < global.gManager.charPosLimit.x * -2:
		queue_free()
	
	if velocity.z > 0 and global_position.z > global.gManager.charPosLimit.z * 2:
		queue_free()
	elif velocity.z < 0 and global_position.z < global.gManager.charPosLimit.z * -2:
		queue_free()

func _on_body_entered(body: Node3D) -> void:
	if body == null or body == originBody:
		return
	
	var hitChar : Character = body as Character
	
	if hitChar == null:
		return
	if hitChar.stunned or hitChar.team == originTeam:
		return
	
	hitChar.stun()
	queue_free()
