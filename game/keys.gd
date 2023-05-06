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
				var keycap: KeyCap = KeycapScene.instantiate()
				keycap.letter = letter
				keycap.transform.origin.x = x
				keycap.transform.origin.z = z
				self.add_child(keycap)

