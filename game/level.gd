class_name Level
extends Node3D

@export var release_speed: float = 4.0
@export var letters: String
var spelled_letters: Array = []
var letter_colors: Array = [Color.CORNFLOWER_BLUE] #Keycap.COLOR_ORANGE, Keycap.COLOR_LIGHT_ORANGE, Keycap.COLOR_YELLOW, Keycap.COLOR_BLUE
var letter_color_index: int = 0

var letter_index: int = 0
const KeycapScene = preload("res://game/keycap/keycap.tscn")
const DroppingKeycapScene = preload("res://game/dropping_keycap/dropping_keycap.tscn")


func _ready():
	self.release_letter()
	self.add_child(Keyboard)

	for i in range(self.letters.length()):
		var letter: String = self.letters[i]
		if letter != " ":
			var keycap: Keycap = KeycapScene.instantiate()
			keycap.type = Keycap.Types.SPELLED
			keycap.letter = letter
			keycap.position.x = i
			keycap.visible = false
			$SpelledLetters.add_child(keycap)
			self.spelled_letters.append(keycap)
		else:
			self.spelled_letters.append(null)
	$SpelledLetters.scale = Vector3(0.75, 0.75, 0.75)
	$SpelledLetters.position.x -= self.letters.length() / 2.0

func release_letter():
	while letter_index < self.letters.length():
		var letter = self.letters[self.letter_index]
		if letter == " ":
			self.letter_index += 1
		else:
			var position = self.get_random_start_position(letter, 0, 3, [])
			var dropping_key = DroppingKeycapScene.instantiate()
			dropping_key.letter = letter
			dropping_key.x = position.x
			dropping_key.y = position.y
			dropping_key.letter_index = self.letter_index
			dropping_key.letter_color = self.get_next_letter_color()
			dropping_key.letter_locked.connect(self.show_spelled_letter)
			self.add_child(dropping_key)

			var timer = Timer.new()
			timer.wait_time = self.release_speed
			timer.one_shot = true
			timer.autostart = true
			timer.timeout.connect(self.release_letter)
			self.add_child(timer)

			self.letter_index += 1
			break


func show_spelled_letter(index, success):
	var keycap: Keycap = self.spelled_letters[index]
	keycap.visible = true
	keycap.highlight(Keycap.COLOR_GREEN if success else Keycap.COLOR_RED, 0)


func get_next_letter_color():
	var color: Color = self.letter_colors[self.letter_color_index]
	self.letter_color_index = self.letter_color_index + 1 if self.letter_color_index < len(self.letter_colors) - 2 else 0
	return color


func get_letter_position(letter: String):
	for y in Keyboard.layout:
		var line: String = Keyboard.layout[y]
		for x in range(len(line)):
			if letter == line[x]:
				return Vector2i(x, y)

func get_random_start_position(letter: String, min_spaces: int, max_spaces: int, already_taken: Array):
	while true:
		var old_position = self.get_letter_position(letter)
		var new_position = old_position
		new_position.y = new_position.y + randi_range(min_spaces, max_spaces) * (1 if randi_range(0, 1) == 1 else -1)
		new_position.y = max(0, min(2, new_position.y))
		new_position.x = new_position.x + randi_range(min_spaces, max_spaces) * (1 if randi_range(0, 1) == 1 else -1)
		new_position.x = max(0, min(Keyboard.layout[new_position.y].length(), new_position.x))
		var start_letter:String = Keyboard.get_letter_by_position(new_position.x, new_position.y)
		if not start_letter in ["", " "] and new_position != old_position:
			return new_position
