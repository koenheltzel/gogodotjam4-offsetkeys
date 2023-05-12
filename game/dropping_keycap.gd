class_name DroppingKeycap
extends Node3D

signal letter_locked(dropping_keycap: DroppingKeycap, index: int, success: bool)
@onready var keycap: Keycap = $Keycap
@onready var column: Node3D = $Column

@export var letter: String
@export var letter_index: int
@export var letter_color: Color
const CONTROL_BOTTOM: float = 0.25
const MIN_COLUMN_ALPHA: float = 0.4
const Y_SCALE: float = 1.5
const DROP_TIME: float = 1.5
var x: int = 0
var y: int = 0
var selected: bool = false
var locked: bool = false
var time_tween: Tween
var start_y_position: int = 0
var y_position: float:
	get:
		return y_position
	set(value):
		y_position = value
		keycap.position.y = value * Y_SCALE
		column.scale.y = y_position * Y_SCALE
		column.transparency = min(column.transparency, max(MIN_COLUMN_ALPHA, y_position / 20.0))


func _ready():
	self.keycap.letter = self.letter
	self.keycap.highlight_color = self.letter_color
	self.y_position = self.start_y_position

#	self.column.material_override = self.column.material_override.duplicate(true)
#	(self.column.material_override as StandardMaterial3D).albedo_color = self.letter_color
	self.column.transparency = 1.0

	var tween = self.get_tree().create_tween()
	var tmp_y_position = self.y_position
	for i in range(self.y_position + 1):
		tween.tween_property(self, "y_position", tmp_y_position, self.DROP_TIME).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
		tmp_y_position = tmp_y_position - 1.0
	tween.tween_interval(0.25)
	tween.finished.connect(self.tween_ready)


func tween_ready():
	self.queue_free()
	Engine.time_scale = 1.0

	if not Input.is_action_pressed(self.letter):
		var keyboard_keycap:Keycap = Nodes.keyboard.get_keycap_by_position(self.x, self.y)
		keyboard_keycap.reset_highlight()


func _process(delta):
	self.position.x = self.x
	self.position.z = self.y

	if not self.locked and self.y_position < self.CONTROL_BOTTOM:
		self.lock()


func lock():
	self.locked = true

	var success: bool = self.letter == Nodes.keyboard.get_letter_by_position(self.x, self.y)
	if success:
		Nodes.keyboard.get_keycap_by_position(self.x, self.y).highlight(Keycap.COLOR_GREEN)
		self.keycap.highlight(Keycap.COLOR_GREEN)
	else:
		Nodes.keyboard.get_keycap_by_position(self.x, self.y).highlight(Keycap.COLOR_RED)
		self.keycap.highlight(Keycap.COLOR_RED)

	self.letter_locked.emit(self, self.letter_index, success)


func _input(event):
	if not self.locked and self.letter != "" and not event.is_echo():
		if InputMap.has_action(self.letter) and event.is_action(self.letter) and Nodes.game.is_first_dropping_keycap_with_letter(self):
			self.selected = event.is_action_pressed(self.letter)

			if self.selected:
				self.keycap.highlight(self.keycap.highlight_color)

			if not self.selected and Nodes.game.is_first_dropping_keycap(self):
				Engine.time_scale = self.DROP_TIME * 8
				self.lock()

		if not self.locked and self.selected and self.y_position >= self.CONTROL_BOTTOM and Nodes.game.is_first_dropping_keycap_with_letter(self):
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

			if not Nodes.keyboard.get_letter_by_position(new_x, new_y) in ["", " "]:
				var keycap:Keycap = Nodes.keyboard.get_keycap_by_position(self.x, self.y)
				keycap.reset_highlight()

				self.x = new_x
				self.y = new_y

				keycap = Nodes.keyboard.get_keycap_by_position(self.x, self.y)
				if keycap.letter == self.letter:
					keycap.highlight(Keycap.COLOR_GREEN)
				else:
					keycap.highlight(Keycap.COLOR_RED)
