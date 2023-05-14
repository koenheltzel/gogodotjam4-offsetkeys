class_name LetterData
extends RefCounted

var letter:String
var offset: int
var start_y_position: int
var time_scale: float
var destroyed_callback: Callable
var destroyed_callback_args: Array
var next_up_callback: Callable
var next_up_callback_args: Array
var fixed_offset: Vector2i

func _init(letter: String, start_y_position: int, time_scale: float, offset: int=0):
	self.letter = letter
	self.start_y_position = start_y_position
	self.time_scale = time_scale
	self.offset = offset

func set_destroyed_callback(destroyed_callback, destroyed_callback_args=[]):
	self.destroyed_callback = destroyed_callback
	self.destroyed_callback_args = destroyed_callback_args
	return self

func set_next_up_callback(next_up_callback, next_up_callback_args=[]):
	self.next_up_callback = next_up_callback
	self.next_up_callback_args = next_up_callback_args
	return self

func set_fixed_offset(offset: Vector2i):
	self.fixed_offset = offset
	return self
