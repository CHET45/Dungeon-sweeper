extends Sprite2D
@export var motion_flag:bool
var sixth_frame=true
@export var frame_pos=0
func enemy_animation():
	frame=frame_pos
	if frame_pos==0:
		frame_pos=4
	if frame_pos==256:
		frame_pos=6
	frame_pos+=1
	if frame_pos>6 and sixth_frame:		
		frame_pos=2
		sixth_frame=false
	if frame_pos>7:
		frame_pos=4
		sixth_frame=true
	$Timer.start()

func enemy_atack_animation():
	frame=frame_pos
	frame_pos+=1
	if frame_pos>4:
		get_parent().atack=false
		get_parent().atack_flag=true
		frame_pos=0
	if frame_pos>2:
		get_parent().damage_the_player()
	$atack_timer.start()
