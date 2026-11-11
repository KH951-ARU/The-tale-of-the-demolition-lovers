extends Control

@onready var  LCD_display : Label = $CD_player_body/LCD_Display
@onready var  CD_Disc : TextureRect = $CD_player_body/CD_Disc
@onready var anim_player: AnimationPlayer =$AnimationPlayer

@onready var prev_button: TextureButton = $CD_player_body/HBoxContainer/Prev_button
@onready var play_button: TextureButton = $CD_player_body/HBoxContainer/Play_button
@onready var next_button: TextureButton = $CD_player_body/HBoxContainer/Next_button

var levels: Array[Dictionary] = [
	{"name": "Our Phantoms Forever", "path": "res://TTDL_TRACKS/TRACK/DEMOLITION_LOVERS(L1/level_1.tscn"},
	{"name": "This is how we do it in the murder scene", "path": "res://TTDL_TRACKS/TRACK/GIVE_EM_HELL_KID(L2)/level_2.tscn"},
	{"name": "Lost in a coma and covered in cake", "path": "res://TTDL_TRACKS/TRACK/TO_THE_END(L3)/level_3.tscn"},
	{"name": "Cause I'm gonna string this --------------", "path":"res://TTDL_TRACKS/TRACK/YKWTDTGLUIP(L4)/level_4.tscn"}
]

var current_track_index: int = 0 
var is_manipulating_disc : bool = false

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	prev_button.pressed.connect(_on_prev_buttion_pressed)
	next_button.pressed.connect(_on_next_button_pressed)
	play_button.pressed.connect(_on_play_button_pressed)
	
	update_LCD_readout()

func _process(delta: float) -> void:
	if CD_Disc:
		CD_Disc.rotation += 2 * delta
		

func update_LCD_readout() -> void:
	var TRACK_num = current_track_index + 1
	var TRACK_name = levels[current_track_index]["name"]
	LCD_display.text ="TRACK %02d: %s\n READY" % [TRACK_num, TRACK_name]

func change_track(direction : int ) -> void:
	if is_manipulating_disc: return
	is_manipulating_disc = true
	
	LCD_display.text = "EJECTING..."
	anim_player.play("OPEN_LID")
	await anim_player.animation_finished
	
	current_track_index = posmod(current_track_index + direction, levels.size())
	var TRACK_num = current_track_index + 1
	var TRACK_name = levels[current_track_index]["name"]
	
	LCD_display.text = "TRACK: %02d: %s READING DISC..." % [TRACK_num, TRACK_name]
	await get_tree().create_timer(0.2).timeout
	
	anim_player.play("CLOSE_LID")
	await anim_player.animation_finished
	
	update_LCD_readout()
	is_manipulating_disc = false

func _on_next_button_pressed() -> void:
	change_track(1)


func _on_prev_buttion_pressed() -> void:
	change_track(-1)

func _on_play_button_pressed() -> void:
	if is_manipulating_disc: return
	is_manipulating_disc = true
	
	var TRACK_num = current_track_index + 1
	var TRACK_name = levels[current_track_index]["name"]
	LCD_display.text = "TRACK: %02d\nSPINNING UP....." % [TRACK_num,TRACK_name]
	
	await get_tree().create_timer(0.4).timeout
	
	var target_scene = levels[current_track_index]
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	get_tree().change_scene_to_file(target_scene)
