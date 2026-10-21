extends CanvasLayer

@onready var crosshair_sprite: TextureRect = $CrossHairSprite

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	
	crosshair_sprite.pivot_offset = Vector2( 8, 8)

func _process(_delta: float) -> void:
	var mouse_pos = crosshair_sprite.get_viewport().get_mouse_position()
	crosshair_sprite.global_position = mouse_pos - Vector2( 8, 8)

func pulse_crosshair() -> void:
	crosshair_sprite.scale = Vector2( 1.3, 1.53)
	
	var tween = create_tween()
	tween.tween_property(crosshair_sprite, "scale", Vector2.ONE, 0.15).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
