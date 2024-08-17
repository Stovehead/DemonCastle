class_name Stage
extends Node2D

@export var tile_map:Node2D
@export var objects:Node2D
@export var player_spawner:PlayerSpawner
@export var left_limit:int = 0
@export var right_limit:int = 0
@export var top_limit:int = 8
@export var bottom_limit:int = 224
@export var music:AudioStream
@export var has_checkpoint:bool
@export var has_permanent_checkpoint:bool
@export var stage_number:int
@export var starting_time:int
@export var death_barrier:float = 240
@export var start_timer:bool = true
