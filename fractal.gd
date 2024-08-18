extends Sprite2D

const ZOOM_FACTOR = .1
var zoom = 1.0
var off = Vector2(1.9,0)

var shader_material

func _ready():
	# Check if the sprite has a shader material
	if self.material is ShaderMaterial:
		# Cast the material to ShaderMaterial
		shader_material = self.material as ShaderMaterial
		
	else:
		print("Sprite does not have a shader material applied.")
		
	#Big.setBigDecimals(1)
	var big_num = Big.new(0, 50)
	big_num.plusEquals(1.0)
	var big_divisor = Big.new(10 ** 1, 50)
	big_num.dividedByEquals(big_divisor)
	print(big_num.toString())

func _input(event):
	if Input.is_action_just_pressed("zoom_in"):
		set_zoom(zoom * (1 + ZOOM_FACTOR), get_global_mouse_position())
	if Input.is_action_just_pressed("zoom_out"):
		set_zoom(zoom * (1 - ZOOM_FACTOR), get_global_mouse_position())

func set_zoom(val, pos):
	if shader_material:
		zoom = val
		shader_material.set_shader_parameter("scale", zoom)
		
		off -= (pos * zoom / (texture.size / 2.0))
		shader_material.set_shader_parameter("offset", off)
		
	
