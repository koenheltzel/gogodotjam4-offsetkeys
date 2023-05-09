@tool
class_name Keycap
extends Node3D

const COLOR_WHITE := Color("FFFFFF", 0.75)
const COLOR_RED := Color("F94144", 0.75)
const COLOR_ORANGE := Color("F3722C", 0.75)
const COLOR_LIGHT_ORANGE := Color("F8961E", 0.75)
const COLOR_YELLOW := Color("F9C74F", 0.75)
const COLOR_GREEN := Color("90BE6D", 0.75)
const COLOR_TURQUOSE := Color("43AA8B", 0.75)
const COLOR_BLUE := Color("577590", 0.75)

@export var letter: String
var highlight_color: Color = Color.CORNFLOWER_BLUE

@onready var mesh_instance_3d = $MeshInstance3D
@onready var label_3d: Label3D = $Label3D
enum Types { LAYOUT, DROPPING, SPELLED, UNDEFINED }
@export var type: Types = Types.UNDEFINED


func _ready():
	assert(self.type != Types.UNDEFINED)
	self.mesh_instance_3d.material_override = self.mesh_instance_3d.material_override.duplicate(true)
	self.reset_highlight()


func _process(delta):
	self.label_3d.text = self.letter  # Should be in _ready but when instantiating DroppingKeycap, this doesn't work.


func _input(event) -> void:
	if (self.type == Types.LAYOUT or self.type == Types.DROPPING) and InputMap.has_action(self.letter) and event.is_action(self.letter) and not event.is_echo():
		if event.is_action_pressed(self.letter):
			self.highlight(self.highlight_color, 0)
			# self.position.y = -0.25 if Input.is_action_pressed(self.letter) else 0.0
		else:
			self.reset_highlight()


func reset_highlight():
#	(self.mesh_instance_3d.material_override as StandardMaterial3D).albedo_color = Color.ANTIQUE_WHITE
	(self.mesh_instance_3d.material_override as StandardMaterial3D).backlight_enabled = false
#	(self.mesh_instance_3d.material_override as StandardMaterial3D).rim_enabled = false
#	(self.mesh_instance_3d.material_override as StandardMaterial3D).emission_enabled = false


func highlight(color: Color, duration=0.25):
#	(self.mesh_instance_3d.material_override as StandardMaterial3D).albedo_color = color #if Input.is_action_pressed(self.letter) else Color.ANTIQUE_WHITE
	(self.mesh_instance_3d.material_override as StandardMaterial3D).backlight = color
	(self.mesh_instance_3d.material_override as StandardMaterial3D).backlight_enabled = true
#	(self.mesh_instance_3d.material_override as StandardMaterial3D).emission = color
#	(self.mesh_instance_3d.material_override as StandardMaterial3D).emission_enabled = true
#	(self.mesh_instance_3d.material_override as StandardMaterial3D).emission_energy_multiplier = 1.0
#	(self.mesh_instance_3d.material_override as StandardMaterial3D).rim = 0.15
#	(self.mesh_instance_3d.material_override as StandardMaterial3D).rim_tint = 1.0
#	(self.mesh_instance_3d.material_override as StandardMaterial3D).rim_enabled = true

	if duration > 0:
		var timer = Timer.new()
		timer.wait_time = 0.25
		timer.one_shot = true
		timer.autostart = true
		timer.timeout.connect(self.reset_highlight)
		self.add_child(timer)
