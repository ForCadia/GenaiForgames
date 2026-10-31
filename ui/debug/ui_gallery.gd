extends Node

var game: Node
var selector: OptionButton
var pages := ["Start", "Controls", "HUD", "Reload", "Boss", "Pause", "Death", "Victory", "Developer", "Banner", "Tutorial", "BossArmor", "BossPhase2"]

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	game = preload("res://main.tscn").instantiate()
	game.ui_preview = true
	add_child(game)
	game.set_process(false)
	game.set_process_unhandled_input(false)
	var layer := CanvasLayer.new()
	layer.layer = 100
	add_child(layer)
	var root := preload("res://ui/ui_factory.gd").root(layer)
	var row := HBoxContainer.new()
	root.add_child(row)
	row.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	row.grow_horizontal = Control.GROW_DIRECTION_BOTH
	row.grow_vertical = Control.GROW_DIRECTION_BEGIN
	preload("res://ui/ui_factory.gd").label(row, "UI PREVIEW / FIXTURE DATA", "AmberLabel")
	selector = OptionButton.new()
	row.add_child(selector)
	for page in pages: selector.add_item(page)
	selector.item_selected.connect(show_page)
	show_page(0)

func show_page(index: int) -> void:
	selector.select(index)
	game.return_to_start()
	if index == 0: return
	if index == 1:
		game.start_screen.show_controls(true)
		return
	game.start_game("checkpoint", 0, false, index in [4, 11, 12])
	game.lab_panel.blocked = false
	game.lab_panel.release_pending = false
	game.score = 2450
	game.stats = {"unarmored": 12, "light": 3, "heavy": 4, "flyer": 2}
	game.run_elapsed = 147
	game.run_deaths = 2
	game.guard_energy = 68
	game.banner_time = 0
	game.has_grenade = true
	if index == 3:
		game.ammo[0] = 0
		game.reload_left = 0.6
	if index == 4:
		game.boss.hp = 8
		game.boss.armor = 0
	if index == 12:
		game.boss.armor = 1
		game.boss.phase = 2
	if index == 9:
		game.banner_time = 3
	if index == 10:
		game.run_elapsed = 0
		game.player_hud._process(0)
	if index == 5: game.set_ui_paused(true)
	if index == 6:
		game.state = "dead"
		game.death_ui_ready = true
		game.banner = "HOSTILE FIRE"
	if index == 7: game.state = "victory"
	if index == 8:
		# Preview the real controls without starting or recording an experiment.
		game.developer_mode = true
		game.lab_panel.show()
		game.lab_panel.panel.show()
		game.lab_panel.expanded = true
	game._refresh_player_ui()
	game.player_hud.sync()
	game.overlays._process(0)
	game.boss_actor.set_combat_enabled(false)
	get_tree().paused = true

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode in [KEY_PAGEDOWN, KEY_PAGEUP]:
			show_page(posmod(selector.selected + (1 if event.keycode == KEY_PAGEDOWN else -1), pages.size()))
			get_viewport().set_input_as_handled()
