extends Menu

@export var team_cont: Container

var tc_arr = []
var rnd = -Main.GameRound.Debug
var game: Game
var freeplay: bool

func _ready():
	SignalBus.to_game_select.connect(render)
	var new_team_cont = team_cont.duplicate()
	team_cont.add_sibling(new_team_cont)
	tc_arr = [team_cont, new_team_cont]

func render(g: Game):
	game = g
	freeplay = (game == null)
	var t1: Team = null
	var t2: Team = null
	if (!freeplay):
		t1 = g.teams[0]
		t2 = g.teams[1]
	set_team(0, t1)
	set_team(1, t2)

func set_team(i: int, t: Team):
	tc_arr[i].render(t, freeplay)

func _back():
	Main.emit_scene()

func _play():
	if (!game): 
		set_game()
		tc_arr[0].team.cpu = tc_arr[0].is_cpu()
		tc_arr[1].team.cpu = tc_arr[1].is_cpu()

	Main.emit_scene(Main.Scene.GameMenu)
	Stream.cache(func(): SignalBus.play_game.emit(game, false))

func set_game():
	var data = {
		"team1id" = tc_arr[0].team.id,
		"team2id" = tc_arr[1].team.id,
		"round" = Main.GameRound.Freeplay,
		"connect" = true,
		"level name" = level.get_name(),
	}
	game = level.add_game(data, true) #should be archive eventually
