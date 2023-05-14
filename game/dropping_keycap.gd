class_name DroppingKeycap
extends Node3D

signal letter_next_up(dropping_keycap: DroppingKeycap)
signal letter_locked(dropping_keycap: DroppingKeycap, index: int, success: bool)
signal letter_destroyed()
@onready var keycap: Keycap = $Keycap
@onready var column: Node3D = $Column

@export var letter: String
@export var letter_index: int
@export var letter_color: Color
const CONTROL_BOTTOM: float = 0.25
const MAX_COLUMN_ALPHA: float = 0.6
const Y_SCALE: float = 1.5
const DROP_TIME: float = 1.5
var x: int = 0
var y: int = 0
var selected: bool = false
var locked: bool = false
var time_tween: Tween
var start_y_position: int = 0
var last_keycap: bool = false
var time_scale: float
var y_position: float:
	get:
		return y_position
	set(value):
		y_position = value
		keycap.position.y = value * Y_SCALE
		column.scale.y = value * Y_SCALE
		column.alpha = max(0, min(DroppingKeycap.MAX_COLUMN_ALPHA, 1.0 - value / 20.0))


func _ready():
	self.keycap.letter = self.letter
	self.keycap.highlight_color = self.letter_color
	self.column.alpha = 0  # Set to fully transparent before setting y_position (because its setter uses the alpha value).
	self.y_position = self.start_y_position

	self._process(0)  # Set the correct x/z position, if we don't do this it will show on 0, 0 for 1 frame.

	var tween = self.get_tree().create_tween()
	var tmp_y_position = self.y_position
	for i in range(self.y_position + 1):
		if self.last_keycap:
			tween.tween_callback(Sound.play_drop_sound)
		tween.tween_property(self, "y_position", tmp_y_position, self.DROP_TIME).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
		tmp_y_position = tmp_y_position - 1.0
	tween.tween_interval(0.25)
	tween.finished.connect(self.tween_ready)


func tween_ready():
	self.queue_free()
	self.letter_destroyed.emit()

	if not Input.is_action_pressed(self.letter):
		var keyboard_keycap:Keycap = Nodes.keyboard.get_keycap_by_position(self.x, self.y)
		keyboard_keycap.reset_highlight()


func _process(delta):
	self.position.x = self.x
	self.position.z = self.y

	if not self.locked and self.y_position < self.CONTROL_BOTTOM:
		self.lock()


func highlight_right_or_wrong():
	if self.is_right_position():
		Nodes.keyboard.get_keycap_by_position(self.x, self.y).highlight(Keycap.COLOR_GREEN)
		self.keycap.highlight(Keycap.COLOR_GREEN)
	else:
		Nodes.keyboard.get_keycap_by_position(self.x, self.y).highlight(Keycap.COLOR_RED)
		self.keycap.highlight(Keycap.COLOR_RED)


func is_right_position():
	return self.letter == Nodes.keyboard.get_letter_by_position(self.x, self.y)


func lock():
	self.locked = true
	self.highlight_right_or_wrong()
	self.letter_locked.emit(self, self.letter_index, self.is_right_position())


func _input(event):
	if not self.locked and self.letter != "" and not event.is_echo():
		if InputMap.has_action(self.letter) and event.is_action(self.letter) and Nodes.game.is_lowest_level_dropping_keycap(self):
			self.selected = event.is_action_pressed(self.letter)

			if self.selected:
				self.keycap.highlight(self.keycap.highlight_color)

			if not self.selected and Nodes.game.is_lowest_level_dropping_keycap(self):
				if Nodes.game.are_lowest_level_keys_all_released():
					self.lock()
				else:
					self.highlight_right_or_wrong()

		if not self.locked and self.selected and self.y_position >= self.CONTROL_BOTTOM and Nodes.game.is_lowest_level_dropping_keycap(self):
			var new_x:int = self.x + 0
			var new_y:int = self.y + 0

			if event.is_action_pressed("move_left", true):
				new_x -= 1
			if event.is_action_pressed("move_right", true):
				new_x += 1
			if event.is_action_pressed("move_down", true):
				new_y += 1
			if event.is_action_pressed("move_up", true):
				new_y -= 1

			if not Nodes.keyboard.get_letter_by_position(new_x, new_y) in ["", " "] and not Nodes.game.is_position_taken(Vector2i(new_x, new_y)):
				var keyboard_keycap:Keycap = Nodes.keyboard.get_keycap_by_position(self.x, self.y)
				keyboard_keycap.reset_highlight()

				self.x = new_x
				self.y = new_y

			var keyboard_keycap:Keycap = Nodes.keyboard.get_keycap_by_position(self.x, self.y)
			if keyboard_keycap.letter == self.letter:
				keyboard_keycap.highlight(Keycap.COLOR_GREEN)
			else:
				keyboard_keycap.highlight(Keycap.COLOR_RED)
