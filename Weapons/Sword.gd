extends "res://Weapons/Melee_weapon.gd"
var rotation_direction=1
var animation_part=1
# Called when the node enters the scene tree for the first time.
#func _ready():
#	$Stats.text="Damage: "+var_to_str(damage)+"\nAtack speed: "+var_to_str(atk_speed/10)
func set_weapon_path():
	weapon_path=get_path()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func weapon_atack_animation(delta):
	$Weapon_sprite.flip_h=flip
	if animation:
		if animation_part==1:
			animation_part=2
			atk_speed=-atk_speed/3.5
		rotation_degrees+=atk_speed*rotation_direction*delta*100
	if flip:
		rotation_direction=-1
	else:
		rotation_direction=1
	if rotation_direction*rotation_degrees<=-40 and animation_part==2:
		atk_speed=-atk_speed*3.5
		animation_part=3
	if rotation_direction*rotation_degrees>=180 and animation_part==3:
		rotation_degrees=180*rotation_direction
		atk_speed=-atk_speed*1.1
		$Weapon_sprite.position.y-=15
		$Weapon_area.position.y-=15
		animation_part=4
	if rotation_direction*rotation_degrees<=-360 and animation_part==4: 
		rotation_degrees=0*rotation_direction
		animation=false
		$Weapon_area.set_collision_layer_value(7,false)
		atk_speed=-atk_speed/1.1
		$Weapon_sprite.position.y+=15
		$Weapon_area.position.y+=15
		animation_part=1
func set_default_stats():
	damage=10
	atk_speed=11
