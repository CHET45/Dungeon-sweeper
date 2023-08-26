extends Node2D
@export var weapon_node:Node2D
@export var damage:int
@export var atk_speed:float
@export var weapon_path:String
@export var animation:bool=false
@export var flip:bool
var show_stats=false
var sc=0.003
var player
signal Player_entered
signal delete_weapon_from_scene

# Called when the node enters the scene tree for the first time.
func _ready():#+var_to_str(damage)+"\nAtack speed: "+var_to_str(atk_speed/10)
	set_weapon_path()
	Random_stats_generator()
	$Stats.text="Damage: "+var_to_str(damage)+"\nAtack speed: "+var_to_str(round(atk_speed))
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	weapon_atack_animation(delta)
	if show_stats:
		if Input.is_action_just_pressed("use"):
			player.call("Player_entered",get_node(".").duplicate(6), $Weapon_sprite)
			emit_signal("delete_weapon_from_scene",weapon_path)
		$Weapon_sprite.scale=Vector2(1.3,1.3)
		$Stats.visible=true
		$Stats.scale+=Vector2(sc,sc)
		if $Stats.scale.x>=1.1:
			sc=-sc
		if $Stats.scale.x<=0.9:
			sc=-sc
	else:
		$Stats.hide()
		$Stats.scale=Vector2(1,1)
		$Weapon_sprite.scale=Vector2(1,1)

func body_entered(body):
	if body.name=="Player":
		show_stats=true
		player=body

func body_exited(body):
	if body.name=="Player":
		show_stats=false

func weapon_animation():
	animation=true
	$Weapon_area.set_collision_layer_value(7,true)

func weapon_atack_animation(_delta):
	pass
func set_weapon_path():
	pass
func Random_stats_generator():
	var rng=RandomNumberGenerator.new()
	rng.randomize()
	damage=rng.randi_range(damage-5,damage+5)
	atk_speed=rng.randi_range(ceil(atk_speed-10),ceil(atk_speed+20))
