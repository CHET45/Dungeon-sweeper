extends "res://Weapons/Melee_weapon.gd"
var rotation_direction=1
var animation_part=1
var bullet_scene=load("res://Weapons/Bullet.tscn")
# Called when the node enters the scene tree for the first time.
func _ready():
	weapon_scene=load("res://Weapons/green_magic_staff.tscn")
	weapon_path=get_path()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	look_at(get_global_mouse_position())
	if (Input.is_action_just_pressed("Atack")):
		shoot()
	
	#rotation = get_global_mouse_position().angle_to_point(global_position)
	
	#var target_dir=(get_global_mouse_position()-global_position).normalized()
	#var current_dir=global_position.rotated(global_rotation)
	#global_rotation=current_dir.lerp(target_dir,20).angle()
	
	#if target_stop==false:
	#	Gun_rotation()
	#if target_dir.dot(current_dir)>0.9 and Gun_is and see_player:
	#	shoot()
	
	
func shoot():
	var bullet_instace=bullet_scene.instantiate()
	add_child(bullet_instace)
	move_child(bullet_instace,0)
	var v=get_child(0)
	v.velocity = v.position.direction_to(get_global_mouse_position()) * 10
	v.move_and_slide()
