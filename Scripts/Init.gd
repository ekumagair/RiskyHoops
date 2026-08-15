extends Node

func _ready():
	get_tree().paused = false
	Engine.time_scale = 1.0
	
	print("--- INIT ---")
	print(ProjectSettings.get_setting("application/config/name") + " - v" + str(ProjectSettings.get_setting_with_override("application/config/version")))
	print("Made by Eduardo Kumagai Rocha")
	
	global.versionBase = str(ProjectSettings.get_setting("application/config/version"))
	global.version = str(ProjectSettings.get_setting_with_override("application/config/version"))
	global.isWeb = OS.has_feature("web")
	global.isEditor = OS.has_feature("editor")
	global.isMobile = OS.has_feature("mobile")
	global.cmdArgs = global.parse_user_args()
	
	# Set developer mode from user arg.
	if global.has_user_arg_key("developer"):
		global.developer = int(global.get_user_arg_value("developer"))
	
	# Print the user args.
	if global.developer > 0:
		print("Developer = " + str(global.developer))
		
		print("Received user command line arguments:")
		for k in global.cmdArgs.keys():
			print("--" + str(k))
	
	# Must wait at least one frame before changing scene.
	await get_tree().process_frame
	
	# Go to the first real scene.
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
