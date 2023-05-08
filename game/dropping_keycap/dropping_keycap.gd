extends Node3D

@onready var keycap: Keycap = $Keycap

@export var letter: String

var x: int = 0
var y: int = 0


func _ready():
	self.keycap.letter = self.letter
	self.keycap.position.y = 15
	var tween: Tween = self.get_tree().create_tween()
	tween.tween_property(self.keycap, "position:y", 0.01, 5)
	tween.finished.connect(self.keycap_dropped)


func keycap_dropped():
	var timer = Timer.new()
	timer.wait_time = 0.25
	timer.one_shot = true
	timer.autostart = true
	timer.timeout.connect(self.timeout_keycap)
	self.add_child(timer)


func timeout_keycap():
	self.queue_free()


func _process(delta):
	self.position.x = self.x
	self.position.z = -self.y


func _input(event):
	if event.is_action_pressed("move_left", true) and not event.is_echo():
		self.x -= 1
	if event.is_action_pressed("move_right", true) and not event.is_echo():
		self.x += 1
	if event.is_action_pressed("move_down", true) and not event.is_echo():
		self.y -= 1
	if event.is_action_pressed("move_up", true) and not event.is_echo():
		self.y += 1

	if Input.is_action_pressed(self.keycap.letter) and not event.is_echo():
		if self.keycap.position.y < 0.25:
			#			self.queue_free()
			self.keycap.highlight(Color.GREEN)
		else:
			self.keycap.highlight(Color.RED)
