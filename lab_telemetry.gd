extends RefCounted

const VERSION := "lab-b-0.1"
var session_id := ""
var run_id := ""
var events: Array[Dictionary] = []
var run_number := 0
var active := false
var duration := 0.0
var failed_at := -1
var failed_run := ""
var variant := "baseline_pending"
var snapshot := {}
var persistence := not "--lab-test" in OS.get_cmdline_user_args()
var storage := "user://lab_b_telemetry"
var last_error := ""

func _init() -> void:
	for key in preload("res://lab_panel.gd").SPECS:
		snapshot[key] = preload("res://lab_panel.gd").SPECS[key][1]
	snapshot["particles_enabled"] = true
	new_session()

func new_session() -> void:
	session_id = "%s-%s" % [Time.get_unix_time_from_system(), Time.get_ticks_usec()]
	run_id = ""
	run_number = 0
	events.clear()
	active = false
	duration = 0.0
	failed_at = -1
	failed_run = ""
	record("session_start")

func record(kind: String, details: Dictionary = {}) -> void:
	var event := {"event": kind, "session_id": session_id, "run_id": run_id,
		"timestamp": Time.get_datetime_string_from_system(true) + "Z",
		"monotonic_ms": Time.get_ticks_msec(), "version": VERSION,
		"variant": variant, "parameters": snapshot.duplicate(true)}
	event.merge(details, true)
	events.append(event)
	persist()

func start(parameters: Dictionary, current_variant: String) -> void:
	snapshot = parameters.duplicate(true)
	variant = current_variant
	run_number += 1
	run_id = "%s-run-%03d" % [session_id, run_number]
	duration = 0.0
	active = true
	record("run_start")

func finish(score: int, reason: String, position: Vector2, segment: int, boss: bool, failure := false) -> void:
	if not active: return
	active = false
	record("run_end", {"duration": duration, "score": score, "cause": reason,
		"x": position.x, "y": position.y, "segment": segment, "boss": boss,
		"failure": failure, "failure_position": {"x": position.x, "y": position.y} if failure else null})
	if failure:
		failed_at = Time.get_ticks_msec()
		failed_run = run_id

func retry() -> void:
	if failed_at < 0: return
	record("retry", {"failed_run_id": failed_run, "failure_to_restart_seconds":
		float(Time.get_ticks_msec() - failed_at) / 1000.0})
	failed_at = -1
	failed_run = ""

func document() -> Dictionary:
	return {"schema_version": 1, "version": VERSION, "session_id": session_id,
		"exported_at": Time.get_datetime_string_from_system(true) + "Z",
		"retry_definition": "retried failed runs / all failed runs; quick retry <= 10 wall-clock seconds",
		"duration_definition": "active gameplay seconds, excluding tuning panel pauses",
		"events": events}

func persist() -> bool:
	if not persistence: return true
	var err := DirAccess.make_dir_recursive_absolute(storage)
	if err != OK:
		last_error = "Local telemetry directory unavailable: %s" % err
		return false
	var file := FileAccess.open(storage.path_join(session_id + ".json"), FileAccess.WRITE)
	if file == null:
		last_error = "Local telemetry write failed: %s" % FileAccess.get_open_error()
		return false
	file.store_string(JSON.stringify(document(), "\t"))
	last_error = ""
	return true

func export_json() -> bool:
	var data := JSON.stringify(document(), "\t")
	if JSON.parse_string(data) == null:
		last_error = "JSON validation failed"
		return false
	if OS.has_feature("web"):
		JavaScriptBridge.download_buffer(data.to_utf8_buffer(), session_id + ".json", "application/json")
		return true
	if not persist(): return false
	if persistence: OS.shell_open(ProjectSettings.globalize_path(storage))
	return true

func summary() -> String:
	var lengths: Array[float] = []
	var failures := 0
	var retries := 0
	var quick := 0
	for event in events:
		if event.event == "run_end":
			if event.failure: failures += 1
			if event.failure or event.cause == "victory": lengths.append(float(event.duration))
		elif event.event == "retry":
			retries += 1
			if event.failure_to_restart_seconds <= 10: quick += 1
	lengths.sort()
	var median := 0.0
	if not lengths.is_empty():
		var middle := lengths.size() / 2
		median = lengths[middle] if lengths.size() % 2 else (lengths[middle - 1] + lengths[middle]) / 2.0
	return "Runs %d | median %.1fs | retry %d/%d | <=10s %d/%d" % [run_number, median, retries, failures, quick, failures]
