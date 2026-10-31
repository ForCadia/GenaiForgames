@tool
extends EditorScript

func _run() -> void:
	var theme: Theme = preload("res://ui/theme_builder.gd").build()
	ResourceSaver.save(theme,"res://ui/ui_theme.tres")
