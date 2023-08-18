extends Node2D
@export var weapon_node:Node2D
@export var damage:int
@export var atk_speed:float
@export var weapon_path:String
@export var animation:bool=false
@export var flip:bool
signal Player_entered
signal delete_weapon_from_scene

# Called when the node enters the scene tree for the first time.
func _ready():
	Random_stats_generator()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func body_entered(body):
	if body.name=="Player":
		print("Player entered")
		body.call("Player_entered",get_node(".").duplicate(6), $Weapon_sprite)
		emit_signal("delete_weapon_from_scene",weapon_path)
		
func weapon_animation():
	animation=true
	$Weapon_area.set_collision_layer_value(7,true)

func Random_stats_generator():
	var rng=RandomNumberGenerator.new()
	rng.randomize()
	damage=rng.randi_range(damage-5,damage+5)
	atk_speed=rng.randf_range(atk_speed-100,atk_speed+100)
