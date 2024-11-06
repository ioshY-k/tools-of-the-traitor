extends Node

var textbox : PackedScene = preload("res://Scenes/textbox.tscn")
signal dialog_finished

var dialog_participants = Array()

#existing parameters: "offset" (adjusting textbox offset on xAxis)
var dialog_sequences : Dictionary = {
				"intro_names" : 			["DEMObot","Player","DEMObot","Player","DEMObot"],
				"intro_param" : 			{"yOffset" : 150},
				"intro_lines" :			[
											["OHOO.. WELCOME!!! To my very own practice chamber,",
											"Version 25.0.2!",
											"I am your Digital Entity for Mastering Onboardings.",
											"Or for short…"],
											["DEMO Bot, cut the intro!",
											"",
											"I know where I am, I literally build this place.",
											"...like, 25 times.",
											"You could say I even built YOU.",
											"If you want to get technical."],
											["I would LOVE to get technical!!!",
											""],
											["Please let me quickly do a last few practice rounds.",
											"I feel like I might have to leave this place soon."],
											["OHOO! Very sure! You know the drill by now:",
											"Collect the Orbs, Reach the Goal.",
											"And beat your Highscore while you're at it!",
											"Jump is A and Sprint is X.",
											"You can either hold X to Sprint, or toggle your Sprint by tapping X.",
											"Which one is your Preference?"]
										],


				"chose_hold_names" : 	["Player","DEMObot"],
				"chose_hold_param" : 	{"yOffset" : 150},
				"chose_hold_lines" : 	[
											["What Kind of question is this?",
											"I NEVER Toggle my X Buttons to sprint...",
											"Can we just start now please?",
											""],
											["Fine fine, good luck then!",
											""]
										],


				"chose_toggle_names" : 	["Player","DEMObot"],
				"chose_toggle_param" : 	{"yOffset" : 150},
				"chose_toggle_lines" : 	[
											["What Kind of question is this?",
											"I NEVER Hold my X Buttons to sprint...",
											"Can we just start now please?",
											""],
											["Fine fine, good luck then!",
											""]
										],


				"floor_tool_names" : 	["Sign_floor_tool"],
				"floor_tool_param" : 	{"yOffset" : 150},
				"floor_tool_lines": 		[
											["Hold L/ZL to place the Yellow Tool.",
											"Use the left Stick to choose a position",
											"You can only place this Tool while standing still.",
											"",
											"Press Y to call the Tool back when placed.",
											""]
										],


				"cam_names" :			["Sign_cam"],
				"cam_param" : 			{"yOffset" : 150},
				"cam_lines" :			[
											["The right stick controls your camera",
											""],
												
										],


				"block_tool_names" :		["Sign_block_tool"],
				"block_tool_param" : 	{"yOffset" : 150},
				"block_tool_lines" :		[
											["Hold L/ZL to place the Red Tool.",
											"Use the left Stick to choose a position",
											"You can only place this Tool when airborne.",
											"",
											"(The default position is always downwards,",
											"so tapping L/ZL will always position this tool beneath you)"],
										],


				"wall_tool_names" :		["Sign_wall_tool"],
				"wall_tool_param" : 		{"yOffset" : 150},
				"wall_tool_lines" :		[
											["Hold RT + Left/Right to place the Green Tool.",
											"This Tool can only be placed to your left or right.",
											"It can be placed while airborne and while grounded.",
											"It can not be used as standable ground."],
										],


				"spring_tool_names" :		["Sign_spring_tool"],
				"spring_tool_param" : 		{"yOffset" : 150},
				"spring_tool_lines" :		[
											["Hold RT + Down to place the Blue Tool.",
											"",
											"While grounded, it will always be placed in front of you.",
											"While airborn, it will always be placed right below you.",
											"To get launched from the tool",
											"hop onto it.",
											"Holding Jump while launching",
											"will launch you higher up"],
										],


				"walljump_names" :		["DEMObot2","Player","DEMObot2","Player","DEMObot2","Player"],
				"walljump_param" : 		{"xOffset" : -80, "yOffset" : 150},
				"walljump_lines" : 		[
											["Hey by the way:",
											"To control your camera, just move the..."],
											["You know I placed these signs so that I",
											"don't always get interrupted while I practice!"],
											["OHOO really?",
											"because...",
											"I often catch you reading them",
											"when you should be training you know?",
											"What do they even say",
											"that is so captivating?"],
											["Are you done?",
											""],
											["Almost: Do you remember you can jump up walls?",
											"Just hug a wall an press jump again!"],
											["...I actually DID forget about that.",
											"Thanks!"]
										],


					"bullet_names" :		["DEMObot3","Player","DEMObot3","Player","DEMObot3","Player","DEMObot3","Player","DEMObot3"],
					"bullet_param" : 	{"yOffset" : -350},
					"bullet_lines" : 	[
											["Here we go",
											"I waited for this moment."],
											["What is it this time?",
											""],
											["Well you can't know what I am",
											"about to tell you this time...",
											"because I invented it myself!",
											"While you were gone! OHHOOO!"],
											["I am glad you want to help, but this is not a game.",
											"Once I leave, there is no coming back and I-"],
											["Behold: the WORLD DECELERATOR!",
											""],
											["...The what?",
											""],
											["You said when you are airborne and need to manage all these tools",
											"everything is happening so fast.",
											"So I built a device that slows it down",
											""],
											["\"it\" being... everything?",
											"",
											"How would that even...",
											"alright, turn it on for me.",
											"I can always turn it off",
											"if it makes me uncomfortable, right?"],
											["I added the option to the menu.",
											"Now don't thank me, let's see it in action!",
											"Jump down into that pit while holding down LT!",
											"HOO!"],
										]
					}

func run_dialog(dialog_name):
	if not dialog_sequences.has( dialog_name + "_names" ):
		push_error("Custom Error: The Dictionary Key looked for doesn't match with the passed dialog_name \"" + dialog_name + "\"")
		get_tree().quit()
	if not dialog_sequences.has( dialog_name + "_lines" ):
		push_error("Custom Error: The Dictionary Key looked for doesn't match with the passed dialog_name \"" + dialog_name + "\"")
		get_tree().quit()
	for index in range(len(dialog_sequences[dialog_name + "_lines"])):
		if len(dialog_sequences[dialog_name + "_lines"][index]) % 2 != 0:
			push_error("Custom Error: The number of lines in this Dialog entry is odd, but it must be even.")
			get_tree().quit()
			
		
	# Save every Participant as its Node
	dialog_participants = []
	for participant_string in dialog_sequences[dialog_name + "_names"]:
		var already_found = false
		
		# Prevent using the find_child method for nodes that were already searched for
		for node in dialog_participants:
			if node.name == participant_string:
				dialog_participants.append(node)
				already_found = true
				break
		
		# Find child method used only for searching the Node once
		if not already_found:
			dialog_participants.append(get_parent().find_child(participant_string, true, false))
	
	# Manage the dialog by instantiating the corresponding textboxes
	for index in range(len(dialog_participants)):
		print(dialog_sequences[dialog_name + "_param"].get("offset"))
		var textbox_node = textbox.instantiate()
		dialog_participants[index].add_child(textbox_node)
		textbox_node.display_text(	dialog_sequences[dialog_name + "_lines"][index],
									dialog_sequences[dialog_name + "_param"].get("xOffset"),
									dialog_sequences[dialog_name + "_param"].get("yOffset"))
		await textbox_node.finished_displaying
		textbox_node.queue_free()
	
	dialog_finished.emit()
	
