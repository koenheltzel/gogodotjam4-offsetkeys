class_name LetterData
extends RefCounted

var letter:String
var offset: int
var start_y_position: int

func _init(letter: String, offset: int, start_y_position: int):
	self.letter = letter
	self.offset = offset
	self.start_y_position = start_y_position
