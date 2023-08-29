extends "res://Levels/Dungeon_generation.gd"

@onready var camera: Camera2D=$Camera2D
@onready var weapon_stock_obj=$CanvasLayer/Weapon_stock
@onready var LoadingProgress=$CanvasLayer/Loading_screen/LoadingBar
@onready var LoadingState=$CanvasLayer/Loading_screen/LoadingState
@onready var Stats=$CanvasLayer/Weapon_stock/Weapon_list/Container/Button/Stats
@onready var regen_botle=$Regen
var change_weapon_flag=true
var dor_mode_flag=false
var first=true
var weapon_list_obj
var child 
var child_number
var all_weapons=[]
var weapons_in_room=[]
var rng=RandomNumberGenerator.new()

func _ready():
	all_weapons=get_tree().get_nodes_in_group("weapons")
	weapon_list_obj=weapon_stock_obj.get_node("Weapon_list/Container")
	$CanvasLayer.visible=true
	weapon_stock_obj.visible=false
	_setup_camera()
	_generate()
	if rendering_mode=="debug":
		_fill_level(null)

func _process(_delta):
	load_map(generation_progress,state_progress)
	if generation_progress=="done":
		LoadingProgress.get_parent().hide()
		minimap.avatar_movement($Player.position)
		if Input.is_action_just_pressed("c"):
			camera.enabled=!camera.enabled
		if Input.is_action_just_pressed("1"):
			rendering_mode="standart"
			call_deferred("_fill_level",null)
		if Input.is_action_just_pressed("3"):
			rendering_mode="debug"
			call_deferred("_fill_level",null)
	if rendering_mode=="standart":
		call_deferred("_fill_level",null)
	if Input.is_action_pressed("zoom+"):
		camera.zoom +=Vector2(0.01,0.01) 
	elif Input.is_action_pressed("zoom-") and camera.zoom>Vector2(0,0):
		camera.zoom-=Vector2(0.01,0.01) 
	if Input.is_action_just_pressed("re_generate"):
		get_tree().reload_current_scene()
	#if Input.is_action_just_pressed("doors_updown"):
	#	_change_dors_mode(dor_mode_flag,null)
	#	dor_mode_flag=!dor_mode_flag
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
	if level_size:
		camera.position = level_size*16
		camera.zoom = level_size/(level_size*7)

func delete_weapon_from_scene(weapon_path):
	await get_tree().physics_frame
	remove_child(get_node(weapon_path))


func add_weapon_to_weapon_stock(weapon_texture,damage,atack_speed):
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
	var weapon_sprite=weapon_texture.duplicate()
	var weapon_stats=Stats.duplicate()
	wep_Button.add_child(weapon_stats)
	wep_Button.add_child(weapon_sprite)
	weapon_sprite.centered=true
	weapon_sprite.offset*=0
	weapon_sprite.position.y=wep_Button.size.y/2
	weapon_sprite.position.x=63
	weapon_sprite.rotate(-1.5708)
	weapon_sprite.scale*=1.5	
	weapon_stats.text="a.s.:	"+var_to_str(atack_speed)+"\nd.:	"+var_to_str(damage)
	
	child_number=weapon_list_obj.get_child_count()-1
	child = weapon_list_obj.get_child(child_number)
	child.button_number=child_number


func shoot(bullet):
	add_child(bullet)


func weapon_button_pressed(weapon_index):
	child_number=weapon_index


func _on_creature_dead(creature:Node2D,room:Area2D):
	if rng.randi_range(1,4)>2:
		if regen_botle.get_parent():
			regen_botle=regen_botle.duplicate()
		add_child(regen_botle)
		regen_botle.position=creature.position
	if room:
		enemies.get(room).erase(creature)
		remove_child(creature)
		creature.queue_free()
		if enemies.get(room).size()<=0:
			room_sweeped(room,false)
	else:
		get_tree().reload_current_scene()

func _player_enters_room(body:Node2D):
	if body.name=="Player":
		var nearest_room= find_nearest_room(body.position)
		if !sweeped_rooms.has(nearest_room):
			activate_room(nearest_room)

func spawn_weapons(room:Area2D,first_room:bool):
	rng.randomize()
	var weapon_count
	if first_room:
		weapon_count=rng.randi_range(3,6)
	else:
		weapon_count=rng.randi_range(1,4)
	for x in range(0,weapon_count):
		var weapon=all_weapons[rng.randi_range(0,all_weapons.size()-1)]
		if weapon.get_parent():
			var new_weapon=weapon.duplicate()
			new_weapon.set_default_stats()
			weapon=new_weapon
		add_child(weapon)
		weapons_in_room.push_back(weapon)
			
		weapon.position=Vector2(room.position.x+75-x*50,room.position.y)

func activate_room(room:Area2D):
	if rendering_mode!="debug":
		rendering_mode="fight"
	for enemy in enemies.get(room):
		enemy.see_player=true
	
	$Player.room=room
	minimap.visible=false
	_fill_level(room)
	_change_dors_mode(false,room)

func room_sweeped(room:Area2D, first_room:bool):
	if rendering_mode!="debug":
		rendering_mode="standart"
	minimap.visible=true
	sweeped_rooms[room]=true
	minimap.sweeped_room(room)
	spawn_weapons(room,first_room)
	_change_dors_mode(true,room)

func load_map(state,progress):
	LoadingProgress.value=progress
	LoadingState.text=state


func change_weapon_by_button(number):
	child_number=number
