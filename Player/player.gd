extends CharacterBody2D
@export var speed:int
@export var health:int
@export var max_health:int
signal health_change
signal dead
var second_life=false
var second_life_animation=1
var in_motion=false
var motion_flag=true
var damaged=false
var damage_cooldown_flag=true
var weapon:Node2D
var weapons={}
var weapon_count=-1
@export var can_flip_h=true
var room:Area2D

signal add_weapon_to_weapon_stock
# Called when the node enters the scene tree for the first time.
func _ready():
	health=max_health
	emit_signal("health_change",-(round(health-2)/2))
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if health>0:
		var input_direction = Input.get_vector("left", "right", "up", "down")
		velocity=input_direction*speed
		if can_flip_h:
			if velocity.x<0 :
				if $Man.flip_h==false:
					$Weapon_place.position.x=-$Weapon_place.position.x
				$Man.flip_h=true
			elif velocity.x>0:
				if $Man.flip_h==true:
					$Weapon_place.position.x=-$Weapon_place.position.x
				$Man.flip_h=false
		if $Damage_cooldown.time_left<=0.45 or !damaged :
			move_and_slide()
			simple_motion_animation()
				
		if Input.is_action_just_pressed("Atack") and weapon and weapon.animation==false:
			weapon.call("weapon_animation")
			#if weapon.has_method("shoort"):
			#	weapon.call("shoort")
			can_flip_h=false
		elif	weapon and weapon.animation==false:
			can_flip_h=true
		if weapon :
			weapon.flip=$Man.flip_h
			weapon.position=$Weapon_place.position
	elif !second_life and second_life_animation>=1:
			if rotation_degrees>=0 and second_life_animation==1:
				rotation_degrees=-90
				damaged=true
				if weapon:
					weapon.hide()
				$CollisionShape2D.disabled=true
				#$Second_life/Shape.disabled=false
				second_life_animation=2
			elif rotation_degrees<=0 and second_life_animation==2:
				rotation_degrees+=1
				$Player_light.energy+=0.11
				#$Second_life/Shape.shape.radius+=5
				$Player_light.texture_scale+=0.01
			if rotation_degrees>=-45 and second_life_animation==2 and rotation_degrees<0:
				rotation_degrees+=1
				$Player_light.energy+=0.21
				#$Second_life/Shape.shape.radius+=5
				$Player_light.texture_scale+=0.05
			if rotation_degrees>=0 and second_life_animation==2:
				$Player_light.energy=0.1
				$Player_light.texture_scale=0.5
				#$Second_life/Shape.shape.radius=1
				#$Second_life/Shape.disabled=true
				second_life_animation=-1
				rotation_degrees=0
				damaged=false
	elif !second_life and second_life_animation==-1:
		var mouse_pos=get_global_mouse_position()
		$Man.global_position=mouse_pos
		if room.position.distance_squared_to(mouse_pos)<200000:
			$Man.set_modulate(Color("ffffff"))
			if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
				$Man.position*=0
				position=mouse_pos
				@warning_ignore("integer_division")
				Restore_hp(max_health)
				second_life=true
				Take_damage(0)
				await get_tree().physics_frame
				$CollisionShape2D.disabled=false
				if weapon:
					weapon.visible=true
		else:
			$Man.set_modulate(Color("67676781"))
	else:
		emit_signal("dead", get_node("."),null)
	
func simple_motion_animation():
	if (Input.is_action_pressed("down") or 
		Input.is_action_pressed("up") or 
		Input.is_action_pressed("left") or 
		Input.is_action_pressed("right")):
			in_motion=true
	else:
		in_motion=false
		$Man/Timer.stop()
		$Man.frame=4
		motion_flag=true
	if in_motion and motion_flag:
		motion_flag=false
		$Man.Man_animation()

func Take_damage(damage):
	damaged=true
	set_collision_layer_value(2,false)
	if damage_cooldown_flag:
		$Damage_cooldown.start()
		damage_cooldown_flag=false
		speed+=25
		health-=damage
		emit_signal("health_change",damage)
		$AnimationPlayer.play("Damaged")

func damage_cooldown_timeout():
	set_collision_layer_value(2,true)
	damage_cooldown_flag=true
	speed-=25
	damaged=false
	$Damage_cooldown.stop()

func Player_entered(weapon_instance,weapon_texture):
	call_deferred("Player_entered_deferred",weapon_instance,weapon_texture)
func Player_entered_deferred(weapon_instance,weapon_texture):
	if weapon_count>-1:
		weapon.hide()
	weapon_count+=1
	add_child(weapon_instance)
	weapons[weapon_count]=weapon_instance
	weapon=weapon_instance
	emit_signal("add_weapon_to_weapon_stock",weapon_texture,weapon.damage,weapon.atk_speed)
	weapon.flip=$Man.flip_h
	weapon.position=$Weapon_place.position
	
func weapon_button_pressed(weapon_index):
	weapon.hide()
	weapon=weapons.get(weapon_index)
	weapon.visible=true

func Restore_hp(HP):
	if health+HP<=max_health:
		health+=HP
		emit_signal("health_change",-HP)
	elif health+HP>max_health:
		emit_signal("health_change",-(max_health-health))
		health=max_health

func has_weapon(new_weapon:Node2D):
	return weapons.has(new_weapon)
