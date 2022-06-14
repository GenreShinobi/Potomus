extends Area

signal passed_through(side)

export (Globals.cardinals) var side :int = 0
var is_enterance:bool = false
var is_exit:bool = false


func _on_area_entered(area):
	emit_signal("passed_through", side)
