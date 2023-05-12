extends Node3D

@onready var column_front: Sprite3D = %ColumnFront
@onready var column_left: Sprite3D = %ColumnLeft
@onready var column_right: Sprite3D = %ColumnRight
@onready var column_back: Sprite3D = %ColumnBack

var transparency: float:
	get:
		return transparency
	set(value):
		transparency = value
		self.column_front.transparency = transparency
		self.column_left.transparency = transparency
		self.column_right.transparency = transparency
		self.column_back.transparency = transparency
