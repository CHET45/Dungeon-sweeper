extends Control
var rooms={}
@onready var avatar=$Marker

func avatar_movement(pos:Vector2):
	avatar.position=pos/32
func add_rooms(room1:Area2D, room2:Area2D, hororver):
	var cur_rooms=[]
	if !rooms.has(room1):
		cur_rooms.push_back(room1)
	if !rooms.has(room2):
		cur_rooms.push_back(room2)
	for map_room in cur_rooms:
		var room=map_room.duplicate()
		room.position=map_room.position/32
		var visible_room=Polygon2D.new()
		var point_array:PackedVector2Array=[]
		var border=Line2D.new()
		if room.get_child(0).get_shape().get_class()=="RectangleShape2D":
			var width=room.get_child(0).get_shape().get_size().x/64+1
			var height=room.get_child(0).get_shape().get_size().y/64+1
			point_array.push_back(Vector2(room.position.x-width,room.position.y-height))
			point_array.push_back(Vector2(room.position.x+width,room.position.y-height))
			point_array.push_back(Vector2(room.position.x+width,room.position.y+height))
			point_array.push_back(Vector2(room.position.x-width,room.position.y+height))
		elif room.get_child(0).get_shape().get_class()=="CircleShape2D":
			var radius=room.get_child(0).get_shape().get_radius()/32+1
			for xi in range(-radius,radius+1):
				var y=round(sqrt(-xi*xi+radius*radius))
				point_array.push_back(Vector2(xi+room.position.x,y+room.position.y))
			for xi in range(radius,-radius-1,-1):
				var y=-round(sqrt(-xi*xi+radius*radius))
				point_array.push_back(Vector2(xi+room.position.x,y+room.position.y))
		border=create_borders(point_array)
		border.set_default_color(Color(0,0,0))
		border.set_width(2)
		add_child(border)
		visible_room.set_polygon(point_array)
		visible_room.set_color(Color("241500"))
		visible_room.set_z_index(1)
		rooms[map_room]=visible_room
		add_child(visible_room)
	var minimap_room1=room1.duplicate()
	minimap_room1.position=room1.position/32
	minimap_room1.scale=room1.scale/32
	var minimap_room2=room2.duplicate()
	minimap_room2.position=room2.position/32
	minimap_room2.scale=room2.scale/32
	add_corridors(minimap_room1,minimap_room2,hororver)
	
func clear_level():
	for room in rooms:
		remove_child(room)
	rooms={}

func add_corridors(room:Area2D, room2:Area2D,hororver):
	var corridor= Line2D.new()
	corridor.add_point(room.position)
	if hororver:
		corridor.add_point(Vector2(room2.position.x,room.position.y))
	else:
		corridor.add_point(Vector2(room.position.x,room2.position.y))
	corridor.add_point(room2.position)
	corridor.width=5
	corridor.set_default_color(Color("130900"))
	add_child(corridor)

func create_borders(point_array):
	var border=Line2D.new()
	for point in point_array:
		border.add_point(point)
	border.add_point(point_array[0])
	return border

func sweeped_room(room:Area2D):
	var minimap_room=rooms.get(room)
	minimap_room.set_color(Color("412900"))
	print("rar")
	
	
	
	
	
	
	
