extends RefCounted

# Offline active-segment RMS calibration; preserve source files and timing.
const GAINS_DB := {
	"untitled_loop60.ogg": -12.73,
	"chase_mode_loop60.ogg": -10.98,
	"boss_melee_sword.wav": 2.95,
	"iron_missile_fire.wav": -7.74,
	"iron_cannon_fire.wav": 3.49,

	"coin_pickup.wav": -0.24,
	"ui_click.wav": 0.12,
	"ui_error.wav": -4.12,
	"armor_ricochet.wav": -8.43,
	"boss_bomb_countdown.wav": 28.13,
	# Its high crest factor needs extra gain; the Master limiter catches peaks.
	"boss_bomb_explode.wav": 5.04,
	"enemy_explode.wav": -1.12,
	"heavy_turret_charge.wav": -10.5,
	"heavy_turret_fire.wav": -3.04,
	"item_pickup.wav": 4.0,
	"laser_gate_hover.wav": -6.08,
	"light_turret_fire.wav": -10.48,
	"piercer_fire.wav": -7.25,
	"piercer_reload.wav": -10.59,
	"rifle_fire.wav": 1.26,
	"shield_open.wav": -16.41,
	"weapon_switch.wav": -0.45,
	"rifle_reload.mp3": -0.05,
	"chase_mode.mp3": -10.98,
	"untitled.mp3": -12.73,
}

static func gain(path: String) -> float:
	return float(GAINS_DB.get(path.get_file(), -10.0))
