extends "res://Enemies/Enemies.gd"
var angry_boom=false
var rng =RandomNumberGenerator.new()
@onready var boom_area=$Angry_boom_damage/shape
@onready var collision=$Collision_for_everything
@onready var angry_light=$Angry_boom_light
@onready var boom_timer=$Angry_boom_timer
func _ready():
	ready()	
	rng.randomize()
	

func _process(_delta):
	call_deferred("process",_delta)
	if angry_boom and see_player and navigation_agent.is_target_reachable():
		if angry_light.texture_scale<4:
			boom_area.disabled=false
			angry_light.energy+=0.1
			angry_light.texture_scale+=0.05
			collision.shape.radius+=0.2
			boom_area.shape.radius+=0.2
		if angry_light.texture_scale>=1:
			angry_light.energy+=1
			angry_light.texture_scale+=0.1
			collision.shape.radius+=3
			boom_area.shape.radius+=10
		if angry_light.texture_scale>=2:
			angry_light.energy=100
			collision.shape.radius=18
			angry_light.energy=0
			angry_light.texture_scale=0
			boom_area.disabled=true
			boom_area.shape.radius=0
			angry_boom=false
			atack=false
	if see_player and !angry_boom and boom_timer.is_stopped():
		boom_timer.start(rng.randi_range(5,20))
			
	


func _on_angry_boom_timeout():
	boom_timer.start(rng.randi_range(5,20))
	atack=true
	angry_boom=true


func _on_angry_boom_damage_body_entered(body):
	if body.name=="Player":
		body.call("Take_damage",damage)

func set_default_stats():
	max_health=100
