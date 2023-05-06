@tool
class_name KeyCap
extends Node3D

@export var letter: String

@onready var mesh_instance_3d: MeshInstance3D = %MeshInstance3D
@onready var label_3d: Label3D = %Label3D

func _ready():
	self.label_3d.text = self.letter
	self.mesh_instance_3d.material_override = self.mesh_instance_3d.mesh.surface_get_material(0).duplicate(true)
	(self.mesh_instance_3d.material_override as StandardMaterial3D).backlight_enabled = false
	(self.mesh_instance_3d.material_override as StandardMaterial3D).backlight = Color.CORNFLOWER_BLUE

func _input(event) -> void:
	(self.mesh_instance_3d.material_override as StandardMaterial3D).backlight_enabled = Input.is_action_pressed(self.letter)
	self.position.y = -0.1 if Input.is_action_pressed(self.letter) else 0
