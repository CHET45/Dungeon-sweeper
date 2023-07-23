extends Control
var child_count=0
var changeable_hp=0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func HP_plus(how_much):
	for n in how_much:
		if get_child(changeable_hp) and get_child(changeable_hp).frame<2 or changeable_hp<child_count:
			restore_HP()
		else:
			var dub=$HP.duplicate()
			add_child(dub)	
			child_count+=1
			changeable_hp=child_count
			dub.position.x+=24*child_count*scale.x
func set_HP(how_much):
	for n in how_much:
		if get_child(changeable_hp):
			var child=get_child(changeable_hp)
			if child.frame>0:
				child.frame-=1
			if child.frame==0 and changeable_hp>0:
				changeable_hp-=1
func restore_HP():
	if get_child(changeable_hp):
		var child=get_child(changeable_hp)
		if child.frame<2:
			child.frame+=1
		if child.frame==2 and changeable_hp+1<=child_count:
			changeable_hp+=1

func player_health_change(health):
	if health>0:
		set_HP(health)
	else:
		HP_plus(-health)
