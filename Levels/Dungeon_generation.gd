extends Node2D

@export var change_generation_method=1
@export var level_size = Vector2(150, 150)
@export var rooms_size = Vector2(15, 25)
@export var rooms_max = 10
@export var corridor_size=3
var data = {}
var enemies={}
var rooms=[]
var used_rooms={}
var dors=[]
@onready var level: TileMap = $Level

func _generate():
	var regenerate=true
	var rng = RandomNumberGenerator.new()
	while regenerate:
		for room in enemies:
			for enemy in enemies.get(room):
				enemy.queue_free()
		$Player.position=Vector2(0,0)
		level.clear()
		data={}
		enemies={}
		for room in rooms:
			remove_child(room)
		rooms = []
		used_rooms={}
		dors=[]
		regenerate=_generate_data(rng)
	_reduce_room_area()
	_add_connections(rng)
	_add_dors()
	_fill_level()
	
func _fill_level():
	for point in data:
		if data.get(point)==1 or data.get(point)==2:
			level.set_cell(0,point,0,Vector2(12,4))
		elif data.get(Vector2(point))==3:
			if data.get(point+Vector2(0,1))!=3:
				level.set_cell(1,point+Vector2(0,1),0,Vector2(24,6))
			level.set_cell(0,point,0,Vector2(12,4))

func _generate_data(rng:RandomNumberGenerator):
	rng.randomize()
	var room:Area2D
	var tries_before_regeneration=20
	while rooms.size()<7 and rooms.size()<rooms_max:
		room = _get_random_room(rng)
		if room:
			tries_before_regeneration=20
			rooms.push_back(room)
			add_child(room)
			room.body_entered.connect(_player_enters_room)
			_add_creatures(rng,room)
		elif tries_before_regeneration<=0 and data.size()>7000:
			return true
		elif tries_before_regeneration<=-30:
			return true
		else:
			tries_before_regeneration-=1
		print(snapped(rooms.size()/7.0,0.1))
	return false

func _get_random_room(rng: RandomNumberGenerator) :
	var area=Area2D.new()
	var col=CollisionShape2D.new()
	area.add_child(col)
	var shape
	var posx:int
	var posy:int
	var c=32
	var room_dic={}
	if rng.randi_range(0,1):
		var y:int
		var radius=rng.randi_range(rooms_size.x,rooms_size.y)*1.3
		posx = rng.randi_range(2+radius, level_size.x - radius - 2)
		posy = rng.randi_range(2+radius, level_size.y - radius - 2)
		shape=CircleShape2D.new()
		shape.set_radius(radius*c)
		for xi in range(-radius,radius+1):
			y=round(sqrt(-xi*xi+radius*radius))
			for yi in range(-y,y):
				if !data.has(Vector2(xi+posx,yi+posy)):
					room_dic[Vector2(xi+posx,yi+posy)]=1
				else:
					area.queue_free()
					return null
	else:
		var width = rng.randi_range(rooms_size.x, rooms_size.y)
		var height =rng.randi_range(rooms_size.x, rooms_size.y)
		posx = rng.randi_range(2+width, level_size.x - width - 2)
		posy = rng.randi_range(2+height, level_size.y - height - 2)
		shape=RectangleShape2D.new()
		shape.set_size(Vector2(width,height)*2*c)
		for xi in range(posx-width, posx+width):
			for yi in range(posy-height, posy+height):
				if !data.has(Vector2(xi, yi)):
					room_dic[Vector2(xi, yi)] = 1
				else:
					area.queue_free()
					return null
	area.set_collision_mask_value(10,true)
	col.set_shape(shape)
	area.position=Vector2(posx,posy)*c
	data.merge(room_dic)
	return area

func _reduce_room_area():
	for room in rooms:
		var posx=room.position.x/32
		var posy=room.position.y/32
		if room.get_child(0).get_shape().get_class()=="CircleShape2D":
			var radius=room.get_child(0).get_shape().get_radius()/32
			room.get_child(0).get_shape().set_radius((radius-3.5)*32)
			for xi in range(-radius,radius+1):
				var y=round(sqrt(-xi*xi+radius*radius))
				for yi in range(-y,-y+3):
					data.erase(Vector2(xi+posx,yi+posy))
				for yi in range(y-2,y+1):
					data.erase(Vector2(xi+posx,yi+posy))
			for yi in range(-radius,radius+1):
				var x=round(sqrt(-yi*yi+radius*radius))
				for xi in range(-x,-x+3):
					data.erase(Vector2(xi+posx,yi+posy))
				for xi in range(x-2,x+1):
					data.erase(Vector2(xi+posx,yi+posy))
		elif room.get_child(0).get_shape().get_class()=="RectangleShape2D":
			var width=room.get_child(0).get_shape().get_size().x/64
			var height=room.get_child(0).get_shape().get_size().y/64
			room.get_child(0).get_shape().set_size(Vector2(width-4,height-4)*64)
			for w in 3:
				for xi in range(posx-width, posx+width):
					data[Vector2(xi,posy+height-w)]=null
					data[Vector2(xi,posy-height+w)]=null
				for yi in range(posy-height, posy+height):
					data[Vector2(posx+width-w, yi)]=null
					data[Vector2(posx-width+w, yi)]=null	
	print("2")

func _add_dors():
	var all_dors={}
	_add_all_dors(all_dors)
	print("4")
	_choose_best_dors(all_dors)
	print("5")

func _add_all_dors(all_dors:Dictionary):
	for x in level_size.x:
		for y in level_size.y:
			if data.get(Vector2(x,y))==2:
				var maybedor=[]
				var hororver#dor is horizontal or vertical
				if data.get(Vector2(x-1,y))==null:
					for cell in range(corridor_size*2+1):
						if data.get(Vector2(x+cell,y))==2 and cell>=corridor_size*2:
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
					for cell in range(corridor_size*2+1):
						if data.get(Vector2(x,y+cell))==2 and cell>=corridor_size*2:
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
					for cell in range(corridor_size*2+1):
						if data.get(Vector2(x-cell,y))==2 and cell>=corridor_size*2:
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
					for cell in range(corridor_size*2+1):
						if data.get(Vector2(x,y-cell))==2 and cell>=corridor_size*2:
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
					var linedor=Line2D.new()
					for point in maybedor:
						data[point]=3
						linedor.add_point(point)
					all_dors[linedor]=hororver
			elif data.get(Vector2(x,y))==null:
				level.set_cell(0,Vector2(x,y),0,Vector2(36,6))

func _choose_best_dors(all_dors:Dictionary):
	for dor in all_dors:
		var point =dor.get_point_position(0)
		var near_cells=[point]
		var index=0
		var point_count=1
		var is_way_to_room=false
		while index<point_count:
			point=near_cells[index]
			if data.get(point-Vector2(1,0))==2 and !near_cells.has(point-Vector2(1,0)):
				near_cells.push_back(point-Vector2(1,0))
				point_count+=1
			elif data.get(point-Vector2(1,0))==1:
				is_way_to_room=true 
				break
				
			if data.get(point-Vector2(0,1))==2 and !near_cells.has(point-Vector2(0,1)):
				near_cells.push_back(point-Vector2(0,1))
				point_count+=1
			elif data.get(point-Vector2(0,1))==1:
				is_way_to_room=true
				break
				
			if data.get(point+Vector2(1,0))==2 and !near_cells.has(point+Vector2(1,0)):
				near_cells.push_back(point+Vector2(1,0))
				point_count+=1
			elif data.get(point+Vector2(1,0))==1:
				is_way_to_room=true
				break
				
			if data.get(point+Vector2(0,1))==2 and !near_cells.has(point+Vector2(0,1)):
				near_cells.push_back(point+Vector2(0,1))
				point_count+=1
			elif data.get(point+Vector2(0,1))==1:
				is_way_to_room=true
				break
				
			index+=1
		if !is_way_to_room:
			for pt in dor.get_point_count():
				data[dor.get_point_position(pt)]=2
		else:
			dors.push_back(dor)
		#Another way to identify dors
		#var cell=0
		#var twosides=0
		#var x=dor.get_point_position(round(dor.get_point_count()/2)).x
		#var y=dor.get_point_position(round(dor.get_point_count()/2)).y
		#if all_dors[dor]:
		#	while twosides<3:
		#		cell+=1
		#		if data.get(Vector2(x-cell,y))==1 and twosides%2==0:
		#			break
		#		elif data.get(Vector2(x-cell,y))!=2 and twosides%2==0:
		#			twosides+=1
		#		if data.get(Vector2(x+cell,y))==1 and twosides<=1:
		#			break
		#		elif data.get(Vector2(x+cell,y))!=2 and twosides<=1:
		#			twosides+=2
		#else:
		#	while twosides<3:
		#		cell+=1
		#		if data.get(Vector2(x,y-cell))==1 and twosides%2==0:
		#			break
		#		elif data.get(Vector2(x,y-cell))!=2 and twosides%2==0:
		#			twosides+=1
		#		if data.get(Vector2(x,y+cell))==1 and twosides<=1:
		#			break
		#		elif data.get(Vector2(x,y+cell))!=2 and twosides<=1:
		#			twosides+=2
		#if twosides>=3:
		#	for pt in dor.get_point_count():
		#		data[dor.get_point_position(pt)]=2
		#else:
		#	dors.push_back(dor)
	all_dors.clear()

func _change_dors_mode(Open:bool,room_center:Vector2):
	for dor in dors:
		if (dor.get_point_position(0)*32).distance_squared_to(room_center)<rooms_size.y*32*1.3*rooms_size.y*32*1.3*1.2:
			for pt in dor.get_point_count():
				if Open:
					if data.get(dor.get_point_position(pt)-Vector2(0,1))!=3:
						level.set_cell(1,dor.get_point_position(pt)-Vector2(0,1),0,Vector2(2,5))
					if data.get(dor.get_point_position(pt)+Vector2(0,1))!=3:
						level.set_cell(1,dor.get_point_position(pt)+Vector2(0,1),0,Vector2(24,6))
					level.set_cell(0,dor.get_point_position(pt),0,Vector2(12,4))
					level.set_cell(1,dor.get_point_position(pt),0,Vector2(2,5))
				else:
					if data.get(dor.get_point_position(pt)-Vector2(0,1))!=3:
						level.set_cell(1,dor.get_point_position(pt)-Vector2(0,1),0,Vector2(46,6))
					if data.get(dor.get_point_position(pt)+Vector2(0,1))!=3:
						level.set_cell(1,dor.get_point_position(pt)+Vector2(0,1),0,Vector2(50,4))
					level.set_cell(1,dor.get_point_position(pt),0,Vector2(30,4))
		else:
			continue

func _add_creatures(rng:RandomNumberGenerator, room:Area2D):
	if $Player.position!=Vector2(0,0):
		var room_monsters=[]
		for en in rng.randi_range(1,2):
			var child_enemy=get_node("Red_monster").duplicate()			
			room_monsters.push_back(child_enemy)
			add_child(child_enemy)
			child_enemy.position=room.position+Vector2(rng.randi_range(-150,150),rng.randi_range(-150,150))
			child_enemy.visible=true
			child_enemy.room=room
		enemies[room]=room_monsters
	else:
		used_rooms[room]=true
		$Player.position=room.position

func _add_connections(rng: RandomNumberGenerator):
	var k=1
	for room in rooms:
		var distace=9999999
		var nearest_room:Area2D
		for room2_index in range(k, rooms.size()):
			if distace>(room.position/32).distance_squared_to(rooms[room2_index].position/32):
				distace=(room.position/32).distance_squared_to(rooms[room2_index].position/32)
				nearest_room=rooms[room2_index]
		k+=1
		if nearest_room:
			var room_center1 = room.position/32
			var room_center2 = nearest_room.position/32
			if !rng.randi_range(0, 1):
				_add_corridor(room_center1.x, room_center2.x, room_center1.y, Vector2.AXIS_X)#Exit horizontal
				_add_corridor(room_center1.y, room_center2.y, room_center2.x, Vector2.AXIS_Y)#Enter vertical
			else:
				_add_corridor(room_center1.y, room_center2.y, room_center1.x, Vector2.AXIS_Y)#Exit vertical
				_add_corridor(room_center1.x, room_center2.x, room_center2.y, Vector2.AXIS_X)#Enter horizontal
	print("3")

func _add_corridor( start: int, end: int, constant: int, axis: int) :
	for cor_length in corridor_size:
		for t in range(min(start, end), max(start, end) + cor_length+1):
			var point = Vector2.ZERO
			match axis:
				Vector2.AXIS_X: point = Vector2(t, constant+cor_length)
				Vector2.AXIS_Y: point = Vector2(constant+cor_length, t)
			if data.get(point)!=1:
				data[point] = 2

func _player_enters_room(_body:Node2D):
	pass
func find_nearest_room(player):
	var distance=level_size.x*level_size.y*level_size.x*level_size.y
	var nearest_room:Area2D
	for room in rooms:
		if room.position.distance_squared_to(player)<distance:
			distance=room.position.distance_squared_to(player)
			nearest_room=room
	return nearest_room
