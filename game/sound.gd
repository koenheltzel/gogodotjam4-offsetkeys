extends Node3D

var drop_sound: int = 1

func play_drop_sound():
	self.get_node("DropSound%d" % self.drop_sound).play()
	self.drop_sound = self.drop_sound + 1 if self.drop_sound < 3 else 1


func play_letter_sound(success):
	(%RightSound if success else %WrongSound).play()
