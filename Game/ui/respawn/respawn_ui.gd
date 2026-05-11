extends Control
class_name RespawnUI

signal respawn_requested
signal main_menu_requested

@onready var respawn_button: Button = $DeathPanel/VBoxContainer/RespawnButton
@onready var main_menu_button: Button = $DeathPanel/VBoxContainer/MainMenuButton

func _ready() -> void:
	visible = false
	mouse_filter = Control.MOUSE_FILTER_STOP

	respawn_button.pressed.connect(_on_respawn_pressed)
	main_menu_button.pressed.connect(_on_main_menu_pressed)

func show_screen() -> void:
	visible = true
	respawn_button.grab_focus()

func hide_screen() -> void:
	visible = false

func _on_respawn_pressed() -> void:
	respawn_requested.emit()

func _on_main_menu_pressed() -> void:
	main_menu_requested.emit()
