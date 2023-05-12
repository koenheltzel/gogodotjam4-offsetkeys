extends Node3D

@onready var column_front: Sprite3D = %ColumnFront
@onready var column_left: Sprite3D = %ColumnLeft
@onready var column_right: Sprite3D = %ColumnRight
@onready var column_back: Sprite3D = %ColumnBack

var alpha: float:
	get:
		return alpha
	set(value):
		alpha = value
		self.column_front.modulate.a = alpha
		self.column_left.modulate.a = alpha
		self.column_right.modulate.a = alpha
		self.column_back.modulate.a = alpha
