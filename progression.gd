extends Node

const DATA := preload("res://build_data.gd")
const SAVE_PATH := "user://progression.cfg"
const STARTING_COINS := 600
var save_path := SAVE_PATH
var profile_name := ""
var named_profile := false
var unlocked_stage := 3
var records: Dictionary = {}
var coins := STARTING_COINS
var test_grant_applied := false
var owned: Dictionary = {}
var preview_only := false
var persistence := true
var load_failed := false

func configure_named(player_name: String) -> void:
	profile_name = player_name.strip_edges().left(32)
	named_profile = true
	save_path = "user://profiles/" + profile_name.to_lower().sha256_text() + ".cfg"
	coins = 0
	unlocked_stage = 0
	owned.clear()
	records.clear()
	test_grant_applied = true

func _ready() -> void:
	persistence = not preview_only and not "--lab-test" in OS.get_cmdline_user_args()
	if persistence and load_profile() != OK: load_failed = true

func load_profile() -> Error:
	var config := ConfigFile.new()
	var error := config.load(save_path)
	if error != OK:
		load_failed = error != ERR_FILE_NOT_FOUND
		if not load_failed:
			test_grant_applied = true
			return save()
		return error
	coins = maxi(0,int(config.get_value("profile","coins",0)))
	unlocked_stage = clampi(int(config.get_value("profile","unlocked_stage",0 if named_profile else 3)),0,3)
	owned.clear()
	for id in config.get_value("profile","owned",PackedStringArray()):
		if DATA.NODES.has(str(id)): owned[str(id)] = true
	records.clear()
	var saved_records = config.get_value("profile","records",{})
	if saved_records is Dictionary:
		for key in saved_records: records[str(key)] = maxi(0,int(saved_records[key]))
	test_grant_applied = bool(config.get_value("profile","test_grant_600_v1",false))
	if not named_profile and not test_grant_applied:
		coins = maxi(coins,STARTING_COINS)
		test_grant_applied = true
		return save()
	return OK

func unlock_after(level: int) -> bool:
	var before := unlocked_stage
	unlocked_stage = maxi(unlocked_stage,mini(3,level+1))
	if save() != OK:
		unlocked_stage = before
		return false
	return true

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
	config.set_value("profile", "name", profile_name)
	config.set_value("profile", "unlocked_stage", unlocked_stage)
	config.set_value("profile", "records", records)
	config.set_value("profile", "coins", coins)
	config.set_value("profile", "test_grant_600_v1", test_grant_applied)
	config.set_value("profile", "owned", PackedStringArray(owned.keys()))
	var directory := ProjectSettings.globalize_path(save_path.get_base_dir())
	var error := DirAccess.make_dir_recursive_absolute(directory)
	if error != OK: return error
	return config.save(save_path)
