class_name StatsUI
extends HBoxContainer


@onready var block: HBoxContainer = $Block
@onready var block_label: Label = %BlockLabel
@onready var health: HealthUI= $Health
@onready var counter: HBoxContainer = $Counter
@onready var counter_label: Label = %CounterLabel

func update_stats(stats: Stats) -> void:
	block_label.text = str(stats.block)
	health._update_stats(stats)
	
	block.visible = stats.block > 0
	health.visible = stats.health > 0
	
	counter_label.text = str(stats.counter_damage)
	counter.visible = stats.counter_damage > 0
