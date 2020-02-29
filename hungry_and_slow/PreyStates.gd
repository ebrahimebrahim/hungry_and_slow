extends Node

const TreeStructure = preload("res://TreeStructure.gd")
var PreyStatesTree : TreeStructure = TreeStructure.new("prey")

var idle : TreeStructure
var idle1 : TreeStructure
var idle2 : TreeStructure

var seeking_safety : TreeStructure
var running_away : TreeStructure


func _ready():
	idle = PreyStatesTree.add_child("idle")
	idle1 = idle.add_child("IDLE1")
	idle2 = idle.add_child("IDLE2")
	seeking_safety = PreyStatesTree.add_child("seeking safety")
	running_away = PreyStatesTree.add_child("running away")
