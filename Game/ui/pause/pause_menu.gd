extends Control

signal main_menu_requested
signal resume_requested

@onready var resume_button: Button = $Panel/VBoxContainer/ResumeButton
@onready var settings_button: Button = $Panel/VBoxContainer/SettingsButton
@onready var main_menu_button: Button = $Panel/VBoxContainer/MainMenuButton
@onready var quit_button: Button = $Panel/VBoxContainer/QuitButton

func _ready() -> void:
	visible = false
	resume_button.pressed.connect(_on_resume_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	main_menu_button.pressed.connect(_on_main_menu_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

func show_menu() -> void:
	visible = true
	get_tree().paused = true
	resume_button.grab_focus()
	UIState.is_paused = true

func hide_menu() -> void:
	visible = false
	get_tree().paused = false
	UIState.is_paused = false

func _on_resume_pressed() -> void:
	resume_requested.emit()

func _on_settings_pressed() -> void:
	print("Settings menu stub.")

func _on_main_menu_pressed() -> void:
	hide_menu()
	main_menu_requested.emit()

func _on_quit_pressed() -> void:
	get_tree().quit()
