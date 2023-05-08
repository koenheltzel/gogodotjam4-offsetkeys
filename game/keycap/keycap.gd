@tool
class_name Keycap
extends Node3D

@export var letter: String

@onready var mesh_instance_3d = $MeshInstance3D
@onready var label_3d: Label3D = $Label3D


func _ready():
	self.mesh_instance_3d.material_override = self.mesh_instance_3d.material_override.duplicate(true)
	self.reset_highlight()


func _process(delta):
	self.label_3d.text = self.letter  # Should be in _ready but when instantiating DroppingKeycap, this doesn't work.


func _input(event) -> void:
	var action_name: String
	if self.letter == "↑":
		action_name = "move_up"
	elif self.letter == "↓":
		action_name = "move_down"
	elif self.letter == "←":
		action_name = "move_left"
	elif self.letter == "→":
		action_name = "move_right"
	else:
		action_name = self.letter

	if action_name != "":
		if Input.is_action_pressed(action_name):
			self.highlight(Color.LIGHT_BLUE)
			# self.position.y = -0.25 if Input.is_action_pressed(self.letter) else 0.0
		else:
			self.reset_highlight()


func reset_highlight():
	(self.mesh_instance_3d.material_override as StandardMaterial3D).albedo_color = Color.ANTIQUE_WHITE
	(self.mesh_instance_3d.material_override as StandardMaterial3D).rim_enabled = false


func highlight(color: Color):
	(self.mesh_instance_3d.material_override as StandardMaterial3D).albedo_color = color #if Input.is_action_pressed(self.letter) else Color.ANTIQUE_WHITE
	(self.mesh_instance_3d.material_override as StandardMaterial3D).rim = 0.5
	(self.mesh_instance_3d.material_override as StandardMaterial3D).rim_tint = 0.5
	(self.mesh_instance_3d.material_override as StandardMaterial3D).rim_enabled = true
