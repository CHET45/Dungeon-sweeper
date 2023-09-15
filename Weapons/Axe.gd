extends "res://Weapons/Melee_weapon.gd"
var rotation_direction=1
var animation_part=1


func set_weapon_path():
	weapon_path=get_path()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func weapon_atack_animation(delta):
	$Weapon_sprite.flip_v=flip
	$Weapon_area.position.x=-$Weapon_sprite.offset.y
	if animation:
		if animation_part==1:
			animation_part=2
			atk_speed=-atk_speed/4
		rotation_degrees+=atk_speed*rotation_direction*delta*100
	if flip:
		$Weapon_sprite.offset.y=4
		rotation_direction=-1
	else:
		$Weapon_sprite.offset.y=-4
		rotation_direction=1
	
	if animation_part==2:
		if $Weapon_sprite.position.y>-10:
			$Weapon_sprite.position.y-=0.3
		if $Weapon_area.position.y>-30:
			$Weapon_area.position.y-=0.3
	if animation_part==3 and rotation_direction*rotation_degrees>=280:
		if $Weapon_sprite.position.y<0:
			$Weapon_sprite.position.y+=0.5
		if $Weapon_area.position.y<-20:
			$Weapon_area.position.y+=0.47
	if rotation_direction*rotation_degrees<=-40:
		atk_speed=-atk_speed*4
	if rotation_direction*rotation_degrees>=180 and animation_part==2:
		atk_speed=atk_speed/2.5
		animation_part=3
	if rotation_direction*rotation_degrees>=360 and animation_part==3:
		animation_part=1
		animation=false
		atk_speed=atk_speed*2.5
		rotation_degrees=0
		$Weapon_sprite.position.y=0
		$Weapon_area.position.y=0
		$Weapon_area.set_collision_layer_value(7,false)
	
func set_deafault_stats():
	damage=15
	atk_speed=9
