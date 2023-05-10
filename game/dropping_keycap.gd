class_name DroppingKeycap
extends Node3D

signal letter_locked(dropping_keycap: DroppingKeycap, index: int, success: bool)
signal letter_destroyed()
@onready var keycap: Keycap = $Keycap
@onready var column: MeshInstance3D = $Column

@export var letter: String
@export var letter_index: int
@export var letter_color: Color
const BOTTOM: float = 0.03
const CONTROL_BOTTOM: float = 0.25
const MIN_COLUMN_ALPHA: float = 0.6
var x: int = 0
var y: int = 0
var selected: bool = false
var locked: bool = false
var tween: Tween


func _ready():
	self.keycap.letter = self.letter
	self.keycap.highlight_color = self.letter_color
	self.keycap.position.y = 15
	self.drop_unit()
	self.column.material_override = self.column.material_override.duplicate(true)
	(self.column.material_override as StandardMaterial3D).albedo_color = self.letter_color
#	self.column.mesh.surface_set_material(0, self.column.mesh.surface_get_material(0).duplicate(true))
#	(self.column.mesh.surface_get_material(0) as StandardMaterial3D).albedo_color = self.letter_color


func drop_unit(all_the_way=false):
	if self.keycap.position.y > self.BOTTOM or all_the_way:
		if self.tween:
			self.tween.kill()
		self.tween = self.get_tree().create_tween()
		self.tween.set_trans(Tween.TRANS_BOUNCE)
		var target_y:int
		if all_the_way or self.keycap.position.y <= 1:
			target_y = self.BOTTOM
		else:
			target_y = self.keycap.position.y - 1
		self.tween.tween_property(self.keycap, "position:y", target_y, 0.8).set_trans(Tween.TRANS_BOUNCE if self.keycap.position.y > 1 else Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
		self.tween.finished.connect(self.drop_unit)
	else:
		self.letter_destroyed.emit(self)
		self.queue_free()


func _process(delta):
	self.position.x = self.x
	self.position.z = self.y
	self.column.transparency = max(self.MIN_COLUMN_ALPHA, self.keycap.position.y / 15.0)

#	var height: float = self.keycap.position.y
#	if $Column:
#		$Column.set_scale(Vector3(1.0, self.keycap.position.y, 1.0))
#		$Column.position.y = height / 2.0

	if not self.locked and self.keycap.position.y < self.CONTROL_BOTTOM:
		self.lock()

func lock():
		self.locked = true
		$Column.visible = false

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

			if not self.selected and Nodes.game.is_first_dropping_keycap(self):
				self.drop_unit(true)
				self.lock()

		if not self.locked and self.selected and self.keycap.position.y >= self.CONTROL_BOTTOM and Nodes.game.is_first_dropping_keycap_with_letter(self):
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
				self.x = new_x
				self.y = new_y