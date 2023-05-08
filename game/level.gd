class_name Level
extends Node3D

@export var letters: String

var letter_index: int = 0
const DroppingKeycapScene = preload("res://game/dropping_keycap/dropping_keycap.tscn")


func _ready():
	self.release_letter()


func release_letter():
	if letter_index < self.letters.length():
		var letter = self.letters[self.letter_index]

		var dropping_key = DroppingKeycapScene.instantiate()
		dropping_key.letter = letter
		self.add_child(dropping_key)

		var timer = Timer.new()
		timer.wait_time = 4
		timer.one_shot = true
		timer.autostart = true
		timer.timeout.connect(self.release_letter)
		self.add_child(timer)

		self.letter_index += 1
