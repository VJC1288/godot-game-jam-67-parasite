extends Control


@onready var play_button = %PlayButton
@onready var how_to_play_button = %HowToPlayButton
@onready var x_button = %"X Button"
@onready var how_to_play_window = %HowToPlayWindow




func _on_x_button_pressed():
	how_to_play_window.visible = false


func _on_how_to_play_button_pressed():
	how_to_play_window.visible = true


func _on_play_button_pressed():
	get_tree().change_scene_to_packed(Globals.WORLD)
