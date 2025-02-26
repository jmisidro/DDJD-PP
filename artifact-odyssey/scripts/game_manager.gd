extends Node

@onready var money_label = $"../Player/Camera2D/moneyLabel"

var money = 0

func add_money(qty):
	money += qty
	money_label.text = str(money) + "X"
	
func remove_money(qty):
	money -= qty
	money_label.text = str(money) + "X"
