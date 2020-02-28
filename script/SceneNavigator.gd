extends Node

const Game = preload("res://scenes/Game.tscn")

var _main_scene_instance = preload("res://scenes/Main.tscn").instance()

func nav_to_main():
    var tree := get_tree()
    var root := tree.get_root()
    var current_scene := tree.current_scene
    if current_scene != _main_scene_instance:
        current_scene.queue_free()
    root.add_child(_main_scene_instance)
    tree.current_scene = _main_scene_instance
    
    
func nav_to_game():
    var tree := get_tree()
    var root := tree.get_root()
    root.remove_child(tree.current_scene)
    var game_scene_instance = Game.instance()
    root.add_child(game_scene_instance)
    tree.current_scene = game_scene_instance
