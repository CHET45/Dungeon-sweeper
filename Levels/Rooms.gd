extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready():
	body_entered.connect(body)
	print(2)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):	
	print(1)

func body(h:Node2D):
	print(h)
