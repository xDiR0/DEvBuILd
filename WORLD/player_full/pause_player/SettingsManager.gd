extends Node

# Настройки по умолчанию
var settings = {
	"mouse_sensitivity": 0.002,
	"master_volume": 1.0,
	"music_volume": 0.8,
	"sfx_volume": 0.8,
	"fullscreen": false
}

const SETTINGS_PATH = "user://settings.cfg"

func _ready():
	load_settings()

func load_settings():
	var config = ConfigFile.new()
	if config.load(SETTINGS_PATH) == OK:
		for key in settings.keys():
			if config.has_section_key("settings", key):
				settings[key] = config.get_value("settings", key)
	
	apply_settings()

func save_settings():
	var config = ConfigFile.new()
	for key in settings.keys():
		config.set_value("settings", key, settings[key])
	config.save(SETTINGS_PATH)

func apply_settings():
	# Применяем громкость
	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index("Master"),
		linear_to_db(settings["master_volume"])
	)
	
	# Применяем настройки экрана
	if settings["fullscreen"]:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func set_setting(key, value):
	if settings.has(key):
		settings[key] = value
		apply_settings()
		save_settings()

func get_setting(key):
	return settings.get(key, null)
