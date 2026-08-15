extends Node

var gManager : GameManager

var versionBase : String
var version : String
var isWeb : bool = false
var isEditor : bool = false
var isMobile : bool = false
var developer : int = 0
var cmdArgs : Dictionary

#region Gameplay
func get_opposite_team(team : int) -> int:
	if team == 0:
		return 1
	else:
		return 0
#endregion

#region UI
func get_focus_owner():
	return get_viewport().gui_get_focus_owner()

func give_focus_to(toFocus):
	toFocus.grab_focus()

func release_focus():
	if get_focus_owner() != null:
		get_focus_owner().release_focus()
#endregion

#region Cmd
func parse_user_args() -> Dictionary:
	var args = OS.get_cmdline_user_args()
	var result : Dictionary = {}
	var i = 0
	
	while i < args.size():
		var thisArg = args[i]
		
		# If this argument is a --key.
		if thisArg.begins_with("--"):
			# Remove the leading '--'
			var key : String = thisArg.substr(2)
			
			if "=" in key:
				### Format: --key=value ###
				var split = key.split("=", false, 1)
				result[split[0]] = split[1]
			elif i + 1 < args.size() and !args[i + 1].begins_with("-"):
				### Format: --key value ###
				result[key] = args[i + 1]
				i += 1
			else:
				### Format: --key (boolean flag) ###
				result[key] = true
		
		i += 1
	
	return result

func has_user_arg_key(key : String) -> bool:
	return global.cmdArgs.has(key)

func get_user_arg_value(key : String):
	return global.cmdArgs.get(key, false)
#endregion
