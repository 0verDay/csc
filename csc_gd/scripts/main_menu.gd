extends Node2D

@export var gameplay_interface_scene: PackedScene

@onready var start_button: Button = $CanvasLayer/StartButton

func _ready() -> void:
	start_button.pressed.connect(_on_start_button_pressed)

func _on_start_button_pressed() -> void:
	if gameplay_interface_scene == null:
		push_warning("未设置 gameplay_interface 场景资源")
		return

	get_tree().change_scene_to_packed(gameplay_interface_scene)
