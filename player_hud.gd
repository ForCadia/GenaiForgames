class_name PlayerHUD
extends CanvasLayer

@export var reload_fill_style: StyleBoxFlat

@onready var status_panel: PanelContainer = $Root/StatusPanel
@onready var health_label: Label = $Root/StatusPanel/Margin/VBox/HealthRow/HealthLabel
@onready var health_bar: ProgressBar = $Root/StatusPanel/Margin/VBox/HealthRow/HealthBar
@onready var weapon_label: Label = $Root/StatusPanel/Margin/VBox/WeaponLabel
@onready var penetration_label: Label = $Root/StatusPanel/Margin/VBox/AmmoRow/PenetrationLabel
@onready var ammo_bar: ProgressBar = $Root/StatusPanel/Margin/VBox/AmmoRow/AmmoBar

var normal_fill_style: StyleBoxFlat

func _ready() -> void:
	normal_fill_style = ammo_bar.get_theme_stylebox("fill").duplicate()

func refresh(health: int, max_health: int, weapon_name: String, penetration: int,
		current_ammo: int, capacity: int, reload_remaining: float, reload_duration: float) -> void:
	health_label.text = "HP%d/%d" % [health, max_health]
	health_bar.max_value = maxi(max_health, 1)
	health_bar.value = clampi(health, 0, max_health)
	weapon_label.text = weapon_name
	penetration_label.text = "PEN %d" % penetration
	if reload_remaining > 0.0:
		ammo_bar.add_theme_stylebox_override("fill", reload_fill_style)
		ammo_bar.value = clampf(1.0 - reload_remaining / maxf(reload_duration, 0.001), 0.0, 1.0)
	else:
		ammo_bar.add_theme_stylebox_override("fill", normal_fill_style)
		ammo_bar.value = clampf(float(current_ammo) / float(maxi(capacity, 1)), 0.0, 1.0)

func follow_hitbox(hitbox: Rect2) -> void:
	# Center the entire label + bars group, not only the colored bar.
	status_panel.reset_size()
	status_panel.position = Vector2(
		roundf(hitbox.get_center().x - status_panel.size.x * 0.5),
		roundf(hitbox.position.y - status_panel.size.y - 24.0)
	)
