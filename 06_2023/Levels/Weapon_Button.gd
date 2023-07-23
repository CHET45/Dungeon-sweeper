extends Button
signal weapon_button_pressed
@export var button_number:int

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_button_down():
	emit_signal("weapon_button_pressed",button_number)
