extends CharacterBody2D

## movement config
@export var speed: float = 300
@export var acceleration: float = 0.2

##shooting config
@export var bullet_scene: PackedScene = preload("res://Test/scenes/bullet.tscn")
@export var fire_rate: float = 0.15
@export var gun_spread_deg : float = 4.0
@export var recoil_shake_strength: float = 12

@onready var muzzle: Marker2D = $Muzzle

var can_shoot: bool = true
var camera_node: Camera2D

func _ready() -> void:
	var cameras = get_tree().get_nodes_in_group("Camera")
	if cameras.size() > 0:
		camera_node = cameras[0]

func _physics_process(_delta: float) -> void:
	handle_movement()
	handle_rotation()
	
	if Input.is_action_pressed("shoot") and can_shoot:
		shoot()

## grid based movement
func handle_movement() -> void:
	var input_direction := Input.get_vector("move_left", "move_right","move_up","move_down")
	
	#smooth accelerate & decelerate
	if input_direction != Vector2.ZERO:
		velocity = velocity.lerp(input_direction * speed, acceleration)
	else:
		velocity = velocity.lerp(Vector2.ZERO, acceleration)
	move_and_slide()

## mouse / cursor based rotation
func handle_rotation() -> void:
	var mouse_pos = get_global_mouse_position()
	look_at(mouse_pos)

## firing weapon
func shoot() -> void: 
	can_shoot = false
	
	#spawn projectile
	var bullet_inst = bullet_scene.instantiate() as CharacterBody2D
	
	# randomised spread for weapons
	var random_spread = deg_to_rad(randf_range(-gun_spread_deg,gun_spread_deg))
	
	#set postition of muzzle with player position & random spread
	bullet_inst.global_position = muzzle.global_position
	bullet_inst.rotation = global_rotation + random_spread
	
	# add to bullet to root (so it can travel
	get_tree().current_scene.add_child(bullet_inst)
	
	#screen shake
	if camera_node:
		camera_node.apply_shake(recoil_shake_strength)
	#enforce fire rate 
	await get_tree().create_timer(fire_rate).timeout
	can_shoot = true
