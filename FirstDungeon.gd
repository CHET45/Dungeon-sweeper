extends "res://Levels/basic_dungeon.gd"

func delete_weapon_from_scene(_weapon_path):
	await get_tree().physics_frame
	for weapon in weapons_in_room:
		remove_child(weapon)
	weapons_in_room=[]
