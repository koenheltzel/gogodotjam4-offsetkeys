extends Node

signal keyboard_set
signal keyboard_ready
signal game_ready

var keyboard: Keyboard:
	get:
		return keyboard
	set(value):
		keyboard = value
		keyboard_set.emit()

var game: Game:
	get:
		return game
	set(value):
		game = value
		game_ready.emit()
