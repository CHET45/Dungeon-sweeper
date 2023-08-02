extends CharacterBody2D
@export var movement_speed: float
var speed
@export var health:int
@export var max_health:int
@export var damage:int
@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D
var next_path_position: Vector2
var in_motion=false
var motion_flag=true
var damaged=false
var damage_cooldown_flag=true
var RGB=1
var RGB_flag=true
@export var atack=false
@export var atack_flag=true
var damage_player=true
signal hit_player
@export var see_player=false
func _ready():
	speed=movement_speed
	health=max_health
	$HP.max_value=max_health
	navigation_agent.path_desired_distance = 4.0
	navigation_agent.target_desired_distance = 4.0

	# Make sure to not await during _ready.
	call_deferred("actor_setup")

func actor_setup():
	# Wait for the first physics frame so the NavigationServer can sync.
	await get_tree().physics_frame
	set_movement_target(get_parent().get_node("Player").global_position)
	$Player_radar.monitoring=true

func set_movement_target(target_to_move: Vector2):
	navigation_agent.target_position = target_to_move

func _process(_delta):	
	if health>0:
		if see_player:
			set_movement_target(get_parent().get_node("Player").global_position)
			movement_speed=speed
		else:
			set_movement_target(position)
			speed=movement_speed
			movement_speed=0
		$HP.value=health
		var current_agent_position: Vector2 = global_position
		next_path_position= navigation_agent.get_next_path_position()
	
		var new_velocity: Vector2 = next_path_position - current_agent_position
		new_velocity = new_velocity.normalized()
		new_velocity = new_velocity * movement_speed
	
		velocity = new_velocity
		if velocity.x<0:
			$animation.flip_h=true
		elif velocity.x>0:
			$animation.flip_h=false
		if !navigation_agent.is_navigation_finished() and !atack:
			$animation/atack_timer.stop()
			if !damaged or $Damage_cooldown.time_left<=0.1:
				move_and_slide()
				in_motion=true
		else:
			in_motion=false
			$animation/Timer.stop()
			motion_flag=true
		if damaged:
			Damage_animation()
		if in_motion and motion_flag:
			motion_flag=false
			$animation.enemy_animation()
		
	else:
		queue_free()

func body_entered(body):
	if body.name=="Player":
		if atack_flag:
			atack=true
			atack_flag=false
			damage_player=true
			$animation.frame_pos=0
			$animation.enemy_atack_animation()
func body_exited(body):
	if body.name=="Player":
		damage_player=false
func damage_the_player():
	if damage_player:
		emit_signal("hit_player",damage)
func weapon_entered(area):
	var object=area.get_parent()
	if object.has_method("weapon_animation") :
		damaged=true
		if damage_cooldown_flag:
			damage_cooldown_flag=false
			health-=object.damage
			$Damage_cooldown.start()
func Damage_cooldown_timeout():
	damaged=false
	damage_cooldown_flag=true
	$animation.modulate=Color(1,1,1)
func Damage_animation():
	$animation.modulate=Color(RGB,RGB,RGB)
	if RGB_flag and RGB<=2:
		RGB+=1
	elif RGB>=1:
		RGB_flag=false
		RGB-=1
	else:
		RGB_flag=true


func _on_player_radar_body_entered(body):
	if body.name=="Player":
		see_player=true
		$Player_radar/CollisionShape2D.scale*=3.5

func _on_player_radar_body_exited(body):
	if body.name=="Player":
		$Player_radar/CollisionShape2D.scale/=3.5
		see_player=false
