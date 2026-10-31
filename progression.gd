extends Node

const DATA := preload("res://build_data.gd")
const SAVE_PATH := "user://progression.cfg"
const STARTING_COINS := 600
var coins := STARTING_COINS
var test_grant_applied := false
var owned: Dictionary = {}
var preview_only := false
var persistence := true
var load_failed := false

func _ready() -> void:
	persistence = not preview_only and not "--lab-test" in OS.get_cmdline_user_args()
	if not persistence: return
	var config := ConfigFile.new()
	var error := config.load(SAVE_PATH)
	if error != OK:
		load_failed = error != ERR_FILE_NOT_FOUND
		if not load_failed:
			test_grant_applied = true
			save()
		return
	coins = maxi(0, int(config.get_value("profile", "coins", 0)))
	test_grant_applied = bool(config.get_value("profile", "test_grant_600_v1", false))
	for id in config.get_value("profile", "owned", PackedStringArray()):
		if DATA.NODES.has(str(id)): owned[str(id)] = true

	if not test_grant_applied:
		coins = maxi(coins, STARTING_COINS)
		test_grant_applied = true
		save()

func has_upgrade(id: String) -> bool:
	return id == "core" or owned.has(id)

func effect(key: String) -> float:
	var total := 0.0
	for id in owned: total += float(DATA.NODES[id].effects.get(key, 0.0))
	return total

func can_buy(id: String) -> bool:
	if load_failed or not DATA.NODES.has(id) or has_upgrade(id): return false
	for parent in DATA.NODES[id].parents:
		if not has_upgrade(parent): return false
	return coins >= int(DATA.NODES[id].cost)

func buy(id: String) -> bool:
	if not can_buy(id): return false
	coins -= int(DATA.NODES[id].cost)
	owned[id] = true
	if save() != OK:
		owned.erase(id)
		coins += int(DATA.NODES[id].cost)
		return false
	return true

func credit(amount: int) -> bool:
	if amount <= 0 or load_failed: return false
	coins += amount
	if save() != OK:
		coins -= amount
		return false
	return true

func save() -> Error:
	if not persistence: return OK
	if load_failed: return ERR_FILE_CORRUPT
	var config := ConfigFile.new()
	config.set_value("profile", "coins", coins)
	config.set_value("profile", "test_grant_600_v1", test_grant_applied)
	config.set_value("profile", "owned", PackedStringArray(owned.keys()))
	return config.save(SAVE_PATH)
