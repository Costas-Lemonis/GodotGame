
extends Control


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	hide()


func _process(delta: float) -> void:
	pass


func _input(event):
	if event.is_action_pressed("ui_cancel"):
		if visible:
			_on_btn_resume_pressed()
		else:
			show()
			get_tree().paused = true


func _on_btn_resume_pressed() -> void:
	get_tree().paused = false
	hide()


func _on_btn_restart_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()


func _on_btn_main_menu_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/mainScene.tscn")


func _on_btn_quit_pressed() -> void:
	get_tree().paused = false
	get_tree().quit()
