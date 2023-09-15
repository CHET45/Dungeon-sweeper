extends "res://Enemies/Enemies.gd"
var angry_boom=false
var damage_for_boom:int
var HP:int
var rng =RandomNumberGenerator.new()
@onready var boom_area=$Angry_boom_damage/shape
@onready var collision=$Collision_for_everything
@onready var angry_light=$Angry_boom_light
var boom_shape:CircleShape2D
var coll_shape:CircleShape2D
func _ready():
	ready()
	HP=health
	rng.randomize()
	damage_for_boom=rng.randi_range(ceil(max_health/3.0),ceil(max_health/2.0))
	

func _process(_delta):
	call_deferred("process",_delta)
	if angry_boom:
		if angry_light.texture_scale<2:
			boom_area.disabled=false
			angry_light.energy+=0.2
			angry_light.texture_scale+=0.0015
			coll_shape.radius+=0.05
			boom_shape.radius+=0.1
			collision.shape=coll_shape
			boom_area.shape=boom_shape
			see_player=false
			if angry_light.texture_scale>=0.3:
				angry_light.texture_scale-=0.0002
				coll_shape.radius-=0.05
				boom_shape.radius-=0.1
				collision.shape=coll_shape
				boom_area.shape=boom_shape
				see_player=false
			if angry_light.texture_scale>=0.5:
				angry_light.energy+=0.5
				angry_light.texture_scale+=0.17
				coll_shape.radius+=3
				boom_shape.radius+=20
				collision.shape=coll_shape
				boom_area.shape=boom_shape
				see_player=false
		elif angry_light.texture_scale>=2:
			coll_shape.radius=10
			boom_shape.radius=10
			collision.shape=coll_shape 
			boom_area.shape=boom_shape
			angry_light.energy=0
			angry_light.texture_scale=0
			boom_area.disabled=true
			angry_boom=false
			see_player=true
			damage_for_boom=rng.randi_range(ceil(max_health/3.0),ceil(max_health/2.0))
	if angry_boom==false and HP-health>=damage_for_boom:
		_angry_boom()

func flip_enemy(direction):
	if direction<0:
		$animation.flip_h=true
		if $Release_damage.scale.x>0 and $Take_damage.scale.x>0:
			$Release_damage.scale.x=-$Release_damage.scale.x
			$Take_damage.scale.x=-$Take_damage.scale.x
	elif direction>0:
		$Release_damage.scale.x=abs($Release_damage.scale.x)
		$Take_damage.scale.x=abs($Take_damage.scale.x)
		$animation.flip_h=false
		
func _angry_boom():
	see_player=false
	HP=health
	angry_boom=true
	coll_shape=CircleShape2D.new()
	boom_shape=CircleShape2D.new()

func _on_angry_boom_damage_body_entered(body):
	body.call("Take_damage",damage)
	print(body.name)

func damage_the_player():
	if damage_player:
		emit_signal("hit_player",damage)
		Restore_hp(ceil(damage/2.0))


func set_default_stats():
	max_health=100
