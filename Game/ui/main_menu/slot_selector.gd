extends Control

## Slot selector panel — shown from the main menu.
## Operates in two modes:
##   MODE_NEW_GAME  — any slot is selectable; overwriting an occupied slot requires confirmation
##   MODE_CONTINUE  — only occupied slots are selectable

signal slot_chosen(slot_index: int)
signal back_requested

enum Mode { MODE_NEW_GAME, MODE_CONTINUE }

const SLOT_BUTTON_SCENE := preload("res://ui/main_menu/slot_button.tscn")

@onready var title_label: Label = $Panel/VBoxContainer/TitleLabel
@onready var slots_container: VBoxContainer = $Panel/VBoxContainer/SlotsScroll/SlotsContainer
@onready var back_button: Button = $Panel/VBoxContainer/BackButton
@onready var confirm_dialog: ConfirmationDialog = $ConfirmDialog

var current_mode: Mode = Mode.MODE_NEW_GAME
var _pending_overwrite_index: int = -1
var _slot_buttons: Array[SlotButton] = []


func _ready() -> void:
	visible = false
	back_button.pressed.connect(_on_back_pressed)
	confirm_dialog.confirmed.connect(_on_overwrite_confirmed)


func show_selector(mode: Mode) -> void:
	current_mode = mode

	if mode == Mode.MODE_NEW_GAME:
		title_label.text = "New Game — Choose a Slot"
	else:
		title_label.text = "Continue — Choose a Slot"

	_rebuild_slot_list()
	visible = true


func hide_selector() -> void:
	visible = false


func _rebuild_slot_list() -> void:
	# Clear existing buttons
	for btn in _slot_buttons:
		if is_instance_valid(btn):
			btn.queue_free()
	_slot_buttons.clear()

	var summaries := SaveManager.get_all_slot_summaries()

	for summary in summaries:
		var btn := SLOT_BUTTON_SCENE.instantiate() as SlotButton
		slots_container.add_child(btn)
		btn.setup(summary["index"], summary)
		btn.slot_selected.connect(_on_slot_selected)
		btn.slot_delete_requested.connect(_on_slot_delete_requested)

		# In Continue mode, only occupied slots are selectable
		if current_mode == Mode.MODE_CONTINUE:
			btn.set_selectable(summary["occupied"])

		_slot_buttons.append(btn)


func _on_slot_selected(slot_index: int) -> void:
	if current_mode == Mode.MODE_CONTINUE:
		# Can only select occupied slots
		if not SaveManager.is_slot_occupied(slot_index):
			return
		slot_chosen.emit(slot_index)

	elif current_mode == Mode.MODE_NEW_GAME:
		if SaveManager.is_slot_occupied(slot_index):
			# Show overwrite confirmation
			_pending_overwrite_index = slot_index
			confirm_dialog.dialog_text = "Slot %d has existing save data.\nOverwrite it with a new game?" % (slot_index + 1)
			confirm_dialog.popup_centered()
		else:
			slot_chosen.emit(slot_index)


func _on_overwrite_confirmed() -> void:
	if _pending_overwrite_index >= 0:
		slot_chosen.emit(_pending_overwrite_index)
		_pending_overwrite_index = -1


func _on_slot_delete_requested(slot_index: int) -> void:
	SaveManager.delete_slot(slot_index)
	_rebuild_slot_list()


func _on_back_pressed() -> void:
	hide_selector()
	back_requested.emit()
