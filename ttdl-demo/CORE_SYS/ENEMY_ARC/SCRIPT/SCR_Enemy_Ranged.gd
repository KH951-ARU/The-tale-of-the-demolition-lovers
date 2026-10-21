extends EnemyBase

@export_group("Ranged Weapon Properties")
@export var bullet_scene: PackedScene = preload("res://Test/scenes/bullet.tscn")
@export var shoot_range: float = 400.0       # Distance at which they start firing
@export var stop_range: float = 250.0        # Avoid running directly into the player
@export var fire_rate: float = 1.0           # Seconds between shots
@export var gun_spread_deg: float = 6.0      # Inaccuracy

var can_shoot: bool = true
var muzzle: Marker2D

func setup_enemy() -> void:
	# Safely fetch the custom gun muzzle marker node
	if has_node("Muzzle"):
		muzzle = $Muzzle

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
			if not target_player: return
			
			var dist_to_player = global_position.distance_to(target_player.global_position)
			rotate_towards_target(target_player.global_position, delta)
			
			# 1. Handle Tactical Positioning Movement
			if dist_to_player > shoot_range:
				# Too far, advance closer
				var dir = (target_player.global_position - global_position).normalized()
				velocity = dir * movement_speed
			elif dist_to_player < stop_range:
				# Too close, back away to keep distance
				var dir = (global_position - target_player.global_position).normalized()
				velocity = dir * (movement_speed * 0.5)
			else:
				# Perfect range, stay put and aim
				velocity = Vector2.ZERO
				
			# 2. Handle Ranged Shooting Loop
			if dist_to_player <= shoot_range and can_shoot:
				shoot_at_player()

func shoot_at_player() -> void:
	can_shoot = false
	
	if bullet_scene and muzzle:
		var bullet_instance = bullet_scene.instantiate() as CharacterBody2D
		var random_spread = deg_to_rad(randf_range(-gun_spread_deg, gun_spread_deg))
		
		bullet_instance.global_position = muzzle.global_position
		bullet_instance.rotation = global_rotation + random_spread
		
		# Important: Add bullet to the root world container, not the enemy container!
		get_tree().current_scene.add_child(bullet_instance)
		
	# Wait for weapon cool-down sequence
	await get_tree().create_timer(fire_rate).timeout
	can_shoot = true
