extends UIMenu

func _ready() -> void:
	base_ready()

func go_to_main():
	go_to_screen("Main")

func new_game():
	get_tree().change_scene_to_file("res://Maps/map_template.tscn")

func quit_game():
	get_tree().quit()
