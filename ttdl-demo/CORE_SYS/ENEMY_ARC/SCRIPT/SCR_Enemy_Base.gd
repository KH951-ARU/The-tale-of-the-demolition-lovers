class_name EnemyBase
extends CharacterBody2D

@export var movement_speed: float = 200
@export var rotation_speed: float = 10
@export var max_health: int =1

var current_health : int 
enum AIState {IDLE, ALERT, CHARGING }
var current_state : AIState = AIState.IDLE

var target_player : CharacterBody2D = null
var lastr_known_sound_pos : Vector2 = Vector2.ZERO

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
