extends Control

@onready var  LCD_display : Label = $CD_player_body/LCD_Display
@onready var  CD_Disc : TextureProgressBar = $CD_player_body/CD_Disc

var levels: Array[String] = [
	"res://TTDL_TRACKS/TRACK/DEMOLITION_LOVERS(L1/level_1.tscn",
	"res://TTDL_TRACKS/TRACK/GIVE_EM_HELL_KID(L2)/level_2.tscn",
	"res://TTDL_TRACKS/TRACK/TO_THE_END(L3)/level_3.tscn",
	"res://TTDL_TRACKS/TRACK/YKWTDTGLUIP(L4)/level_4.tscn",
]

var current_track_index: int = 0 

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	update_LCD_readout()

func _process(delta: float) -> void:
	if CD_Disc:
		CD_Disc.rotation += 2 * delta
		

func update_LCD_readout() -> void:
	LCD_display.text = "TRACK: %02d\nREADY TO PLAY" % (current_track_index + 1) 

func _on_next_button_pressed() -> void:
	current_track_index = (current_track_index + 1) % levels.size()
	update_LCD_readout()

func _on_prev_buttion_pressed() -> void:
	current_track_index -= 1 
	if  current_track_index < 0:
		current_track_index = levels.size() - 1
	update_LCD_readout()

func _on_play_button_pressed() -> void:
	LCD_display.text = "TRACK: %02d\nLOADING....." % (current_track_index + 1)
	
	var target_scene = levels[current_track_index]
	if SceneManager:
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
		get_tree().change_scene_to_file(target_scene)
