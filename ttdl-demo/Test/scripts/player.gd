extends CharacterBody2D

## movement config
@export var speed: float = 300
@export var acceleration: float = 0.2

# inventory management
@export var inventory: Array[WeaponData] = []
var current_weapon_index: int = 0
var current_weapon : WeaponData = null

###shooting config
#@export var bullet_scene: PackedScene = preload("res://Test/scenes/bullet.tscn")
#@export var fire_rate: float = 0.15
#@export var gun_spread_deg : float = 4.0
#@export var recoil_shake_strength: float = 12

@onready var muzzle: Marker2D = $Muzzle

var can_shoot: bool = true
var camera_node: Camera2D

func _ready() -> void:
	#fetch cameras
	var cameras = get_tree().get_nodes_in_group("Camera")
	if cameras.size() > 0:
		camera_node = cameras[0]
	# initalise inventory if weapons exist
	if inventory.size() > 0:
		equip_weapon(0)

func _physics_process(_delta: float) -> void:
	handle_movement()
	handle_rotation()
	handle_inventory_input()
	
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

func handle_inventory_input() -> void:
	# handles weapon swaping
	if Input.is_action_just_pressed("ui_focus_next") or Input.is_action_just_pressed("next_weapon"):
		cycle_weapon(1)
	elif Input.is_action_just_pressed("ui_focus_prev") or Input.is_action_just_pressed("prev_weapon"):
		cycle_weapon(-1)

##equips weapon
func equip_weapon(index : int) -> void:
	if index >= 0 and index < inventory.size():
		current_weapon_index = index
		current_weapon = inventory[index]
		print("equiped weapon: ", current_weapon.weapon_name)

## cycling thorogh weapons
func cycle_weapon(direction : int ) -> void:
	if inventory.size() <= 1: return
	var new_index = (current_weapon_index + direction) % inventory.size()
	if new_index < 0:
		new_index = inventory.size() - 1
	equip_weapon(new_index)


## firing weapon
func shoot() -> void: 
	can_shoot = false
	
	#spawn projectile
	var bullet_inst = current_weapon.bullet_scene.instantiate() as CharacterBody2D
	
	# randomised spread for weapons
	var max_spread = current_weapon.gun_spread_deg
	var random_spread = deg_to_rad(randf_range(-max_spread,max_spread))
	
	#set postition of muzzle with player position & random spread
	bullet_inst.global_position = muzzle.global_position
	bullet_inst.rotation = global_rotation + random_spread
	
	# add to bullet to root (so it can travel
	get_tree().current_scene.add_child(bullet_inst)
	
	#screen shake
	if camera_node:
		camera_node.apply_shake(current_weapon.shake_strength)
	#enforce fire rate 
	await get_tree().create_timer(current_weapon.fire_rate).timeout
	can_shoot = true
