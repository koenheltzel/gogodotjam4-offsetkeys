class_name Game
extends Node3D

var letters: Array[LetterData]
var spelled_letters: Array = []
var letter_colors: Array = [Color.CORNFLOWER_BLUE] #Keycap.COLOR_ORANGE, Keycap.COLOR_LIGHT_ORANGE, Keycap.COLOR_YELLOW, Keycap.COLOR_BLUE
var letter_color_index: int = 0
var locked_letters_tweening: int = 0

const KeycapScene = preload("res://game/keycap/keycap.tscn")
const DroppingKeycapScene = preload("res://game/dropping_keycap.tscn")
var active_dropping_keycaps: Array[DroppingKeycap] = []

@onready var message_label: Label = %MessageLabel
@onready var audio_stream_player = %AudioStreamPlayer
@onready var camera_animation_player: AnimationPlayer = %CameraAnimationPlayer

var intro_sound = preload("res://game/intro.ogg")

func _init():
	Nodes.game = self


func _ready():
	if not Nodes.keyboard.is_ready:
		await Nodes.keyboard_ready
	self.hide_message(false)
	self.start_level(1)


func show_message(message):
	if self.message_label.text != "":
		var tween: Tween = self.hide_message()
		await tween.finished

	self.message_label.text = message
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(self.message_label, "modulate:a", 1.0, 0.5)


func hide_message(fade=true):
	if fade:
		var tween: Tween = get_tree().create_tween()
		tween.tween_property(self.message_label, "modulate:a", 0, 0.5)
		return tween
	else:
		self.message_label.modulate.a = 0


func level1_intro():
	self.camera_animation_player.play("look_down")
	self.camera_animation_player.seek(0, true)
	self.camera_animation_player.pause()
	self.audio_stream_player.stream = self.intro_sound
	self.audio_stream_player.play()

	self.show_message("It was his first game jam..")
	await get_tree().create_timer(2).timeout
	self.hide_message()
	await get_tree().create_timer(0.5).timeout

	self.show_message("Less is more.. the theme echoed in his head..")
	await get_tree().create_timer(2.5).timeout
	self.hide_message()
	await get_tree().create_timer(0.5).timeout

	self.show_message("Mind completely blank, he stared down at his keyboard..")
	await get_tree().create_timer(2).timeout

	self.camera_animation_player.play()

	await get_tree().create_timer(1).timeout
	self.hide_message()
	await get_tree().create_timer(2).timeout


func start_level(level:int):
	if level == 1:
		await self.level1_intro()

		self.show_message("Press the matching key on your keyboard")

		var slow: float = 0.7
		var normal: float = 1.0

		var gap: int = 10
		self.letters = [
			LetterData.new("L", 1.2 * gap, normal).set_callback(self.hide_message),
			LetterData.new("E", 2.2 * gap, normal),
			LetterData.new("S", 3.2 * gap, normal),
			LetterData.new("S", 4.2 * gap, normal).set_callback(self.show_message, ["Oh oh! A wild offset \"I\" key appears.\nHold down the \"I\" key, press your LEFT arrow key, then release the \"I\"."]),
			null,
			LetterData.new("I", 5.2 * gap, slow).set_fixed_offset(Vector2i(1, 0)).set_callback(self.show_message, ["Same for the \"S\" now, but move it DOWN.\nHold down the \"S\" key, press your DOWN arrow key, then release the \"S\"."]),
			LetterData.new("S", 6.2 * gap, slow).set_fixed_offset(Vector2i(0, -1)).set_callback(self.hide_message),
			null,
			LetterData.new("M", 7.2 * gap, slow, 1),
			LetterData.new("O", 8.2 * gap, normal, 2),
			LetterData.new("R", 9.2 * gap, normal, 2),
			LetterData.new("E", 10.2 * gap, normal, 2),
		]
#	elif level == 2:
#		self.letters = "GOGODOTJAM"

	var i: int = 0
	var letter_count: int = 0
	for letter_data in self.letters:
		if letter_data:
			var keycap: Keycap = KeycapScene.instantiate()
			keycap.type = Keycap.Types.SPELLED
			keycap.letter = letter_data.letter
			keycap.position.x = i
			keycap.visible = false
			$SpelledLetters.add_child(keycap)
			self.spelled_letters.append(keycap)

			var position = self.get_random_start_position(letter_data, [])
			if letter_data.fixed_offset:
				position += letter_data.fixed_offset
			var dropping_key = DroppingKeycapScene.instantiate()
			dropping_key.time_scale = letter_data.time_scale
			dropping_key.letter = letter_data.letter
			dropping_key.x = position.x
			dropping_key.y = position.y
			dropping_key.letter_index = i
			dropping_key.letter_color = self.get_next_letter_color()
			dropping_key.letter_locked.connect(self._on_letter_locked)
			dropping_key.letter_destroyed.connect(self._on_letter_destroyed)
			if letter_data.destroyed_callback:
				dropping_key.letter_destroyed.connect(letter_data.destroyed_callback.bindv(letter_data.destroyed_callback_args))

			dropping_key.start_y_position = letter_data.start_y_position
			self.add_child(dropping_key)
			self.active_dropping_keycaps.append(dropping_key)
			letter_count += 1
		else:
			self.spelled_letters.append(null)
		i += 1
	$SpelledLetters.scale = Vector3(0.7, 0.7, 0.7)
	$SpelledLetters.position.x -= len(self.letters) / 2.0

	if level > 1:
		%LevelIntroAnimation.play("level_start")
		%LevelIntroAnimation.seek(0, true)
		$LevelLabel.text = "Level %d" % level


func _on_letter_locked(dropping_keycap: DroppingKeycap, index, success):
	var keycap: Keycap = self.spelled_letters[index]
	keycap.visible = true
	keycap.highlight(Keycap.COLOR_GREEN if success else Keycap.COLOR_RED)
	self.active_dropping_keycaps.erase(dropping_keycap)
	self.locked_letters_tweening += 1

	Engine.time_scale = dropping_keycap.time_scale * 8


func _on_letter_destroyed():
	self.locked_letters_tweening -= 1
	if Nodes.game.locked_letters_tweening == 0:
		Engine.time_scale = 1.0
		if len(self.active_dropping_keycaps) > 0:
			var dropping_keycap: DroppingKeycap = self.active_dropping_keycaps[0]
			Engine.time_scale = dropping_keycap.time_scale


func get_next_letter_color():
	var color: Color = self.letter_colors[self.letter_color_index]
	self.letter_color_index = self.letter_color_index + 1 if self.letter_color_index < len(self.letter_colors) - 2 else 0
	return color


func get_letter_position(letter: String):
	for y in Nodes.keyboard.layout:
		var line: String = Nodes.keyboard.layout[y]
		for x in range(len(line)):
			if letter == line[x]:
				return Vector2i(x, y)


func get_random_start_position(letter_data: LetterData, already_taken: Array):
	while true:
		var old_position = self.get_letter_position(letter_data.letter)
		if letter_data.offset == 0:
			return old_position
		else:
			var new_position = old_position
			var x_movement = randi_range(0, letter_data.offset)
			var y_movement = letter_data.offset - x_movement
			new_position.y = new_position.y + x_movement * (1 if randi_range(0, 1) == 1 else -1)
			new_position.x = new_position.x + y_movement * (1 if randi_range(0, 1) == 1 else -1)

			var start_letter:String = Nodes.keyboard.get_letter_by_position(new_position.x, new_position.y)
			if not start_letter in ["", " "] and new_position != old_position:
				return new_position


func get_lowest_level():
	var lowest_level = 99999
	for tmp_dropping_keycap in self.active_dropping_keycaps:
		if not tmp_dropping_keycap.locked and floor(tmp_dropping_keycap.y_position) < lowest_level:
			lowest_level = floor(tmp_dropping_keycap.y_position)
	return lowest_level


func is_lowest_level_dropping_keycap(dropping_keycap: DroppingKeycap):
	return self.get_lowest_level() == floor(dropping_keycap.y_position)


func get_dropping_keycap_order(dropping_keycap: DroppingKeycap) -> int:
	return self.active_dropping_keycaps.find(dropping_keycap)


func get_first_dropping_keycap_with_letter(letter: String) -> DroppingKeycap:
	for tmp_dropping_keycap in self.active_dropping_keycaps:
		if letter == tmp_dropping_keycap.letter:
			return tmp_dropping_keycap
	return null
