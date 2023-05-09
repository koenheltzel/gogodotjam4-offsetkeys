extends Node3D

signal letter_locked(index: int, success: bool)
@onready var keycap: Keycap = $Keycap
@onready var column: MeshInstance3D = $Column

@export var letter: String
@export var letter_index: int
@export var letter_color: Color
const BOTTOM: float = 0.03
const CONTROL_BOTTOM: float = 0.25
var x: int = 0
var y: int = 0
var toggled: bool = false
var locked: bool = false


func _ready():
	self.keycap.letter = self.letter
	self.keycap.highlight_color = self.letter_color
	self.keycap.position.y = 15
	self.drop_unit()
	self.column.material_override = self.column.material_override.duplicate(true)
	(self.column.material_override as StandardMaterial3D).albedo_color = self.letter_color
#	self.column.mesh.surface_set_material(0, self.column.mesh.surface_get_material(0).duplicate(true))
#	(self.column.mesh.surface_get_material(0) as StandardMaterial3D).albedo_color = self.letter_color


func drop_unit():
	if self.keycap.position.y > self.BOTTOM:
		var tween = self.get_tree().create_tween()
		tween.set_trans(Tween.TRANS_BOUNCE)
		tween.tween_property(self.keycap, "position:y", self.keycap.position.y - 1 if self.keycap.position.y > 1 else 0.03, 0.8).set_trans(Tween.TRANS_BOUNCE if self.keycap.position.y > 1 else Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
		tween.finished.connect(self.drop_unit)
	else:
		self.queue_free()


func _process(delta):
	self.position.x = self.x
	self.position.z = self.y

#	var height: float = self.keycap.position.y
#	if $Column:
#		$Column.set_scale(Vector3(1.0, self.keycap.position.y, 1.0))
#		$Column.position.y = height / 2.0

	if not self.locked and self.keycap.position.y < self.CONTROL_BOTTOM:
		self.locked = true

		$Column.visible = false

		var success: bool = self.letter == Keyboard.get_letter_by_position(self.x, self.y)
		if success:
			Keyboard.get_keycap_by_position(self.x, self.y).highlight(Keycap.COLOR_GREEN)
			self.keycap.highlight(Keycap.COLOR_GREEN)
		else:
			Keyboard.get_keycap_by_position(self.x, self.y).highlight(Keycap.COLOR_RED)
			self.keycap.highlight(Keycap.COLOR_RED)

		self.letter_locked.emit(self.letter_index, success)


func _input(event):
	if not self.locked and self.letter != "" and not event.is_echo():
		if InputMap.has_action(self.letter) and event.is_action(self.letter):
			self.toggled = event.is_action_pressed(self.letter)

		if self.toggled and self.keycap.position.y >= self.CONTROL_BOTTOM:
			if event.is_action_pressed("move_left", true):
				self.x -= 1
			if event.is_action_pressed("move_right", true):
				self.x += 1
			if event.is_action_pressed("move_down", true):
				self.y += 1
			if event.is_action_pressed("move_up", true):
				self.y -= 1
