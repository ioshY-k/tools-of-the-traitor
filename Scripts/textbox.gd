extends MarginContainer

@onready var label: Label = $MarginContainer/Label
@onready var letter_display_timer: Timer = $Letter_display_timer
@onready var continue_marker: TextureRect = $MarginContainer2/ContinueMarker
@onready var talking_sfx: AudioStreamPlayer = $Talking_sfx

var text_blocks = Array()
var letter_index = 0
var letter_time = 0.06
var letter_time_skipping = 0.001

signal finished_textblock()
signal finished_reading()
signal finished_displaying()

var firsttimetest = true

func _ready() -> void:
	talking_sfx.volume_db = PlayerStats.sfx_volume
	

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("accept") or Input.is_action_just_pressed("jump") or Input.is_action_just_pressed("place_simple_tool"):
		finished_reading.emit()

func display_text(text_to_display: Array, xOffset, yOffset, char_pitch):
	if xOffset == null:
		xOffset = 0
	if yOffset == null:
		yOffset = 0
	
	talking_sfx.pitch_scale = char_pitch
	for block in range(0, len(text_to_display)-1, 2):
		custom_minimum_size.x = 0
		set_deferred("size", 185)
		continue_marker.visible = false
		
		#checking how big the box must be
		text_blocks = text_to_display
		label.text = text_to_display[block] + "\n" + text_to_display[block+1]
		await resized
		
		# resizing and positioning box
		custom_minimum_size.x = size.x
		global_position.x = get_parent().position.x - (size.x/2) + xOffset
		global_position.y = get_parent().position.y + yOffset
		z_index = 100
		
		label.text = ""
		display_letters(text_to_display[block], text_to_display[block+1])
		await finished_textblock
		continue_marker.visible = true
		await finished_reading
	
	finished_displaying.emit()
	
	

func display_letters(block1: String, block2: String):
	
	
	var letter_number = round(120/min(Engine.get_frames_per_second(),120))
	
	for current_block in [block1, block2]:
		letter_index = 0
		while letter_index < current_block.length() - letter_number:
			for current_letter_number in range(letter_number):
				print(str(letter_index) + ": " + str(current_block[current_letter_number + letter_index]) )
				label.text += current_block[current_letter_number + letter_index]
			
			#if Input.is_action_pressed("accept") or Input.is_action_pressed("jump") or Input.is_action_just_pressed("place_simple_tool"):
				#letter_display_timer.start(letter_time_skipping)
			#else:
				#letter_display_timer.start(letter_time)
			if not talking_sfx.playing:
				talking_sfx.play()
				
			await get_tree().process_frame
			letter_index += letter_number
		for last_letters in range(current_block.length() - letter_index):
			label.text += current_block[letter_index + last_letters]
		label.text += "\n"
		
	
	await get_tree().process_frame
	finished_textblock.emit()
