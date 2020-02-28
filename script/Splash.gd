extends TextureRect


func _ready():
    yield(get_tree().create_timer(1), "timeout")
    SceneNavigator.nav_to_main()
