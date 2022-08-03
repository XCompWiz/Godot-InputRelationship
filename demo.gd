extends Node

const ACTION = "ui_accept"

var frame_tick_counter : int = 0
var physics_tick_counter : int = 0

var frame_container :Dictionary
var physics_container : Dictionary

export(NodePath) var fps_label_path:NodePath
export(NodePath) var frame_label_path:NodePath
export(NodePath) var physics_label_path:NodePath
export(NodePath) var difference_label_path:NodePath

export(NodePath) var frame_action_path:NodePath
export(NodePath) var physics_action_path:NodePath
export(NodePath) var input_action_path:NodePath

export(Color) var color_bg = Color.white
export(Color) var color_pressed = Color.rebeccapurple
export(Color) var color_just_pressed = Color.red
export(Color) var color_just_released = Color.fuchsia
export(Color) var color_input_press = Color.gold
export(Color) var color_input_release = Color.darkgreen

onready var frame_tick_container:Container = $Control/Control/FrameTick
onready var physics_tick_container:Container = $Control/Control/PhysicsTick
onready var fps_label:Label = get_node(fps_label_path)
onready var frame_label:Label = get_node(frame_label_path)
onready var physics_label:Label = get_node(physics_label_path)
onready var difference_label:Label = get_node(difference_label_path)
onready var frame_action_label:Label = get_node(frame_action_path)
onready var physics_action_label:Label = get_node(physics_action_path)
onready var input_action_label:Label = get_node(input_action_path)

func _ready() -> void:
	$Control.connect("gui_input", self, "forwarded_gui_input")
	
	get_tree().connect("idle_frame", self, "_on_idle")
	
	$Control/HBoxContainer/HBoxContainer/MarginContainer/ColorRect.color = color_bg
	$Control/HBoxContainer/HBoxContainer3/MarginContainer/ColorRect.color = color_just_pressed
	$Control/HBoxContainer/HBoxContainer4/MarginContainer/ColorRect.color = color_pressed
	$Control/HBoxContainer/HBoxContainer5/MarginContainer/ColorRect.color = color_just_released
	$Control/HBoxContainer/HBoxContainer6/MarginContainer/ColorRect.color = color_input_press
	$Control/HBoxContainer/HBoxContainer7/MarginContainer/ColorRect.color = color_input_release

	frame_container = {
		total = 0.0,
		max = 1.0,
		frames = [],
		element = frame_tick_container
	}
	physics_container = {
		total = 0.0,
		max = 1.0,
		frames = [],
		element = physics_tick_container
	}


func _input(event: InputEvent) -> void:
	
	var p_indicator:ColorRect = physics_container.frames.back()
	var f_indicator:ColorRect = frame_container.frames.back()
	if event.is_action_pressed(ACTION):
		p_indicator.color = color_input_press
		f_indicator.color = color_input_press
		input_action_label.text = "Pressed"
	if event.is_action_released(ACTION):
		p_indicator.color = color_input_release
		f_indicator.color = color_input_release
		input_action_label.text = "Not Pressed"

func add_frame_box(frame_duration : float, color : Color, container):
	var frame_width : float = frame_duration / container.max * container.element.rect_size.x - container.element.get_constant('separation')
	var node := ColorRect.new()
	node.size_flags_vertical = Control.SIZE_EXPAND_FILL
	node.rect_min_size = Vector2(frame_width, 0)
	node.rect_size = node.rect_min_size
	node.set_meta('duration', frame_duration)
	node.color = color
	
	container.total += frame_duration
	while container.total >= container.max:
		self.remove_oldest(container)

	container.frames.append(node)
	container.element.add_child(node)
	
func remove_oldest(container):
	var node = container.frames.pop_front()
	container.element.remove_child(node)
	container.total -= node.get_meta('duration')
	node.queue_free()


func _process(delta: float) -> void:
	frame_tick_counter += 1

	fps_label.text = str(Engine.get_frames_per_second())
	frame_label.text = str(frame_tick_counter)
	
	var used_color:Color = color_bg
	
	var text := "Not pressed"
	if Input.is_action_pressed(ACTION):
		used_color = color_pressed
		text = "Pressed"
	if Input.is_action_just_pressed(ACTION):
		used_color = color_just_pressed
		text = "Just pressed"
	if Input.is_action_just_released(ACTION):
		used_color = color_just_released
		text = "Just released"
	frame_action_label.text = text
	
	add_frame_box(delta, used_color, frame_container)


func _physics_process(delta: float) -> void:
	physics_tick_counter += 1
	
	physics_label.text = str(physics_tick_counter)
	
	var used_color:Color = color_bg
	
	var text := "Not pressed"
	if Input.is_action_pressed(ACTION):
		used_color = color_pressed
		text = "Pressed"
	if Input.is_action_just_pressed(ACTION):
		used_color = color_just_pressed
		text = "Just pressed"
	if Input.is_action_just_released(ACTION):
		used_color = color_just_released
		text = "Just released"
	physics_action_label.text = text
	
	add_frame_box(delta, used_color, physics_container)

func _on_idle():
	difference_label.text = str(physics_tick_counter - frame_tick_counter)
