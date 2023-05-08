@tool
class_name KeyCap
extends Node3D

@export var letter: String

@onready var mesh_instance_3d = $MeshInstance3D
@onready var label_3d: Label3D = $Label3D

func _ready():
	self.label_3d.text = self.letter
	self.mesh_instance_3d.material_override = self.mesh_instance_3d.material_override.duplicate(true)
#	(self.mesh_instance_3d.material_override as StandardMaterial3D).backlight_enabled = false
#	(self.mesh_instance_3d.material_override as StandardMaterial3D).albedo_color = Color.CORNFLOWER_BLUE

func _input(event) -> void:
	(self.mesh_instance_3d.material_override as StandardMaterial3D).albedo_color = Color.CORNFLOWER_BLUE if Input.is_action_pressed(self.letter) else Color.ANTIQUE_WHITE
#	(self.mesh_instance_3d.material_override as StandardMaterial3D).backlight_enabled = Input.is_action_pressed(self.letter)
	self.position.y = -0.25 if Input.is_action_pressed(self.letter) else 0.0
