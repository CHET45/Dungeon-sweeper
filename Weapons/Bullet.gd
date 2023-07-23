extends Area2D
@export var damage:int
@export var speed:int
var velocity=Vector2()

# Called when the node enters the scene tree for the first time.
func _ready():
	velocity=-position+get_global_mouse_position()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	position+=velocity.normalized()*500*delta
	
func body_entered(body):
	queue_free()
	
func weapon_animation():
	pass
