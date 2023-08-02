extends Node2D
@export var level_size=Vector2(100,100) 
@export var rooms_size=Vector2(10,14)#x-room size min; y-room size max
@export var rooms_max=14
var data = {}
var children=[]
var rooms=[]
var dors=[]
var all_dor_cells={}
@onready var level: TileMap = $level
@onready var camera: Camera2D = $Camera2D
var red_monster:PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	red_monster=load("res://Enemies/Red_monster.tscn")
	setup_camera()
	generate()
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func setup_camera():
	camera.position = level.map_to_local(level_size / 2)
	var z = max(level_size.x, level_size.y) / 450
	camera.zoom = Vector2(z, z)

func generate():
	level.clear()
	data = {}
	for child_enemy in children:
		child_enemy.queue_free()
	children=[]
	dors=[]
	rooms=[]
	all_dor_cells={}
	generate_data()
	_add_dors()
	_fill_level()

func _fill_level():
	for x in level_size.x:
		for y in level_size.y:
			if data.get(Vector2(x,y))==1:
				level.set_cell(0,Vector2(x,y),0,Vector2(12,4))
			elif data.get(Vector2(x,y))==null:
				level.set_cell(0,Vector2(x,y),0,Vector2(36,6))
			elif data.get(Vector2(x,y))==2:
				if data.get(Vector2(x,y-1))!=2:
					level.set_cell(1,Vector2(x,y-1),0,Vector2(46,6))
				if data.get(Vector2(x,y+1))!=2:
					level.set_cell(1,Vector2(x,y+1),0,Vector2(50,4))
				level.set_cell(1,Vector2(x,y),0,Vector2(30,4))

func generate_data():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	for r in range(rooms_max):
		var room = _get_random_room(rng)
		if _intersects(room):
			continue
			
		_add_room(room)
		_add_monsters(rng,room)
		if rooms.size() > 1:
			var room_previous: Rect2 = rooms[-2]
			_add_connection(rng,room_previous, room)
	if rooms.size()<10:
		generate()

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

func _add_connection(rng: RandomNumberGenerator, room1: Rect2, room2: Rect2):
	var room_center1 = room1.get_center()
	var room_center2 = room2.get_center()
	if rng.randi_range(0, 1) == 0:
		_add_corridor(room_center1.x, room_center2.x, room_center1.y, Vector2.AXIS_X)#Exit horizontal
		_add_corridor(room_center1.y, room_center2.y, room_center2.x, Vector2.AXIS_Y)#Enter vertical
	else:
		_add_corridor(room_center1.y, room_center2.y, room_center1.x, Vector2.AXIS_Y)#Exit vertical
		_add_corridor(room_center1.x, room_center2.x, room_center2.y, Vector2.AXIS_X)#Enter horizontal

func _add_corridor( start: int, end: int, constant: int, axis: int) :
	for cor_length in 3:
		for t in range(min(start, end), max(start, end) + cor_length):
			var point = Vector2.ZERO
			match axis:
				Vector2.AXIS_X: point = Vector2(t, constant+cor_length-1)
				Vector2.AXIS_Y: point = Vector2(constant+cor_length-1, t)
			data[point] = 1

func _add_dors():
	_add_dor_cells()
	for point in all_dor_cells:
		if !dor_has_point(point):
			dor_maker(point)

func dor_has_point(point:Vector2):
	var point_already_used=false
	for dor in dors:
		for pt in dor.get_point_count():
			if dor.get_point_position(pt)==point:
				point_already_used=true
				break
	return point_already_used

func dor_maker(point:Vector2):
	var dor_cells=[]
	dor_from_cells(point,dor_cells,0)
	var dor=$Line2D
	for pt in dor_cells:
		dor.add_point(pt)
	dors.push_back(dor)

func dor_from_cells(point:Vector2, dor_cells:Array, indx:int):
	var dor_points_exist=true
	while dor_points_exist:
		if data.get(point-Vector2(1,0))==2:
			var point_already_used=false
			for pt in dor_cells:
				if point-Vector2(1,0)==pt:
					point_already_used=true
					break
			if !point_already_used:
				dor_cells.push_back(point-Vector2(1,0))
		elif data.get(point-Vector2(0,1))==2:
			var point_already_used=false
			for pt in dor_cells:
				if point-Vector2(0,1)==pt:
					point_already_used=true
					break
			if !point_already_used:
				dor_cells.push_back(point-Vector2(0,1))
		elif data.get(point+Vector2(1,0))==2:
			var point_already_used=false
			for pt in dor_cells:
				if point+Vector2(1,0)==pt:
					point_already_used=true
					break
			if !point_already_used:
				dor_cells.push_back(point+Vector2(1,0))
		elif data.get(point+Vector2(0,1))==2:
			var point_already_used=false
			for pt in dor_cells:
				if point+Vector2(0,1)==pt:
					point_already_used=true
					break
			if !point_already_used:
				dor_cells.push_back(point+Vector2(0,1))
		if dor_cells.size()>1 and dor_cells[indx+1]:
			indx+=1
			point=dor_cells[indx]
		else:
			dor_points_exist=false

func _add_dor_cells():
	for x in level_size.x:
		for y in level_size.y:
			if data.get(Vector2(x,y))==1:
				var point_in_room=false
				for room in rooms:
					if room.has_point(Vector2(x,y)):
						point_in_room=true
						break
				if !point_in_room:
					var near_point_in_room=false
					for room in rooms:
						if room.has_point(Vector2(x-1,y)):
							near_point_in_room=true
						elif room.has_point(Vector2(x,y-1)):
							near_point_in_room=true
						elif room.has_point(Vector2(x+1,y)):
							near_point_in_room=true
						elif room.has_point(Vector2(x,y+1)):
							near_point_in_room=true
						elif room.has_point(Vector2(x-1,y-1)):
							near_point_in_room=true
						elif room.has_point(Vector2(x+1,y-1)):
							near_point_in_room=true
						elif room.has_point(Vector2(x-1,y+1)):
							near_point_in_room=true
						elif room.has_point(Vector2(x+1,y+1)):
							near_point_in_room=true
						if near_point_in_room:
							break
					if near_point_in_room:
						data[Vector2(x,y)]=2
						all_dor_cells[Vector2(x,y)]=true

func _change_dors_mode():
	if level.get_cell_atlas_coords(1,data.find_key(2))==Vector2i(30,4):
		for pt in all_dor_cells:
			if data.get(pt-Vector2(0,1))!=2:
				#level.set_cell(0,Vector2(x,y-1),0,Vector2(12,4))
				level.set_cell(1,pt-Vector2(0,1),0,Vector2(2,5))
			if data.get(pt+Vector2(0,1))!=2:
				level.set_cell(1,pt+Vector2(0,1),0,Vector2(24,6))
				#level.set_cell(1,Vector2(x,y+1),0,Vector2(2,5))
			level.set_cell(0,pt,0,Vector2(12,4))
			level.set_cell(1,pt,0,Vector2(2,5))
	else:
		for pt in all_dor_cells:
			if data.get(pt-Vector2(0,1))!=2:
				#level.set_cell(0,Vector2(x,y-1),0,Vector2(12,4))
				level.set_cell(1,pt-Vector2(0,1),0,Vector2(46,6))
			if data.get(pt+Vector2(0,1))!=2:
				level.set_cell(1,pt+Vector2(0,1),0,Vector2(50,4))
				#level.set_cell(1,Vector2(x,y+1),0,Vector2(2,5))
			level.set_cell(1,pt,0,Vector2(30,4))

func _add_monsters(rng:RandomNumberGenerator, room:Rect2):
	if rng.randi_range(0,1) and $Player.position!=Vector2(0,0):
		for en in rng.randi_range(1,3):
			var child_enemy=get_node("Red_monster").duplicate()
			children.push_back(child_enemy)
			add_child(child_enemy)
			child_enemy.position=room.get_center()*32+Vector2(rng.randi_range(-100,100),rng.randi_range(-100,100))
			child_enemy.visible=true
	else:
		$Player.position=room.get_center()*32

func _intersects(room: Rect2):
	var out = false
	for room_other in rooms:
		if room.intersects(room_other, true):
			out = true
			break
	return out
