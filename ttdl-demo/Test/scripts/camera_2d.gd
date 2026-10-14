extends Camera2D

@export var player : CharacterBody2D # player ref
@export var camera_speed : float = 0.1 # weight for mouse influence
@export var shake_decay: float = 15

@export var boundary_node_path: NodePath = "../MapBoundary"

var shake_strength: float = 0

func _ready() -> void:
	#ease to access for the camera to shake
	add_to_group("Camera")
	set_camera_limits_from_boundary()

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
	

func set_camera_limits_from_boundary() -> void:
	if not has_node(boundary_node_path):
		print (" map boundary not found")
	
	var boundary_area = get_node(boundary_node_path) as Area2D
	var collision_shape = boundary_area.get_child(0) as CollisionShape2D
	
	if collision_shape and collision_shape.shape is RectangleShape2D:
		var rect_shape = collision_shape.shape as RectangleShape2D
		var size = rect_shape.size
		var half_size = size / 2
		
		var center_pos = collision_shape.global_position
		limit_left = int(center_pos.x - half_size.x)
		limit_top = int(center_pos.y - half_size.y)
		limit_right = int(center_pos.x + half_size.x)
		limit_bottom = int(center_pos.y + half_size.y)

func apply_shake(strength: float) -> void:
	shake_strength = strength
