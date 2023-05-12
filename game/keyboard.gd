@tool
class_name Keyboard
extends Node

const KeycapScene = preload("res://game/keycap/keycap.tscn")

var layout: Dictionary
var layouts: Dictionary = {
	0: { 0: "QWERTYUIOP", 1: "ASDFGHJKL", 2: " ZXCVBNM"},
	1: { 0: "QWERTZUIOP", 1: "ASDFGHJKL", 2: " YXCVBNM"},
	2: { 0: "AZERTYUIOP", 1: "QSDFGHJKLM", 2: " WXCVBN"},
}
var keycaps: Dictionary
var is_ready: bool = false


func _init():
	Nodes.keyboard = self


func _ready():
	Nodes.keyboard_ready.emit()
	self.is_ready = true


func set_layout(index: int):
	self.layout = self.layouts[index]

	self.keycaps = { 0: [], 1: [], 2: []}

	while self.get_child_count() > 0:
		self.remove_child(self.get_children()[0])

	for z in self.layout:
		var line: String = self.layout[z]
		for x in range(len(line)):
			var letter: String = line[x]
			if letter == " ":
				self.keycaps[z].append(null)
			else:
				var keycap: Keycap = KeycapScene.instantiate()
				keycap.type = Keycap.Types.LAYOUT
				keycap.letter = letter
				keycap.transform.origin.x = x
				keycap.transform.origin.z = z
				self.add_child(keycap)
				self.keycaps[z].append(keycap)

	if get_tree().paused:
		get_tree().paused = false
		await get_tree().create_timer(0.05).timeout
		get_tree().paused = true


func get_letter_by_position(x, y):
	if not y in self.layout:
		return ""
	elif x < 0 or x > len(self.layout[y]) - 1:
		return ""
	return self.layout[y][x]


func get_keycap_by_position(x, y):
	if not y in self.keycaps:
		return null
	elif x < 0 or x > len(self.keycaps[y]) - 1:
		return null
	return self.keycaps[y][x]
