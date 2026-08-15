extends UIScreen

@onready var versionLabel : Label = $VersionLabel

func _process(delta : float) -> void:
	if Input.is_anything_pressed():
		close()

func on_title_open():
	versionLabel.text = "v" + global.version
