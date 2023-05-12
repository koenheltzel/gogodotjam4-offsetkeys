extends Node3D

@export var game_scene:PackedScene
@export var settings_scene:PackedScene

@onready var overlay := %FadeOverlay
@onready var continue_button := %ContinueButton
@onready var new_game_button := %NewGameButton
@onready var settings_button := %SettingsButton
@onready var exit_button := %ExitButton
@onready var game_title: MeshInstance3D = %GameTitle

var next_scene = game_scene
var new_game = true

func _ready() -> void:
	overlay.visible = true
	new_game_button.disabled = game_scene == null
	settings_button.disabled = settings_scene == null
	continue_button.visible = SaveGame.has_save() and SaveGame.ENABLED

	# connect signals
	new_game_button.pressed.connect(_on_play_button_pressed)
	continue_button.pressed.connect(_on_continue_button_pressed)
	settings_button.pressed.connect(_on_settings_button_pressed)
	exit_button.pressed.connect(_on_exit_button_pressed)
	overlay.on_complete_fade_out.connect(_on_fade_overlay_on_complete_fade_out)

	if continue_button.visible:
		continue_button.grab_focus()
	else:
		new_game_button.grab_focus()

func _process(delta):
	# Wiggle game title in relation to the mouse position.
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	viewport_size /= 2.0
	var mouse_position: Vector2 = get_viewport().get_mouse_position()
	var x_movement: float = (mouse_position.x - viewport_size.x) / viewport_size.x
	var y_movement: float = (mouse_position.y - viewport_size.y) / viewport_size.y
	self.game_title.rotation.y = x_movement * 0.1
	self.game_title.rotation.x = y_movement * 0.1

func _on_settings_button_pressed() -> void:
	new_game = false
	next_scene = settings_scene
	overlay.fade_out()

func _on_play_button_pressed() -> void:
	next_scene = game_scene
	overlay.fade_out()

func _on_continue_button_pressed() -> void:
	new_game = false
	next_scene = game_scene
	overlay.fade_out()

func _on_exit_button_pressed() -> void:
	get_tree().quit()

func _on_fade_overlay_on_complete_fade_out() -> void:
	if new_game and SaveGame.has_save():
		SaveGame.delete_save()
	get_tree().change_scene_to_packed(next_scene)
