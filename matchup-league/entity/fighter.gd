class_name Fighter extends DataEntity

#match vars
var types
var base
var str_type
var str_val
var wk_type
var wk_val ##stored as positive

#team vars
var team_ID = -1
var team ## only edit using set_team
var contract
var retirement

var starting_season
var potential

#record vars
var matches_won = 0
var matches_lost = 0

func _init(data = {}):
	super(data, "F")
	set_data(data, true)
	
func connect_objs():
	if (team_ID >= 0):
		set_team(level.get_team(team_ID))
		#set_series(team.series) #prep only

func set_data(data: Dictionary, init = false) -> Fighter:
	if (!init): super(data)
	if (data == {}): return self
	types = types_arr(data.get("types", types))
	base = set_base(data.get("base", base))
	str_type = data.get("str_type", str_type)
	str_val = set_mod(data.get("str_val", str_val))
	wk_type = data.get("wk_type", wk_type)
	wk_val = set_mod(data.get("wk_val", wk_val))
	starting_season = data.get("start season", season)
	team_ID = data.get("team ID", team_ID)
	matches_won = data.get("wins", matches_won)
	matches_lost = data.get("losses", matches_lost)
	if (!init): set_team(level.get_team(team_ID))
	return self

func set_team(t: Team):
	if (t == team): 
		return
	team = t
	team_ID = team.id
	team.add_fighter(self)

## returns an array of types from a character string. ex: ABC -> [A, B, C]
func types_arr(type_str = types) -> Array:
	if (!type_str is String): return []
	var type_arr = []
	if (type_str.length() > Main.MAX_TYPES):
		type_str.left(Main.MAX_TYPES)
	for i in type_str.length():
		type_arr.append(type_str[i])
	return type_arr

## returns each type's character as a string. ex: ABC
func types_str(type_arr = types) -> String:
	if (!type_arr is Array): return ""
	var type_str = ""
	for type in type_arr:
		type_str += type
	return type_str

## returns a string of icons: (A)(B)(C)
func types_icon(type_arr = types) -> String:
	if (!type_arr is Array): return ""
	var type_str = ""
	for type in type_arr:
		type_str += "(%s) " % type
	return type_str


func set_base(new: int) -> int:
	if (new < Main.MIN_BASE):
		new = Main.MIN_BASE
	elif (new > Main.MAX_BASE):
		new = Main.MAX_BASE
	return new
		
func set_mod(new: int) -> int:
	if (new < Main.MIN_MOD):
		new = Main.MIN_MOD
	elif (new > Main.MAX_MOD):
		new = Main.MAX_MOD
	return new

func get_base() -> int:
	return base

func get_strength_val() -> int:
	return str_val

func get_weak_val(positive = true) -> int:
	return wk_val if (positive) else -wk_val

## compiles fighter rating from stats
func get_rating() -> float:
	return (base * Rating.BASE_WT) + (str_val * Rating.STR_WT) - (wk_val * Rating.WK_WT)

func win_pct() -> float:
	if (matches_played() == 0):
		return NodeUtil.float_zero()
	return float(matches_won) / matches_played()
	
func get_wins() -> int:
	return matches_won

func get_losses() -> int:
	return matches_lost

func add_win():
	matches_won += 1

func add_loss():
	matches_lost += 1

func matches_played() -> int:
	return matches_won + matches_lost

func no_contests() -> int:
	return Main.get_current_round() - matches_played()

#format functions

## set param true for strength, false for weakness
func str_mod(use_strength = true) -> String:
	var type = ""
	var pm = ""
	var val = 0
	if (use_strength):
		type = str_type
		val = str_val
		pm = "+"
	else:
		type = wk_type
		val = wk_val
		pm = "-"
	
	return "(%s) %s%d" % [type, pm, val]

## string with matches won and matches played: "W/P"
func str_matches() -> String:
	return "%d/%d" % [matches_won, matches_played()]

func str_name_matches() -> String:
	return de_name + " " + str_matches()

func format_save() -> Dictionary:
	var data = {
		"id": id,
		"name": de_name,
		"season": season,
		"types": types_str(),
		"base": base,
		"str_type": str_type,
		"str_val": str_val,
		"wk_type": wk_type,
		"wk_val": wk_val,
		"start season": starting_season,
		"team ID": team_ID,
		"wins": matches_won,
		"losses": matches_lost,
	}
	return data
