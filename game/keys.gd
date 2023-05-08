@tool
extends Node3D

const KeycapScene = preload("res://game/keycap/keycap.tscn")


func _ready():
	var layout := { 0: "QWERTYUIOP", 1: "ASDFGHJKL", 2: " ZXCVBNM"}

	for z in layout:
		var line: String = layout[z]
		for x in range(len(line)):
			var letter: String = line[x]
			if letter != " ":
				var keycap: Keycap = KeycapScene.instantiate()
				keycap.letter = letter
				keycap.transform.origin.x = x
				keycap.transform.origin.z = z
				self.add_child(keycap)

	var keycap: Keycap = KeycapScene.instantiate()
	keycap.letter = "↑"
	keycap.transform.origin.x = 10
	keycap.transform.origin.z = 2
	self.add_child(keycap)

	keycap = KeycapScene.instantiate()
	keycap.letter = "←"
	keycap.transform.origin.x = 9
	keycap.transform.origin.z = 3
	self.add_child(keycap)

	keycap = KeycapScene.instantiate()
	keycap.letter = "↓"
	keycap.transform.origin.x = 10
	keycap.transform.origin.z = 3
	self.add_child(keycap)

	keycap = KeycapScene.instantiate()
	keycap.letter = "→"
	keycap.transform.origin.x = 11
	keycap.transform.origin.z = 3
	self.add_child(keycap)
