extends Node2D
@export var weapon_scene:PackedScene
@export var damage:int
@export var atk_speed:float
@export var weapon_path:String
@export var animation:bool=false
@export var flip:bool
signal Player_entered
signal delete_weapon_from_scene

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func body_entered(body):
	if body.name=="Player":
		
		emit_signal("Player_entered",weapon_scene.instantiate(), $Weapon_sprite)
		emit_signal("delete_weapon_from_scene",weapon_path)
		#$Weapon_area.set_collision_mask_value(3,true)
		
func weapon_animation():
	animation=true
	$Weapon_area.set_collision_layer_value(5,true)
