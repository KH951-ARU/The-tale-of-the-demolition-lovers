extends CharacterBody2D

@export var movement_speed: float = 220
@export var rotation_speed: float = 10

enum AIState { IDLE, ALERT, CHARGING }
var current_state : AIState = AIState.IDLE

var target_player : CharacterBody2D = null
var last_known_sound_pos : Vector2 = Vector2.ZERO

func _ready() -> void:
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		target_player = players[0]
		

func _physics_process(delta: float) -> void:
	match current_state:
		AIState.IDLE:
			velocity = Vector2.ZERO
		
		AIState.ALERT:
			rotate_towards_target(last_known_sound_pos, delta)
			
			#move to location
			var dir = (last_known_sound_pos - global_position).normalized()
			velocity = dir * movement_speed
			
			if global_position.distance_to(last_known_sound_pos) < 20:
				current_state = AIState.IDLE
		
		AIState.CHARGING:
			if target_player:
				rotate_towards_target(target_player.global_position, delta)
				var dir = (target_player.global_position - global_position).normalized()
				velocity = dir * movement_speed
				
				if global_position.distance_to(target_player.global_position) < 40:
					if target_player.has_method("die"):
						target_player.die()
	move_and_slide()

func rotate_towards_target(target_pos : Vector2, delta : float) -> void:
	var target_angle = (target_pos - global_position).angle()
	global_rotation = lerp_angle(global_rotation, target_angle, rotation_speed * delta)

func _on_hearing_radius_body_entered(body: Node2D) -> void:
	if body.name.begins_with("Bullet") or body.is_in_group("bullets"):
		if current_state == AIState.CHARGING:
			return
			
		last_known_sound_pos = body.global_position
		current_state = AIState.ALERT
		
		await get_tree().create_timer(0.3).timeout
		current_state = AIState.CHARGING
	

func take_damage(amount: int) -> void:
	queue_free()
