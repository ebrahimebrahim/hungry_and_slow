extends Node

const TreeStructure = preload("res://TreeStructure.gd")
var PreyStatesTree : TreeStructure = TreeStructure.new("prey")

var idle : TreeStructure
var idle_motion : TreeStructure
var idle_stopped : TreeStructure

var seeking_safety : TreeStructure
var running_away : TreeStructure


func _ready():
	idle = PreyStatesTree.add_child("idle")
	idle_motion = idle.add_child("in motion")
	idle_stopped = idle.add_child("stopped")
	seeking_safety = PreyStatesTree.add_child("seeking safety")
	running_away = PreyStatesTree.add_child("running away")
