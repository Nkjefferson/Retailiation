class_name SpawnedEntity extends Resource


@export var entity : PackedScene
@export var spawn_weight : float

func _get(property: StringName):
	if property == 'entity':
		return entity
	if property == 'spawn_weight':
		return spawn_weight
	return false

func _set(property: StringName, value):
	if property == 'entity':
		entity = value
	if property == 'spawn_weight':
		entity = value
	return true

func _get_property_list():
	var props = []
	props.append(
		{
			'entity': entity,
			'type': PackedScene
		}
	)
	props.append(
		{
			'spawn_rate': spawn_weight,
			'type': TYPE_FLOAT
		}
	)
	return props
