extends "res://Weapons/Melee_weapon.gd"
var rotation_direction=1
var animation_part=1
var bullet_scene=load("res://Weapons/Bullet.tscn")
signal shoot
var bullet_instace
# Called when the node enters the scene tree for the first time.
func _ready():
	weapon_scene=load("res://Weapons/green_magic_staff.tscn")
	weapon_path=get_path()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	bullet_instace=bullet_scene.instantiate()
	bullet_instace.global_transform=$Aim.global_transform
	if get_parent().name=="Player":
		look_at(get_global_mouse_position())
	#rotation = get_global_mouse_position().angle_to_point(global_position)
	
	#var target_dir=(get_global_mouse_position()-global_position).normalized()
	#var current_dir=global_position.rotated(global_rotation)
	#global_rotation=current_dir.lerp(target_dir,20).angle()
	
	#if target_stop==false:
	#	Gun_rotation()
	#if target_dir.dot(current_dir)>0.9 and Gun_is and see_player:
	#	shoot()
func shoort():
	print(name)
	emit_signal("shoot",bullet_instace)
