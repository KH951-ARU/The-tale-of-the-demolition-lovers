extends Node

signal kills_updated(new_count: int)

var total_kills: int = 0:
	set(value):
		total_kills = clamp(value, 0 ,999)
		kills_updated.emit(total_kills)

func add_kill() -> void:
	total_kills += 1

func reset_kills() -> void:
	total_kills = 0
