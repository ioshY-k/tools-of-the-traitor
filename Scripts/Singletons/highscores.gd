extends Node

var highscore_list = Array()
const hs_entry_scene = preload("res://Scenes/hs_entry.tscn")

func _ready() -> void:
	var hs_file = "user://highscores.dat"
	
	var file_r = FileAccess.open(hs_file, FileAccess.READ)
	while file_r.get_position() < file_r.get_length():
		var score = file_r.get_line()
		var time = file_r.get_line()
		var tools = file_r.get_line()
		var cursed = file_r.get_line()
		add_highscore(int(score),time,int(tools),cursed == "true")
		
	file_r.close()
	pass

func add_highscore(score, time, tools, cursed):
	var highscore: Highscore = Highscore.new(score, time, tools, cursed)
	highscore_list.append(highscore)

func convert_to_tableentry(hs: Highscore) -> HBoxContainer:
	var entry = hs_entry_scene.instantiate()
	entry.get_node("score_label").text = str(hs.score)
	entry.get_node("time_label").text = hs.time
	entry.get_node("tools_label").text = str(hs.tools)
	return entry

func sort_by_time():
	highscore_list.sort_custom(compare_time)

func compare_time(a,b):
	print_debug(a.time)
	print(b.time)
	var a_time_as_number = a.time[0] + a.time[1] + a.time[3] + a.time[4] + a.time[6] + a.time[7]
	var b_time_as_number = b.time[0] + b.time[1] + b.time[3] + b.time[4] + b.time[6] + b.time[7]
	print_debug(a_time_as_number)
	print_debug(b_time_as_number)
	return int(a_time_as_number) < int(b_time_as_number)

func sort_by_score():
	highscore_list.sort_custom(compare_score)

func compare_score(a,b):
	return a.score > b.score

func sort_by_tools():
	highscore_list.sort_custom(compare_tools)

func compare_tools(a,b):
	return a.tools < b.tools


class Highscore extends Node:

	var score: int
	var time: String
	var tools: int
	var cursed: bool

	func _init(sc, ti, to, cu) -> void:
		score = sc
		time = ti
		tools = to
		cursed = cu
