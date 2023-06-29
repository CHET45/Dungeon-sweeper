extends "res://Weapons/Melee_weapon.gd"
var rotation_direction=-1
# Called when the node enters the scene tree for the first time.
func _ready():
	weapon_scene=load("res://Weapons/Sword.tscn")
	weapon_path=get_path()
	#$Weapon_sprite.texture=$Weapon_sprite

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	$Weapon_sprite.flip_h=flip
	if animation:
		rotation_degrees+=atk_speed*rotation_direction
	if flip:
		rotation_direction=-1
	else:
		rotation_direction=1
	if rotation_direction*rotation_degrees>=180:
		rotation_degrees=180*rotation_direction
		atk_speed=-atk_speed
	if rotation_direction*rotation_degrees<=0:
		rotation_degrees=0*rotation_direction
		animation=false
		$Weapon_area.set_collision_layer_value(5,false)
		atk_speed=-atk_speed
