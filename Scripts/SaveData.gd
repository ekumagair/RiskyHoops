extends Node

var saveDataPath : String = 'user://save_data'
var currentSaveSlot : int = 0

var loadedVersionBase : String = ""
var loadedVersion : String = ""
var loadedSaveSystemVersion : int = 0
var loadedDemoCheck : int = 0
var loadedDay : int
var loadedMonth : int
var loadedYear : int

func create_folder(fPath : String):
	if !DirAccess.dir_exists_absolute(fPath):
		DirAccess.make_dir_absolute(fPath)

#region SLOT SAVE
func save_current_slot():
	save_slot(currentSaveSlot)

func save_slot(slot : int):
	# Create folder.
	create_folder(saveDataPath)
	
	var fileName : String = saveDataPath + "/slot" + str(slot) + GameConstants.SAVE_EXTENSION
	var file : FileAccess = FileAccess.open(fileName, FileAccess.WRITE)
	
	############### SAVING start ###############
	
	# Register the save system version.
	file.store_64(GameConstants.SAVE_VERSION)
	
	# Save game version.
	file.store_pascal_string(global.versionBase)
	file.store_pascal_string(global.version)
	
	# Save current date.
	file.store_8(int(Time.get_date_dict_from_system().day))
	file.store_8(int(Time.get_date_dict_from_system().month))
	file.store_16(int(Time.get_date_dict_from_system().year))
	
	# Save options.
	file.store_64(options.quarterDuration)
	file.store_64(options.scoreGoal)
	file.store_float(options.musicVolume)
	file.store_float(options.sfxVolume)
	file.store_pascal_string(options.locale)
	file.store_8(1 if options.duplicateChars else 0)
	
	############### SAVING end ###############
	
	file.close()
	
	# Print.
	if global.developer > 0:
		print("Saved slot: " + fileName)
#endregion

#region SLOT LOAD
func load_current_slot():
	load_slot(currentSaveSlot)

func load_slot(slot : int):
	var data = get_stored_data(slot)
	
	if data == null:
		return
	
	############### LOADING start ###############
	
	loadedSaveSystemVersion = data.get_64()
	
	loadedVersionBase = data.get_pascal_string()
	loadedVersion = data.get_pascal_string()
	
	loadedDay = data.get_8()
	loadedMonth = data.get_8()
	loadedYear = data.get_16()
	
	options.set_quarter_duration(data.get_64())
	options.set_score_goal(data.get_64())
	options.set_music_volume(data.get_float())
	options.set_sfx_volume(data.get_float())
	
	if loadedSaveSystemVersion > 0:
		options.set_locale(data.get_pascal_string())
		options.set_allow_duplicate_chars(data.get_8() == 1)
	
	############### LOADING end ###############
	
	# Print.
	if global.developer > 0:
		print("Loaded slot " + str(slot))
		print("Loaded data from version " + loadedVersion + " (" + str(loadedSaveSystemVersion) + ")")

func get_stored_data(slot : int):
	var fileName : String = saveDataPath + "/slot" + str(slot) + GameConstants.SAVE_EXTENSION
	
	if FileAccess.file_exists(fileName):
		return FileAccess.open(fileName, FileAccess.READ)
	else:
		return null
#endregion

#region SLOT DELETE
func delete_current_slot():
	delete_slot(currentSaveSlot)

func delete_slot(slot : int):
	var fileName : String = saveDataPath + "/slot" + str(slot) + GameConstants.SAVE_EXTENSION
	
	if FileAccess.file_exists(fileName):
		DirAccess.remove_absolute(fileName)
	
	# Print.
	if global.developer > 0:
		print("Deleted slot " + str(slot))
#endregion
