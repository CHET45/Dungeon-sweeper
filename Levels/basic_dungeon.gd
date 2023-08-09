extends "res://Levels/Dungeon_generation.gd"

@onready var camera: Camera2D = $Camera2D
@onready var weapon_stock_obj=$CanvasLayer/Weapon_stock
var change_weapon_flag=true
var dor_mode_flag=false
var first=true
var weapon_list_obj
var child 
var child_number

func _ready():
	_setup_camera()
	weapon_list_obj=weapon_stock_obj.get_node("Weapon_list/Container")
	$CanvasLayer.visible=true
	weapon_stock_obj.visible=false
	_generate()

func _process(_delta):
	if Input.is_action_pressed("zoom+"):
		camera.zoom +=Vector2(0.01,0.01) 
	elif Input.is_action_pressed("zoom-") and camera.zoom>Vector2(0,0):
		camera.zoom-=Vector2(0.01,0.01) 
	if Input.is_action_just_pressed("re_generate"):
		get_tree().reload_current_scene()
	if Input.is_action_just_pressed("doors_updown"):
		_change_dors_mode(dor_mode_flag,$Player.position)
		dor_mode_flag=!dor_mode_flag
	if Input.is_action_just_pressed("Change_weapon") and change_weapon_flag:
		weapon_stock_obj.visible=true
		change_weapon_flag=false
	elif Input.is_action_just_pressed("Change_weapon") and !change_weapon_flag:
		weapon_stock_obj.visible=false
		change_weapon_flag=true
	if !change_weapon_flag and !first and $Player.can_flip_h:
		if Input.is_action_just_released("weapon_scroll_up"):
				child_number+=1
				if child_number>weapon_list_obj.get_child_count()-1:
					child_number=0
		if Input.is_action_just_released("weapon_scroll_down"):
			child_number-=1
			if child_number<0:
				child_number=weapon_list_obj.get_child_count()-1
		if child_number>=0 and child_number<=weapon_list_obj.get_child_count()-1:
			child = weapon_list_obj.get_child(child_number)
			child.emit_signal("weapon_button_pressed",child_number)
func _setup_camera() :
	camera.position = (level_size/2)*32
	camera.zoom = level_size/(level_size*7)

func delete_weapon_from_scene(weapon_path):
	get_node(weapon_path).queue_free()


func add_weapon_to_weapon_stock(weapon_texture):
	var wep_Button=weapon_list_obj.get_child(weapon_list_obj.get_child_count()-1)
	if first:
		first=false
		wep_Button.visible=true
	else:
		var dub=weapon_list_obj.get_node("Button").duplicate()
		weapon_list_obj.add_child(dub)
		wep_Button=weapon_list_obj.get_child(weapon_list_obj.get_child_count()-1)
		for n in wep_Button.get_children():
			wep_Button.remove_child(n)
			n.queue_free()
	wep_Button.add_child(weapon_texture.duplicate())
	var weapon_sprite=wep_Button.get_child(0)
	weapon_sprite.centered=true
	weapon_sprite.offset*=0
	weapon_sprite.position.y=wep_Button.size.y/2
	weapon_sprite.position.x=63
	weapon_sprite.rotate(-1.5708)
	weapon_sprite.scale*=2
	
	child_number=weapon_list_obj.get_child_count()-1
	child = weapon_list_obj.get_child(child_number)
	child.button_number=child_number


func shoot(bullet):
	add_child(bullet)


func weapon_button_pressed(_weapon_index):
	#chtobi menjalos pri nazatii na knopku
	#child_number=weapon_index
	pass
	#chtobi menjalos pri nazatii na knopku
	#child_number=weapon_index
	pass


func _on_creature_dead(creature:Node2D,room):
	enemies.get(room).erase(creature)
	remove_child(creature)
	creature.queue_free()
	if enemies.get(room).size()<=0:
		used_rooms[room]=true
		_change_dors_mode(true,room.position)

func _player_enters_room(body:Node2D):
	if body.name=="Player":
		var nearest_room= find_nearest_room(body.position)
		if !used_rooms.has(nearest_room):
			_change_dors_mode(false,nearest_room.position)
