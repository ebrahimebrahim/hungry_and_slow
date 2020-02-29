extends Reference

var name : String = "Unnamed TreeStructure node"
var ID : int
var children = {}
var parent

func _init(name : String, parent_node = null):
	self.name = name
	self.ID = name.hash()
	self.parent = parent_node

func add_child(child_name : String):
	children[child_name]=(get_script().new(child_name,self))
	return get_child(child_name)

func get_child(child_name : String):
	return children[child_name]

func get_parent():
	return parent

# Determines whether self is descendant of given node (descendant-or-equal-to)
func IS(tree_structure_node) -> bool :
	if self.ID==tree_structure_node.ID: return true
	if not parent: return false
	return parent.IS(tree_structure_node)
