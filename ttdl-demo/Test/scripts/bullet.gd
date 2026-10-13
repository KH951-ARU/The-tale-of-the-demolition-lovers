extends CharacterBody2D

@export var speed: float = 1200 
@export var damage : int = 1

func _ready() -> void:
	velocity = Vector2.RIGHT.rotated(rotation) * speed

func _physics_process(delta: float) -> void:
	var collision = move_and_collide(velocity * delta)
	if collision:
		var collider = collision.get_collider()
		if collider.has_method("take_damage"):
			collider.take_damage(damage)
		
		queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
