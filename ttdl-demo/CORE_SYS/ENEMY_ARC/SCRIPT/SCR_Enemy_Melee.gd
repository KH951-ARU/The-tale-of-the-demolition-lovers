extends EnemyBase

@export var attack_range: float = 40.0
@export var attack_damage: int = 1

func process_ai(delta: float) -> void:
	match current_state:
		AIState.IDLE:
			velocity = Vector2.ZERO
			
		AIState.ALERT:
			rotate_towards_target(last_known_sound_pos, delta)
			var dir = (last_known_sound_pos - global_position).normalized()
			velocity = dir * movement_speed
			if global_position.distance_to(last_known_sound_pos) < 20.0:
				current_state = AIState.IDLE
				
		AIState.CHARGING:
			if target_player:
				rotate_towards_target(target_player.global_position, delta)
				var dir = (target_player.global_position - global_position).normalized()
				velocity = dir * movement_speed
				
				# Melee contact attack check
				if global_position.distance_to(target_player.global_position) < attack_range:
					if target_player.has_method("take_damage"):
						target_player.take_damage(attack_damage)
