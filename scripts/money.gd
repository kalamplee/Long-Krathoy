extends Control

var money = [1, 2, 5, 10, 20, 50, 100, 500, 1000]


func _on_one_pressed() -> void:
	Global.MONEY = 1
	queue_free()
	pass # Replace with function body.
