extends Card

@export var entangle_ability : PackedScene

func _on_body_entered(body):
    if body.is_in_group("enemies"):
        body.take_damage(self)
        # Level the audio based on distance from player on impact
        MusicManager.play_sound_effect(enemy_hit_sound,-abs((global_position-parent_object.global_position).length())/25)
    else:
        MusicManager.play_sound_effect(wall_hit_sound,-abs((global_position-parent_object.global_position).length())/25)
    if entangle_ability:
        var ability = entangle_ability.instantiate()
        ability.global_position = global_position
        ability.rotation_degrees = rotation_degrees + 90
        get_parent().call_deferred("add_child",ability)
    else:
        printerr("Failed to produce AOE no PackedScene selected")
    queue_free()
