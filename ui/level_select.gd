extends VBoxContainer

const F := preload("res://ui/ui_factory.gd")
const CAMPAIGNS := preload("res://campaign_data.gd")
var game: Node
var back: Callable
var first_button: Button

func _ready() -> void:
	custom_minimum_size.x = 560
	add_theme_constant_override("separation", 12)
	F.label(self, "SELECT MISSION", "LargeLabel")
	F.label(self, "3 MISSIONS / ENDLESS SURVIVAL", "AmberLabel")
	for index in range(CAMPAIGNS.LEVELS.size()):
		var info: Dictionary = CAMPAIGNS.LEVELS[index]
		var button := F.button(self, "LEVEL %02d // %s" % [index + 1, info.name], func(): game.start_level(index))
		if index == 0: first_button = button
		F.label(self, info.description, "MutedLabel")
	add_child(HSeparator.new())
	F.button(self, "ENDLESS MODE // 无尽模式", func(): game.start_endless())
	F.label(self, "波次逐步加压，每五波 Boss；一条命挑战，死亡从首波重开。", "MutedLabel")
	F.button(self, "BACK", back, true)
