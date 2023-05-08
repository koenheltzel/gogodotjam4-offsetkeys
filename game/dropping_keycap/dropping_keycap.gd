extends Node3D

@onready var keycap: Keycap = $Keycap

@export var letter: String
const BOTTOM: float = 0.03
const CONTROL_BOTTOM: float = 0.25
var x: int = 0
var y: int = 0
var toggled: bool = false
var locked: bool = false


func _ready():
	self.keycap.letter = self.letter
	self.keycap.position.y = 15
	self.drop_unit()


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

	if not self.locked and self.keycap.position.y < self.CONTROL_BOTTOM:
		self.locked = true

		$Column.visible = false

		if self.letter == Keyboard.get_letter_by_position(self.x, self.y):
			Keyboard.get_keycap_by_position(self.x, self.y).highlight(Color.LIGHT_GREEN)
			self.keycap.highlight(Color.LIGHT_GREEN)
		else:
			Keyboard.get_keycap_by_position(self.x, self.y).highlight(Color.LIGHT_CORAL)
			self.keycap.highlight(Color.LIGHT_CORAL)


func _input(event):
	if not self.locked:
		if event.is_action(self.letter) and not event.is_echo():
			self.toggled = event.is_action_pressed(self.letter)

		if self.toggled and self.keycap.position.y >= self.CONTROL_BOTTOM:
			if event.is_action_pressed("move_left", true) and not event.is_echo():
				self.x -= 1
			if event.is_action_pressed("move_right", true) and not event.is_echo():
				self.x += 1
			if event.is_action_pressed("move_down", true) and not event.is_echo():
				self.y += 1
			if event.is_action_pressed("move_up", true) and not event.is_echo():
				self.y -= 1
