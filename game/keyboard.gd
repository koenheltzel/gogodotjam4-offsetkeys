@tool
extends Node

const KeycapScene = preload("res://game/keycap/keycap.tscn")

var layout: Dictionary
var keycaps: Dictionary


func _init():
	self.layout = { 0: "QWERTYUIOP", 1: "ASDFGHJKL", 2: " ZXCVBNM"}
	self.keycaps = { 0: [], 1: [], 2: []}

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


func get_letter_by_position(x, y):
	if not y in self.layout:
		return ""
	elif x > len(self.layout[y]) - 1:
		return ""
	return self.layout[y][x]


func get_keycap_by_position(x, y):
	if not y in self.keycaps:
		return null
	elif x > len(self.keycaps[y]) - 1:
		return null
	return self.keycaps[y][x]
