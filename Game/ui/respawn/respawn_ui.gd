extends Control
class_name RespawnUI

signal respawn_requested
signal quit_requested

@onready var respawn_button: Button = $DeathPanel/VBoxContainer/RespawnButton
@onready var quit_button: Button = $DeathPanel/VBoxContainer/QuitButton


func _ready() -> void:
	visible = false
	mouse_filter = Control.MOUSE_FILTER_STOP

	respawn_button.pressed.connect(_on_respawn_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

func show_screen() -> void:
	visible = true
	respawn_button.grab_focus()

func hide_screen() -> void:
	visible = false

func _on_respawn_pressed() -> void:
	respawn_requested.emit()

func _on_quit_pressed() -> void:
	quit_requested.emit()
