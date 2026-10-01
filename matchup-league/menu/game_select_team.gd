extends VBoxContainer

@export var team_option: OptionButton
@export var team_view: Control
@export var random_button: Button
@export var cpu_check: CheckButton

var team: Team
var freeplay: bool

func _ready():
	pass

func render(t: Team = null, fp = false):
	freeplay = fp
	if (!t):
		t = Main.Levels.  .random_team(Filter.exclude_self(team))
	team = t
	if (freeplay):
		team_option.clear()
		var select = 0
		for t_name in team.level.get_t_names():
			team_option.add_item(t_name)
			if (t_name == team.de_name):
				select = team_option.item_count - 1
		team_option.selected = select
	else:
		cpu_check.button_pressed = team.is_cpu()
		
	team_option.visible = freeplay
	team_option.visible = freeplay
	random_button.visible = freeplay
	team_view.render(team)

func _select(idx: int):
	var new_name = team_option.get_item_text(idx)
	var new_team = team.level.find_team(new_name)
	render(new_team, freeplay)

func _random():
	render(null, freeplay)

func is_cpu() -> bool:
	return cpu_check.button_pressed
