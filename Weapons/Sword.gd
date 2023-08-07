extends "res://Weapons/Melee_weapon.gd"
var rotation_direction=1
var animation_part=1
# Called when the node enters the scene tree for the first time.
func _ready():
	#weapon_node=get_node(".")
	weapon_path=get_path()
	#$Weapon_sprite.texture=$Weapon_sprite

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	$Weapon_sprite.flip_h=flip
	if animation:
		if animation_part==1:
			animation_part=2
			atk_speed=-atk_speed/3.5
		rotation_degrees+=atk_speed*rotation_direction
	if flip:
		rotation_direction=-1
	else:
		rotation_direction=1
	if rotation_direction*rotation_degrees<=-40 and animation_part==2:
		atk_speed=-atk_speed*3.5
	if rotation_direction*rotation_degrees>=180:
		rotation_degrees=180*rotation_direction
		atk_speed=-atk_speed
		animation_part=3
	if rotation_direction*rotation_degrees<=0 and animation_part==3:
		rotation_degrees=0*rotation_direction
		animation=false
		$Weapon_area.set_collision_layer_value(7,false)
		atk_speed=-atk_speed
		animation_part=1
