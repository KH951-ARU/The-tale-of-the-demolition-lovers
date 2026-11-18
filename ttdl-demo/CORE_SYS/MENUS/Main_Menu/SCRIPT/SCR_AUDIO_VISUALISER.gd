extends Control

@export_group("Audio Analysis")
@export var bus_name: String = "Music"
@export var bar_count: int = 10
@export var min_freq: float = 20.0
@export var max_freq: float = 12000.0
@export var min_db: float = 60.0

@export_group("Bar Styling")
@export var bar_width: float = 10.0
@export var bar_spacing: float = 4.0
@export var max_height: float = 48.0
@export var fall_speed: float = 14.0

@export_group("Dynamic Colors")
@export var low_color: Color = Color(0.1, 1.0, 0.3, 1.0)    # Neon Green (0% - 50%)
@export var mid_color: Color = Color(1.0, 0.9, 0.1, 1.0)    # Bright Yellow (50% - 80%)
@export var peak_color: Color = Color(1.0, 0.1, 0.3, 1.0)   # Hot Red/Pink (80% - 100%)

var spectrum: AudioEffectSpectrumAnalyzerInstance
var bars: Array[ColorRect] = []

func _ready() -> void:
	z_index = 10
	clip_contents = false # Prevent parent box from hiding bars 2 through 10
	
	# Clear any leftover children just in case
	for child in get_children():
		child.queue_free()
	bars.clear()
	
	# Resize this Control node automatically to fit all 10 bars cleanly
	var total_width = (bar_count * bar_width) + ((bar_count - 1) * bar_spacing)
	custom_minimum_size = Vector2(total_width, max_height)
	size = custom_minimum_size
	
	# Connect to the Music bus safely
	var bus_idx = AudioServer.get_bus_index(bus_name)
	if bus_idx != -1:
		if AudioServer.get_bus_effect_count(bus_idx) == 0:
			var analyzer = AudioEffectSpectrumAnalyzer.new()
			AudioServer.add_bus_effect(bus_idx, analyzer, 0)
		spectrum = AudioServer.get_bus_effect_instance(bus_idx, 0)
	else:
		push_warning("Audio bus '%s' not found! Check your Audio tab." % bus_name)
	
	# Generate all 10 bars side-by-side
	for i in range(bar_count):
		var bar = ColorRect.new()
		bar.color = low_color
		bar.size = Vector2(bar_width, 6.0)
		
		var x_pos = i * (bar_width + bar_spacing)
		bar.position = Vector2(x_pos, max_height - 6.0)
		
		add_child(bar)
		bars.append(bar)

func _process(delta: float) -> void:
	if not spectrum or bars.is_empty():
		return
		
	var prev_hz: float = min_freq
	
	for i in range(bar_count):
		var hz: float = min_freq * pow(max_freq / min_freq, float(i + 1) / float(bar_count))
		var magnitude: float = spectrum.get_magnitude_for_frequency_range(prev_hz, hz).length()
		var energy: float = clamp((min_db + linear_to_db(magnitude)) / min_db, 0.0, 1.0)
		var target_height: float = max(6.0, energy * max_height)
		
		# Smoothly animate height and keep bottom edge anchored
		var current_height: float = bars[i].size.y
		var new_height: float = lerp(current_height, target_height, fall_speed * delta)
		bars[i].size.y = new_height
		bars[i].position.y = max_height - new_height
		
		# Calculate height progress percentage (0.0 to 1.0) and shift color
		var progress: float = clamp(new_height / max_height, 0.0, 1.0)
		bars[i].color = get_color_for_progress(progress)
		
		prev_hz = hz

func get_color_for_progress(progress: float) -> Color:
	if progress < 0.5:
		# Blend from Green to Yellow in the lower half
		return low_color.lerp(mid_color, progress * 2.0)
	else:
		# Blend from Yellow to Red/Pink in the upper half
		return mid_color.lerp(peak_color, (progress - 0.5) * 2.0)
