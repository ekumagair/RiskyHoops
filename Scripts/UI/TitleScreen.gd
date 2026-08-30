extends UIScreen

@onready var versionLabel : Label = $VersionLabel

func _process(delta : float) -> void:
	if Input.is_anything_pressed() and isOpen:
		close()

func on_title_open():
	if global.version == "":
		versionLabel.text = ""
		return
	
	versionLabel.text = "v" + global.version
