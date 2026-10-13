extends Camera2D

@export var player : CharacterBody2D # player ref
@export var camera_speed : float = 0.1 # weight for mouse influence
@export var shake_decay: float = 15

var shake_strength: float = 0

func _ready() -> void:
	#ease to access for the camera to shake
	add_to_group("Camera")

func _process(delta: float) -> void:
	if not player:
		return
	
	#look ahead lerp
	var mouse_pos = get_global_mouse_position()
	var target_pos = player.global_position.lerp(mouse_pos, camera_speed)
	
	# shake shake the screen
	shake_strength = move_toward(shake_strength, 0.0, shake_decay * delta)
	
	# calculate the offsets
	var shake_offset = Vector2(
		randf_range(-shake_strength,shake_strength),
		randf_range(-shake_strength,shake_strength)
	)
	
	#tracking pos & screen shake offset
	global_position = target_pos + shake_offset
	

func apply_shake(strength: float) -> void:
	shake_strength = strength
