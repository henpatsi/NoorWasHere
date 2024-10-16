extends RigidBody3D

var hit_no_exit_area = false

func on_no_exit_area_entered():
	print("Hit no exit area!")
	hit_no_exit_area = true
