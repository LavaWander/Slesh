extends Node

var items_by_id: Dictionary = {}

const ITEMS_ROOT := "res://items"


func _ready() -> void:
	load_all_items()


func load_all_items() -> void:
	items_by_id.clear()
	_scan_dir(ITEMS_ROOT)


func get_item(item_id: StringName) -> ItemData:
	if items_by_id.has(item_id):
		return items_by_id[item_id]
	return null


func _scan_dir(path: String) -> void:
	var dir := DirAccess.open(path)
	if dir == null:
		push_error("Could not open item directory: " + path)
		return

	dir.list_dir_begin()
	var file_name := dir.get_next()

	while file_name != "":
		if file_name == "." or file_name == "..":
			file_name = dir.get_next()
			continue

		var full_path := path.path_join(file_name)

		if dir.current_is_dir():
			_scan_dir(full_path)
		else:
			if file_name.ends_with(".tres") or file_name.ends_with(".res"):
				var resource := load(full_path)
				if resource is ItemData:
					var item := resource as ItemData

					if item.item_id == StringName():
						push_warning("ItemData missing item_id: " + full_path)
					elif items_by_id.has(item.item_id):
						push_warning("Duplicate item_id '%s' at %s" % [String(item.item_id), full_path])
					else:
						items_by_id[item.item_id] = item

		file_name = dir.get_next()

	dir.list_dir_end()
