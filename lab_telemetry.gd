extends RefCounted

const VERSION := "lab-b-0.2"
var session_id := ""
var run_id := ""
var events: Array[Dictionary] = []
var run_number := 0
var active := false
var duration := 0.0
var failed_at := -1
var failed_run := ""
var variant := "A"
var restart_mode := "checkpoint"
var parameter_mode := "原版"
var segment := 0
var boss := false
var start_score := 0
var retry_pressed_at := -1
var failed_variant := ""
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
	clear_pending_retry()
	record("session_start")

func clear_pending_retry() -> void:
	failed_at = -1
	failed_run = ""
	retry_pressed_at = -1
	failed_variant = ""

func set_location(current_segment: int, is_boss: bool) -> void:
	segment = current_segment
	boss = is_boss

func record(kind: String, details: Dictionary = {}) -> void:
	var event := {"event": kind, "session_id": session_id, "run_id": run_id,
		"timestamp": Time.get_datetime_string_from_system(true) + "Z",
		"monotonic_ms": Time.get_ticks_msec(), "version": VERSION,
		"variant": variant, "restart_mode": restart_mode,
		"parameter_mode": parameter_mode, "experiment_preset": parameter_mode, "segment": segment,
		"checkpoint": "boss" if boss else "segment_%d" % segment,
		"boss": boss, "parameters": snapshot.duplicate(true)}
	event.merge(details, true)
	events.append(event)
	persist()

func start(parameters: Dictionary, mode: String, preset: String, current_segment: int, is_boss: bool, score: int) -> void:
	snapshot = parameters.duplicate(true)
	restart_mode = mode
	variant = "A" if mode == "checkpoint" else "B"
	parameter_mode = preset
	set_location(current_segment, is_boss)
	start_score = score
	run_number += 1
	run_id = "%s-run-%03d" % [session_id, run_number]
	duration = 0.0
	active = true
	record("run_start", {"score": score, "start_score": start_score})

func finish(score: int, reason: String, position: Vector2, current_segment: int, is_boss: bool, failure := false) -> void:
	if not active: return
	active = false
	set_location(current_segment, is_boss)
	if failure:
		failed_at = Time.get_ticks_msec()
		failed_run = run_id
		failed_variant = variant
		retry_pressed_at = -1
	record("run_end", {"duration": duration, "score": score, "cause": reason,
		"start_score": start_score, "score_delta": score - start_score,
		"x": position.x, "y": position.y,
		"failure": failure, "failure_position": {"x": position.x, "y": position.y} if failure else null})

func request_retry(action: String) -> void:
	if failed_at < 0 or retry_pressed_at >= 0: return
	retry_pressed_at = Time.get_ticks_msec()
	record("retry_requested", {"failed_run_id": failed_run, "input_action": action,
		"retry_input_monotonic_ms": retry_pressed_at,
		"failure_to_input_seconds": float(retry_pressed_at - failed_at) / 1000.0})

func retry() -> void:
	if failed_at < 0: return
	if retry_pressed_at < 0: request_retry("direct_retry")
	var ready_at := Time.get_ticks_msec()
	record("retry", {"failed_run_id": failed_run, "variant": failed_variant,
		"retry_input_monotonic_ms": retry_pressed_at, "restart_monotonic_ms": ready_at,
		"failure_to_input_seconds": float(retry_pressed_at - failed_at) / 1000.0,
		"failure_to_restart_seconds": float(ready_at - failed_at) / 1000.0,
		"input_to_restart_seconds": float(ready_at - retry_pressed_at) / 1000.0})
	clear_pending_retry()

func document() -> Dictionary:
	return {"schema_version": 2, "version": VERSION, "session_id": session_id,
		"exported_at": Time.get_datetime_string_from_system(true) + "Z",
		"retry_definition": "unique failed runs retried / actual failures of the same variant; quick retry uses failure_to_input_seconds <= 10; administrative resets excluded",
		"duration_definition": "active gameplay seconds, excluding tuning panel pauses",
		"variant_summary": variant_statistics(), "events": events}

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

func variant_statistics() -> Dictionary:
	var result := {"A": {"failures": 0, "retries": 0, "quick_retries": 0},
		"B": {"failures": 0, "retries": 0, "quick_retries": 0}}
	var failed_runs := {}
	var counted := {}
	for event in events:
		if event.event == "run_end" and event.failure:
			failed_runs[event.run_id] = event.variant
			result[event.variant].failures += 1
		elif event.event == "retry" and failed_runs.has(event.failed_run_id) and not counted.has(event.failed_run_id):
			var failed_mode: String = failed_runs[event.failed_run_id]
			counted[event.failed_run_id] = true
			result[failed_mode].retries += 1
			if event.failure_to_input_seconds <= 10: result[failed_mode].quick_retries += 1
	for key in result:
		var row: Dictionary = result[key]
		row["retry_rate"] = float(row.retries) / row.failures if row.failures > 0 else null
		row["quick_retry_rate"] = float(row.quick_retries) / row.failures if row.failures > 0 else null
	return result

func summary() -> String:
	var lengths: Array[float] = []
	for event in events:
		if event.event == "run_end":
			if event.failure or event.cause == "victory": lengths.append(float(event.duration))
	lengths.sort()
	var median := "N/A"
	if not lengths.is_empty():
		var middle := int(lengths.size() / 2)
		var value: float = lengths[middle] if lengths.size() % 2 else (lengths[middle - 1] + lengths[middle]) / 2.0
		median = "%.1fs" % value
	var text := "Runs %d | median %s" % [run_number, median]
	var data := variant_statistics()
	for key in ["A", "B"]:
		var row: Dictionary = data[key]
		var rate := "N/A" if row.retry_rate == null else "%.0f%%" % (row.retry_rate * 100)
		var quick := "N/A" if row.quick_retry_rate == null else "%.0f%%" % (row.quick_retry_rate * 100)
		text += "\n%s: failures %d | retries %d | rate %s | <=10s %s" % [key, row.failures, row.retries, rate, quick]
	return text
