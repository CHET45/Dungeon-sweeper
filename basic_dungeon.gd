extends Node2D


@export var level_size = Vector2(100, 100)
@export var rooms_size = Vector2(15, 25)
@export var rooms_max = 7
var data = {}
var children=[]
var rooms=[]
var dors=[]
@onready var level: TileMap = $Level
@onready var camera: Camera2D = $Camera2D
@onready var weapon_stock_obj=$CanvasLayer/Weapon_stock
var change_weapon_flag=true
var first=true
var weapon_list_obj
var child 
var child_number

func _ready():
	_setup_camera()
	weapon_list_obj=weapon_stock_obj.get_node("Weapon_list/Container")
	$CanvasLayer.visible=true
	weapon_stock_obj.visible=false

func _process(_delta):
	
	if Input.is_action_pressed("zoom+"):
		camera.zoom +=Vector2(0.01,0.01) 
	elif Input.is_action_pressed("zoom-") and camera.zoom>Vector2(0,0):
		camera.zoom-=Vector2(0.01,0.01) 
	if Input.is_action_just_pressed("re_generate"):
		call_deferred("_generate")
	if Input.is_action_just_pressed("doors_updown"):
		#get_tree().paused=true
		_change_dors_mode()
		#get_tree().paused=false
	if Input.is_action_just_pressed("Change_weapon") and change_weapon_flag:
		weapon_stock_obj.visible=true
		change_weapon_flag=false
	elif Input.is_action_just_pressed("Change_weapon") and !change_weapon_flag:
		weapon_stock_obj.visible=false
		change_weapon_flag=true
	if !change_weapon_flag and !first and $Player.can_flip_h:
		if Input.is_action_just_released("weapon_scroll_up"):
				print("up")
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
	camera.position = level.map_to_local(level_size / 2)
	var z = max(level_size.x, level_size.y) / (4.5*level_size.x)
	camera.zoom = Vector2(z, z)

func _generate():
	rooms = []
	var rng = RandomNumberGenerator.new()
	while rooms.size()<6:
		for child_enemy in children:
			child_enemy.queue_free()
		$Player.position=Vector2(0,0)
		level.clear()
		data={}
		children=[]
		rooms = []
		dors=[]
		_generate_data(rng)
	_add_connections(rng)
	_add_dors()
	_fill_level()
	
func _fill_level():
	for point in data:
		if data.get(point)==1 or data.get(point)==2:
			level.set_cell(0,point,0,Vector2(12,4))
		elif data.get(Vector2(point))==3:
			if data.get(point-Vector2(0,1))!=3:
				level.set_cell(1,point-Vector2(0,1),0,Vector2(46,6))
			if data.get(point+Vector2(0,1))!=3:
				level.set_cell(1,point+Vector2(0,1),0,Vector2(50,4))
			level.set_cell(1,point,0,Vector2(30,4))

func _generate_data(rng:RandomNumberGenerator):
	rng.randomize()

	for r in range(rooms_max):
		var room = _get_random_room(rng)
		if _intersects(room):
			continue

		_add_room(room)
		_add_monsters(rng,room)

func _get_random_room(rng: RandomNumberGenerator) :
	var width = rng.randi_range(rooms_size.x, rooms_size.y)
	var height = rng.randi_range(rooms_size.x, rooms_size.y)
	var x = rng.randi_range(2, level_size.x - width - 2)
	var y = rng.randi_range(2, level_size.y - height - 2)
	return Rect2(x, y, width, height)

func _add_room( room: Rect2):
	rooms.push_back(room)
	for x in range(room.position.x, room.end.x):
		for y in range(room.position.y, room.end.y):
			data[Vector2(x, y)] = 1

func _add_dors():
	var all_dors={}
	_add_all_dors(all_dors)
	_choose_best_dors(all_dors)

func _add_all_dors(all_dors:Dictionary):
	for x in level_size.x:
		for y in level_size.y:
			if data.get(Vector2(x,y))==2:
				var maybedor=[]
				var hororver#dor is horizontal or vertical
				if data.get(Vector2(x-1,y))==null:
					for cell in range(7):
						if data.get(Vector2(x+cell,y))==2 and cell>=6:
							maybedor=[]
						elif data.get(Vector2(x+cell,y))==2:
							maybedor.push_back(Vector2(x+cell,y))
						elif data.get(Vector2(x+cell,y))==null:
							break
						else:
							maybedor=[]
							break
						hororver=0
				elif data.get(Vector2(x,y-1))==null:
					for cell in range(7):
						if data.get(Vector2(x,y+cell))==2 and cell>=6:
							maybedor=[]
						elif data.get(Vector2(x,y+cell))==2:
							maybedor.push_back(Vector2(x,y+cell))
						elif data.get(Vector2(x,y+cell))==null:
							break
						else:
							maybedor=[]
							break
						hororver=1
				elif data.get(Vector2(x+1,y))==null:
					for cell in range(7):
						if data.get(Vector2(x-cell,y))==2 and cell>=6:
							maybedor=[]
						elif data.get(Vector2(x-cell,y))==2:
							maybedor.push_back(Vector2(x-cell,y))
						elif data.get(Vector2(x-cell,y))==null:
							break
						else:
							maybedor=[]
							break
						hororver=0
				elif data.get(Vector2(x,y+1))==null:
					for cell in range(7):
						if data.get(Vector2(x,y-cell))==2 and cell>=6:
							maybedor=[]
						elif data.get(Vector2(x,y-cell))==2:
							maybedor.push_back(Vector2(x,y-cell))
						elif data.get(Vector2(x,y-cell))==null:
							break
						else:
							maybedor=[]
							break
						hororver=1
				if maybedor:
					var linedor=$Line2D.duplicate()
					for point in maybedor:
						data[point]=3
						linedor.add_point(point)
					all_dors[linedor]=hororver
			elif data.get(Vector2(x,y))==null:
				level.set_cell(0,Vector2(x,y),0,Vector2(36,6))

func _choose_best_dors(all_dors:Dictionary):
	for dor in all_dors:
		var cell=0
		var twosides=0
		var x=dor.get_point_position(round(dor.get_point_count()/2)).x
		var y=dor.get_point_position(round(dor.get_point_count()/2)).y
		if all_dors[dor]:
			while twosides<3:
				cell+=1
				if data.get(Vector2(x-cell,y))==1 and twosides%2==0:
					break
				elif data.get(Vector2(x-cell,y))!=2 and twosides%2==0:
					twosides+=1
				if data.get(Vector2(x+cell,y))==1 and twosides<=1:
					break
				elif data.get(Vector2(x+cell,y))!=2 and twosides<=1:
					twosides+=2
		else:
			while twosides<3:
				cell+=1
				if data.get(Vector2(x,y-cell))==1 and twosides%2==0:
					break
				elif data.get(Vector2(x,y-cell))!=2 and twosides%2==0:
					twosides+=1
				if data.get(Vector2(x,y+cell))==1 and twosides<=1:
					break
				elif data.get(Vector2(x,y+cell))!=2 and twosides<=1:
					twosides+=2
		if twosides>=3:
			for pt in dor.get_point_count():
				data[dor.get_point_position(pt)]=2
		else:
			dors.push_back(dor)
	all_dors.clear()

func _change_dors_mode():
	if level.get_cell_atlas_coords(1,data.find_key(3))==Vector2i(30,4):
		for dor in dors:
			for pt in dor.get_point_count():
				if data.get(dor.get_point_position(pt)-Vector2(0,1))!=3:
					#level.set_cell(0,Vector2(x,y-1),0,Vector2(12,4))
					level.set_cell(1,dor.get_point_position(pt)-Vector2(0,1),0,Vector2(2,5))
				if data.get(dor.get_point_position(pt)+Vector2(0,1))!=3:
					level.set_cell(1,dor.get_point_position(pt)+Vector2(0,1),0,Vector2(24,6))
					#level.set_cell(1,Vector2(x,y+1),0,Vector2(2,5))
				level.set_cell(0,dor.get_point_position(pt),0,Vector2(12,4))
				level.set_cell(1,dor.get_point_position(pt),0,Vector2(2,5))
	else:
		for dor in dors:
			for pt in dor.get_point_count():
				if data.get(dor.get_point_position(pt)-Vector2(0,1))!=3:
					#level.set_cell(0,Vector2(x,y-1),0,Vector2(12,4))
					level.set_cell(1,dor.get_point_position(pt)-Vector2(0,1),0,Vector2(46,6))
				if data.get(dor.get_point_position(pt)+Vector2(0,1))!=3:
					level.set_cell(1,dor.get_point_position(pt)+Vector2(0,1),0,Vector2(50,4))
					#level.set_cell(1,Vector2(x,y+1),0,Vector2(2,5))
				level.set_cell(1,dor.get_point_position(pt),0,Vector2(30,4))

func _add_monsters(rng:RandomNumberGenerator, room:Rect2):
	if $Player.position!=Vector2(0,0):
		for en in rng.randi_range(1,2):
			var child_enemy=get_node("Red_monster").duplicate()
			children.push_back(child_enemy)
			add_child(child_enemy)
			child_enemy.position=room.get_center()*32+Vector2(rng.randi_range(-150,150),rng.randi_range(-150,150))
			child_enemy.visible=true
	else:
		$Player.position=room.get_center()*32

func _add_connections(rng: RandomNumberGenerator):
	var k=1
	for room in rooms:
		var distace=9999999
		var nearest_room:Rect2
		for room2_index in range(k, rooms.size()):
			if distace>room.get_center().distance_squared_to(rooms[room2_index].get_center()):
				distace=room.get_center().distance_squared_to(rooms[room2_index].get_center())
				nearest_room=rooms[room2_index]
		k+=1
		if nearest_room:
			var room_center1 = room.get_center()
			var room_center2 = nearest_room.get_center()
			if !rng.randi_range(0, 1):
				_add_corridor(room_center1.x, room_center2.x, room_center1.y, Vector2.AXIS_X)#Exit horizontal
				_add_corridor(room_center1.y, room_center2.y, room_center2.x, Vector2.AXIS_Y)#Enter vertical
			else:
				_add_corridor(room_center1.y, room_center2.y, room_center1.x, Vector2.AXIS_Y)#Exit vertical
				_add_corridor(room_center1.x, room_center2.x, room_center2.y, Vector2.AXIS_X)#Enter horizontal


func _add_corridor( start: int, end: int, constant: int, axis: int) :
	for cor_length in 3:
		for t in range(min(start, end), max(start, end) + cor_length+1):
			var point = Vector2.ZERO
			match axis:
				Vector2.AXIS_X: point = Vector2(t, constant+cor_length)
				Vector2.AXIS_Y: point = Vector2(constant+cor_length, t)
			if data.get(point)!=1:
				data[point] = 2

func _intersects(room: Rect2):
	var out = false
	for room_other in rooms:
		if room.intersects(room_other, true):
			out = true
			break
	return out

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
