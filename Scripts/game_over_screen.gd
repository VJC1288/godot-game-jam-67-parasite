extends Control

@onready var death_count_text = %DeathCountText

@onready var game_over_sound = $GameOverSound



func _ready():
	death_count_text.text = "You escaped with " + str(Globals.death_count) + " deaths!"
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	game_over_sound.play()
	
