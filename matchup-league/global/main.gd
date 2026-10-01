extends Node

var season: int
var main_node: Control
var game_seed: Variant
var current_career: Career
var backup = false
const MAX_TYPES = 4
const MIN_BASE = 499
const MAX_BASE = 9999
const MIN_MOD = 9
const MAX_MOD = 299
const CANON_SEED = 1
const SCENE_PATH = "res://scene/%s.tscn"
## max number of scenes that will be stored in scene history
const MAX_SCENES = 8

const DEFAULT_SERIES = "Original"

## put in league class when i make it
const season_length = 7

var Version = {
	Build = 2,
	Version = 1,
	Release = 0,
	Commit = 5
}

func str_version(drop_commit = false) -> String: 
	var nums = Version.values()
	if (nums[3] == null): drop_commit = true
	var statement = "prototype %d.%d.%d" 
	if (drop_commit):
		nums.remove_at(3)
	else:
		statement += ".%d"
	return statement % nums

var Edition = {
	Dev = "development",
	Test = "playtest",
	Prod = "Production",
	Exp = "experimental",
}

var edition = Edition.Dev

var version_edition = str_version() + " " + edition

## stores previously visited scenes, behaves like a stack
var scene_history = []
var Scene = {
	TeamView = "team_view",
	Editor = "editor",
	GameSelect = "game_select",
	GameMenu = "game_menu",
	LoadCareer = "load_career",
	CareerSelect = "career_select",
	SeasonMenu = "season_menu",
	TeamMenu = "team_menu",
	MainMenu = "main_menu",
	SettingsMenu = "settings_menu",
}

var Types = {
	Melee = "M",
	Ranged = "R", 
	Explosive = "E", 
	Fire = "F", 
	Water = "W", 
	Electric = "L",
	Aerial = "A",
	Magic = "G",
	Mechanical = "C",
	Ice = "I",
	Star = "S",
	Evil = "V",
}

## types that are out of circulation
var LegacyTypes = {
	Day = "Y",
	Night = "T",
	Series = "Z",
	Default = "X"
}

## possible future types
var BetaTypes = {
	Defensive = "D",
	Natural = "N",
}

var GameRound = {
	Debug = -99,
	Tournament = [0, 0],
	Freeplay = 0
}

var Entity = {
	Fighter = "fighter",
	Team = "team",
	Game = "game",
	Player = "player",
	Level = "level",
	#TourneyGame = "tourney game",
	League = "league",
	Tournament = "tournament",
	Tourney = Tournament,
}

var Levels = {
	#Prep = null,
	#"College": Level.new("College", 5),
	#Pro = null,
	#Archive = null
}

## names reserved for program functions
var Keyname = {
	Remove = "[Remove]",
	Bye = "[Bye]",
	ByePlain = "Bye",
	Custom = "[Custom]",
	Spectate = "[Spectator]",
	Empty = ""
}

## generic enum
enum {
	ZERO = 0,
	DEBUG = 99,
	HUNDRED = 100,
	THOUSAND = 1_000,
	TEN_THOUSAND = 10_000,
	HUNDRED_THOUSAND = 100_000,
	MILLION = 1_000_000,
	BILLION = 1_000_000_000,

	DEFAULT_SEED = 5862495, #32-bit hash of LN
}

var rep: Reproducible

func _ready():
	SignalBus.set_scene.connect(set_scene)
	season = 11
	Levels.Prep = Level.new("Prep", 3, 4)
	Levels.Pro = Level.new("Pro", 8, 10)
	Levels.Archive = Archive.new()
	rep = Reproducible.new()
	Stream.queue(load_state)

func _process(_delta: float):
	pass
	#report lag
	#if (delta > 0.0167):
	#	if (delta < 0.0333): pass #Err.print(". %.3f" % delta) # <60 fps
	#	elif (delta < 0.1): Err.print("* %.3f" %delta) # <30 fps
	#	else: Err.print("! %.3f" %delta) # <10 fps

func get_level(levelName: String): return Levels[levelName]
	
func get_season() -> int: return season

func blank_entity(ent_name: String) -> DataEntity:
	match ent_name:
		Entity.Fighter:
			return Fighter.new()
		Entity.Team:
			return Team.new()
		Entity.Game:
			return Game.new()
		Entity.Player:
			return Player.new()
		Entity.Tournament:
			return Tournament.new()
		_:
			Err.alert_warn("Main.blank_entity: %s does not match any entity name" % ent_name, Err.Warn.Invalid)
			return DataEntity.new()
	
func set_seed(new_seed = DEFAULT_SEED, new_state = null):
	var old_rep = rep
	game_seed = new_seed
	rep = Reproducible.new(game_seed, new_state)
	if (old_rep): old_rep.free()
	main_node.seed_label.text = "Seed: %d" % game_seed
	Err.print("^ new seed: " + str(game_seed))

## returns an `int` in the range 0 <= i < limit
func random_int(limit = -1) -> int:
	if (!rep): return randi()
	var next = rep.get_next()
	lottery(next)
	if (limit < 0): 
		return next
	else: 
		return next % limit

func pick_random(arr: Array) -> Variant:
	var idx = random_int(arr.size())
	return arr[idx]

func get_current_round():
	if (!current_career): return 0
	return current_career.current_round

## converts hex color to `Color`
func format_color(hex: int) -> Color:
	return Color.hex(hex)

## converts `Color` to rgba32 hex
func format_color_hex(col: Color) -> int:
	return col.to_rgba32()

# scene functions

## sets scene to `sc` scene. if `sc` is empty, goes back a scene
func set_scene(sc: String):
	if (sc == scene_history.back()): return
	if (sc):
		scene_history.append(sc)
		var new_scene = load(SCENE_PATH % sc)
		main_node.set_scene(new_scene.instantiate(), sc)
		if (scene_history.size() > MAX_SCENES): scene_history.pop_front()
	elif(scene_history.size() > 1):
		scene_history.pop_back()
		emit_scene(scene_history.pop_back())
	else:
		Err.print_warn("ran out of scenes to go back to :/", Err.Warn.NoAction)
	
func emit_scene(sc: String = "", condition = (func(): return true)):
	Stream.cache(func(): if (condition.call()): SignalBus.set_scene.emit(sc))

func validate_name(n: String) -> bool:
	return !Keyname.values().has(n)

## true pauses the game, false unpauses
func pause_game(switch: bool):
	Err.print("^ paused: " + str(switch))
	get_tree().paused = switch

func is_paused() -> bool:
	return get_tree().paused

func int_round(rnd = current_career.current_round) -> int:
	if (!rnd): return -1
	return rnd if !(rnd is Array) else rnd[1]

# save/load functions

## saves current game state. if you have stuff after this call you want done after it saves, queue it in `Stream`
## or it will happen before saving
func save_state(to_backup = false):
	backup = to_backup
	if (backup): Err.print("/ saving to backup")
	main_node.prompt_game_save(FileUtil.save_dir_exists(true))

## called from `main_node`
func save_callable():
	Err.print("^ saving to %s" % FileUtil.save_path)
	Setting.save(backup)
	if (current_career):
		current_career.save(backup)
	for level in Levels:
		Levels[level].save_data(backup)
	main_node.save_game_end()
	SignalBus.done_saving.emit()
	Err.print("^ saved")
	backup = false

func load_state(data: Dictionary = {}):
	var file_name = data.get("dir_name", "")
	Err.print("^ loading %s" % file_name)

	# load career data
	if (data == {}):
		current_career = null
	else:
		if (data.get("level")):
			data["level name"] = data["level"]
		var lvl = data["level name"]
		current_career = Career.create(lvl, data.name, data.team_id)
		if (data.round is int): 
			current_career.current_round = data.round - 1
			current_career.begin_round()
		else:
			current_career.current_round = data.round
	
	FileUtil.set_save_path(file_name) # after career is set
	Setting.load()
	for level in Levels.values():
		level.load_data()
	NodeUtil.set_bg_theme()
	SignalBus.done_loading.emit()
	for lvl in Levels.values():
		lvl.set_avg_rating()
	Err.print("^ loaded")

func system_info() -> Dictionary:
	var info = {
		timestamp = Time.get_datetime_string_from_system(false, true),
		version = str_version(),
		edition = edition,
	}
	return info
	
## idk why i did this
func lottery(ticket: int):
	
	if (ticket == game_seed): Err.alert_success("JACKPOT!!!", 777)
	if (ticket % MILLION == 0 && ticket >= MILLION): 
		Err.print("$ " + str(ticket))
		Err.alert_success("you're one in a million!", 777)
