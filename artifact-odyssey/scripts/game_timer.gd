extends Timer

var elapsed_time = 0.0

func _ready():
	start()

func _process(delta):
	if not is_stopped():
		elapsed_time += delta
