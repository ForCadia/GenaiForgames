extends SceneTree

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	assert("--lab-test" in OS.get_cmdline_user_args())
	var game = load("res://main.tscn").instantiate()
	root.add_child(game)
	game.menu_demo.set_active(false)
	game.set_process(false)
	game.start_screen.name_input.text = "LanguageTest"
	var wallet: int = game.progression.coins
	game.start_screen.show_settings(true)
	game.settings.set_option("language","en")
	await process_frame
	await process_frame
	assert(TranslationServer.translate("设置") == "SETTINGS")
	assert(TranslationServer.translate("追踪子弹") == "Homing rounds")
	assert(preload("res://endless_talents.gd").description("homing",0) == "Every 5th bullet homes")
	var selector: OptionButton = game.start_screen.settings_view.find_child("LanguageSelect",true,false)
	assert(selector.selected == 1)
	assert(game.start_screen.name_input.text == "LanguageTest")
	assert(game.progression.coins == wallet)
	game.settings.set_option("language","invalid")
	assert(game.settings.options.language == "en")
	game.settings.set_option("language","zh_CN")
	await process_frame
	await process_frame
	assert(TranslationServer.translate("SETTINGS") == "设置")
	assert(preload("res://endless_talents.gd").description("homing",3) == "每2发子弹有1发追踪")
	game.settings.set_option("language","en")
	game.settings.restore_defaults()
	assert(game.settings.options.language == "zh_CN")
	assert(TranslationServer.translate("BACK") == "返回")
	print("LANGUAGE: EN/ZH live refresh, dynamic talent text, invalid value, restore defaults, profile preservation PASS")
	quit()
