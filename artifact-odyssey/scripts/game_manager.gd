extends Node

@onready var money_label = $"../Player/Camera2D/moneyLabel"

var money = 0

func add_money():
	money += 1
	money_label.text = str(money) + "X"
