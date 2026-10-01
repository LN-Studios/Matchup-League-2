class_name DataEntity extends Node

var id: int = -1
var initial = "DE"
var id_str: String
var de_name: String
var season: int
var level: Level
var series: String

func _init(data = {}, itl = "DE"):
	SignalBus.done_loading.connect(connect_objs)
	initial = itl
	if (data == {}): return
	set_data(data)

func set_data(data: Dictionary, _on_init = false) -> DataEntity:
	if (data == {}): return self
	id = int(data.get("id", id))
	id_str = "%s%d" % [initial, id]
	de_name = data.get("name", de_name)
	if (de_name == Main.Keyname.Empty): de_name = id_str
	season = data.get("season", season)
	set_level(data.get("level name", "forgot to store level name, dingdong"))
	set_series(data.get("series", series))
	return self

func get_basic_data() -> Dictionary:
	var data = {
		"level name" = get_level_name(),
		"season" = Main.season,
	}
	return data

func get_level() -> Level:
	return level

func get_level_name() -> String: 
	return level.name

func set_level(level_name: String):
	level = Main.Levels[level_name]

func set_series(sr: String = Main.DEFAULT_SERIES):
	if (!sr && Main.DEFAULT_SERIES != null):
		set_series()
	else:
		series = sr

## called after all entities done loading to set references to other entities
func connect_objs():
	pass

func has_id() -> bool:
	return id >= 0

func has_name() -> bool:
	return !de_name.is_empty()

## compiles stat used for rating
func get_rating() -> float:
	var ratings = rating_breakdown().values()
	var sum = ArrayUtil.sum(ratings)
	return sum

## should be overridden in subclasses that can have a rating
func rating_breakdown() -> Dictionary:
	Err.print_warn("entity %s can't have a rating breakdown" % id_str, Err.Warn.NoAction)
	return {}

func rating_breakdown_scaled() -> Dictionary:
	var breakdown = rating_breakdown()
	var prop = get_rating_proportion()
	var break_scaled = ArrayUtil.map_dict(breakdown, (func(categ: String): return breakdown[categ] * prop))
	return break_scaled

func get_rating_scaled() -> int:
	Err.print_warn("entity %s can't have a rating scale" % id_str, Err.Warn.NoAction)
	return Main.GameRound.Debug

func get_rating_proportion() -> float:
	return get_rating_scaled() / get_rating()

func win_pct() -> float:
	Err.print_warn("Unsupported function: win_pct()", Err.Warn.NoAction)
	return NodeUtil.float_zero()

func get_library() -> EntityLibrary:
	Err.print_warn("Unsupported function: get_library()", Err.Warn.NoAction)
	return null

func name() -> String:
	return de_name

func is_archive() -> bool:
	return level.is_archive()

func format_save() -> Dictionary:
	var data = {
		"id": id,
		"name": de_name,
	}
	if (level.is_archive()) :
		data.merge({"season" = season}, true)
	return data
