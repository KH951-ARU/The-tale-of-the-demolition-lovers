extends CanvasLayer

@onready var kills_label: Label = $KillsLabel

func _ready() -> void:
	ScoreManager.kills_updated.connect(_on_kills_updated)
	
	_on_kills_updated(ScoreManager.total_kills)
	

func _on_kills_updated(new_count: int) -> void:
	kills_label.text = "Kills: %03d" % new_count
