extends Node

var gManager : GameManager

func get_opposite_team(team : int) -> int:
	if team == 0:
		return 1
	else:
		return 0
