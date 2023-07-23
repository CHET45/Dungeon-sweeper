extends Node2D
@export var HP_regen:int
var animation=false
var sc=0.003
var player

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	$Regen_view.text=var_to_str(HP_regen)
	if animation:
		if Input.is_action_just_pressed("use"):
			if player.health<player.max_health:
				player.call("Restore_hp",HP_regen)
				queue_free()
		scale=Vector2(1.3,1.3)
		$Regen_view.visible=true
		$Regen_view.scale+=Vector2(sc,sc)
		if $Regen_view.scale.x>=1.1:
			sc=-sc
		if $Regen_view.scale.x<=0.9:
			sc=-sc
	else:
		$Regen_view.hide()
		$Regen_view.scale=Vector2(1,1)
		scale=Vector2(1,1)


func _on_area_2d_body_entered(body):
	if body.name=="Player":
		animation=true
		player=body

func _on_area_2d_body_exited(body):
	if body.name=="Player":
		animation=false
