class_name EnemyBase
extends CharacterBody2D

@export var movement_speed: float = 200
@export var rotation_speed: float = 10
@export var max_health: int =1

var current_health : int 
enum AIState {IDLE, ALERT, CHARGING }
var current_state : AIState = AIState.IDLE

var target_player : CharacterBody2D = null
var last_known_sound_pos : Vector2 = Vector2.ZERO

func _ready() -> void:
	current_health = max_health
	add_to_group("enemies")
	
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		target_player = players[0]
		
	setup_enemy()

func _physics_process(delta: float) -> void:
	if current_health <= 0: return
	process_ai(delta)
	move_and_slide()

func setup_enemy() -> void:
	pass

func process_ai(_delta: float) -> void:
	pass

func rotate_towards_target(target_pos: Vector2, delta: float) -> void:
	var target_angle = (target_pos - global_position).angle()
	global_rotation = lerp_angle(global_rotation,target_angle,rotation_speed * delta)

func _on_hearing_radius_body_entered(body : Node2D) -> void:
	if body.name.begins_with("Bullet") or body.is_in_group("bullets"):
		if current_state == AIState.CHARGING: return
		
		last_known_sound_pos = body.global_position
		current_state = AIState.ALERT
		
		await get_tree().create_timer(0.3).timeout
		if current_health > 0:
			current_state = AIState.CHARGING

func take_damage(amount: int) -> void:
	if current_health <= 0:return
	current_health -= amount
	current_state = AIState.CHARGING
	if current_health <= 0:
		die()

func die() -> void:
	current_health = 0
	ScoreManager.add_kill()
	queue_free()
	
