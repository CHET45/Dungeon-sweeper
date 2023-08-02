extends "res://Weapons/Melee_weapon.gd"
var rotation_direction=1
var animation_part=1

# Called when the node enters the scene tree for the first time.
func _ready():
	#weapon_node=get_node(".")
	weapon_path=get_path()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	$Weapon_sprite.flip_v=flip
	$Weapon_area.position.x=-$Weapon_sprite.offset.y
	if animation:
		if animation_part==1:
			animation_part=2
			atk_speed=-atk_speed/4
		rotation_degrees+=atk_speed*rotation_direction
	if flip:
		$Weapon_sprite.offset.y=4
		rotation_direction=-1
	else:
		$Weapon_sprite.offset.y=-4
		rotation_direction=1
	
	if rotation_direction*rotation_degrees<=-40:
		atk_speed=-atk_speed*4
	if rotation_direction*rotation_degrees>=120:
		atk_speed=-atk_speed/2.5
		animation_part=3
		$Weapon_area.set_collision_layer_value(7,false)
	if rotation_direction*rotation_degrees<=0 and animation_part==3:
		animation_part=1
		animation=false
		atk_speed=-atk_speed*2.5
		rotation_degrees=0
	
