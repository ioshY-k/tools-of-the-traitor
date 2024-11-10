extends Node

var highscore_list = Array()
const hs_entry_scene = preload("res://Scenes/hs_entry.tscn")

func _ready() -> void:
	#add_highscore(999,"00:00:00",56,true)
	#add_highscore(79,"00:57:44",68,true)
	#add_highscore(979,"00:00:00",864,true)
	#add_highscore(1,"57:00:42",876,true)
	#add_highscore(99,"22:00:22",30450,true)
	#add_highscore(59,"44:33:00",86,true)
	#add_highscore(4,"00:00:22",8,true)
	#add_highscore(99,"00:00:44",46,true)
	#add_highscore(9,"00:44:00",46,true)
	#add_highscore(15656,"33:00:00",48,false)
	#add_highscore(1,"00:44:00",487,false)
	#add_highscore(155,"00:66:33",787,false)
	#add_highscore(1000,"00:55:55",777,false)
	#add_highscore(100,"00:55:00",8,false)
	#add_highscore(0,"00:00:00",87,false)
	#add_highscore(1000,"00:35:00",7687,false)
	#add_highscore(160,"00:42:43",52,false)
	#add_highscore(400,"00:42:00",76,false)
	#add_highscore(8000,"22:00:00",77,false)
	#add_highscore(366,"00:00:00",898,false)
	#add_highscore(18,"00:00:00",5,false)
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
	print(a.time)
	print(b.time)
	var a_time_as_number = a.time[0] + a.time[1] + a.time[3] + a.time[4] + a.time[6] + a.time[7]
	var b_time_as_number = b.time[0] + b.time[1] + b.time[3] + b.time[4] + b.time[6] + b.time[7]
	print(a_time_as_number)
	print(b_time_as_number)
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
