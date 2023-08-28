extends "res://Enemies/Enemies.gd"
var angry_boom=false
var rng =RandomNumberGenerator.new()
func _ready():
	ready()	
	rng.randomize()
	

func _process(_delta):
	call_deferred("process",_delta)
	if angry_boom and see_player and navigation_agent.is_target_reachable():
		if $Angry_boom_light.texture_scale<2:
			$Angry_boom_damage/shape.disabled=false
			$Angry_boom_light.energy+=0.1
			$Angry_boom_light.texture_scale+=0.005
			$Cillision_for_everything.shape.radius+=0.2
			$Angry_boom_damage/shape.shape.radius+=0.2
		if $Angry_boom_light.texture_scale>=1:
			$Angry_boom_light.energy+=1
			$Angry_boom_light.texture_scale+=0.1
			$Cillision_for_everything.shape.radius+=3
			$Angry_boom_damage/shape.shape.radius+=10
		if $Angry_boom_light.texture_scale>=2:
			$Angry_boom_light.energy=100
			$Cillision_for_everything.shape.radius=18
			$Angry_boom_light.energy=0
			$Angry_boom_light.texture_scale=0
			$Angry_boom_damage/shape.disabled=true
			$Angry_boom_damage/shape.shape.radius=0
			angry_boom=false
			atack=false
	if see_player and !angry_boom and $Angry_boom.is_stopped():
		$Angry_boom.start(rng.randi_range(5,20))
			
	


func _on_angry_boom_timeout():
	$Angry_boom.start(rng.randi_range(5,20))
	atack=true
	angry_boom=true


func _on_angry_boom_damage_body_entered(body):
	if body.name=="Player":
		body.call("Take_damage",damage)
