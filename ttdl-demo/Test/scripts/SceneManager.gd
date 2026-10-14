extends Node

var fade_layer_scene: PackedScene = preload("res://Test/scenes/fade_layer.tscn")

func reload_current_floor() -> void:
	var fade_instance = fade_layer_scene.instantiate()
	get_tree().root.add_child(fade_instance)
	
	var anim_player = fade_instance.get_node("AnimationPlayer") as AnimationPlayer
	
	#fade to black
	anim_player.play("fade")
	await  anim_player.animation_finished
	
	#reload
	get_tree().reload_current_scene()
	
	#fade back in 
	anim_player.play_backwards("fade")
	await  anim_player.animation_finished
	
	#clean up
	fade_instance.queue_free()
