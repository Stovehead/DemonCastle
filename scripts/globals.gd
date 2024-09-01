extends Node

var current_player:Player
var game_instance:Game

var num_zombies:int = 0

var persistent_objects:Dictionary

var entered_konami_code:bool = false

func crossed_point(position:float, target:float, delta:float) -> bool:
	return (position-target)*(position-target-delta) <= 0
