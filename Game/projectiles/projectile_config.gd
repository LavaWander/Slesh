# this script creates the ProjectileConfig resource TYPE, which you can use to create a resource

extends Resource
class_name ProjectileConfig

@export var projectile_scene: PackedScene

@export var speed: float = 300.0
@export var lifetime: float = 1.0
@export var damage: int = 1
@export var size: float = 1.0
