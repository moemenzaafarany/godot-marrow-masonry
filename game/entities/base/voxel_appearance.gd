@tool
class_name VoxelAppearance
extends Node3D

## Dictionary mapping slot names (String) -> VoxelPartSlot node
var slots: Dictionary = {}

func _ready() -> void:
	_register_slots(self)

## Recursively registers all VoxelPartSlot children in the hierarchy
func _register_slots(node: Node) -> void:
	for child in node.get_children():
		if child is VoxelPartSlot:
			slots[child.name] = child
			_register_slots(child) # Recurse deeper for nested slots (e.g., Head -> Ears)

## Adds or updates a VoxelPartData resource on a named slot
func set_slot_part(slot_name: String, data: VoxelPartData) -> void:
	if slots.has(slot_name):
		(slots[slot_name] as VoxelPartSlot).part_data = data

## Dynamically creates and attaches a new sub-slot under an existing parent slot
func attach_sub_slot(parent_slot_name: String, sub_slot_name: String, offset: Vector3 = Vector3.ZERO) -> VoxelPartSlot:
	if not slots.has(parent_slot_name):
		push_error("Parent slot %s not found!" % parent_slot_name)
		return null
		
	var parent_slot: VoxelPartSlot = slots[parent_slot_name]
	var new_slot := VoxelPartSlot.new()
	new_slot.name = sub_slot_name
	new_slot.slot_offset = offset
	
	parent_slot.add_child(new_slot)
	slots[sub_slot_name] = new_slot
	return new_slot

## Retrieves a specific slot by name
func get_slot(slot_name: String) -> VoxelPartSlot:
	return slots.get(slot_name, null)
