extends CharacterBody2D
@export var damage:int
@export var speed:int

# Called when the node enters the scene tree for the first time.
func _ready():
	#damage=get_parent().damage
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	move_and_slide()


func body_entered(body):
	queue_free()
	
func weapon_animation():
	pass
