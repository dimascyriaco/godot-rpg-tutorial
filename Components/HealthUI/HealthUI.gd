extends Control

var hearts = 4 setget set_hearts
var max_hearts = 4 setget set_max_hearts

onready var heart_ui_full = $HeartUIFull as TextureRect
onready var heart_ui_empty = $HeartUIEmpty as TextureRect
onready var heart_width: int = heart_ui_full.texture.get_width()

func _ready() -> void:
	self.max_hearts = PlayerStats.max_health
	self.hearts = PlayerStats.health
	PlayerStats.connect('health_changed', self, 'set_hearts')
	PlayerStats.connect('max_health_changed', self, 'set_max_hearts')

func set_hearts(value: int) -> void:
	hearts = clamp(value, 0, max_hearts)

	if heart_ui_full != null:
		heart_ui_full.rect_size.x = hearts * heart_width

func set_max_hearts(value: int) -> void:
	max_hearts = max(value, 1)
	
	if heart_ui_empty != null:
		heart_ui_empty.rect_size.x = max_hearts * heart_width
