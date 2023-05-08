@tool
extends Node

var layout: Dictionary


func _init():
	self.layout = { 0: "QWERTYUIOP", 1: "ASDFGHJKL", 2: " ZXCVBNM"}


func get_letter_by_position(x, y):
	if not y in self.layout:
		return ""
	elif x > len(self.layout[y]) - 1:
		return ""
	return self.layout[y][x]
