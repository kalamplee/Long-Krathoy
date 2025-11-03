extends Control


func _on_enter_pressed() -> void:
	Global.WISH = $paperTexture/text.value
	queue_free()
	pass # Replace with function body.
