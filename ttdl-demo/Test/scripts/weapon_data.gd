class_name WeaponData
extends Resource

@export var weapon_name: String = "Pistol"
@export var fire_rate: float = 0.25 # delay between shots
@export var gun_spread_deg: float = 3 #max inaccuracy spread
@export var shake_strength: float = 8 # screen shake intensity

@export_group("Projectile Layout")
@export var bullet_scene :PackedScene = preload("res://Test/scenes/bullet.tscn")
@export var bullets_per_shot: int = 1 # 1 = pistol, 5+ shotgun
