extends Sprite2D
@export var motion_flag:bool
var frame_pos:int=5
func Man_animation():
	frame=frame_pos	
	frame_pos+=1
	$Timer.start()
	if frame_pos>8:
		frame_pos=5
