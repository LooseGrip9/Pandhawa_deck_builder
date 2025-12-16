shader_type canvas_item;

// Set this to (25, 30) in the Inspector!
uniform vec2 size = vec2(25.0, 30.0);
uniform float y_rot : hint_range(-180, 180) = 0.0;
uniform float x_rot : hint_range(-180, 180) = 0.0;
// Controls how "deep" the 3D effect looks. Higher = less distortion.
uniform float depth : hint_range(10.0, 500.0) = 50.0;

void vertex() {
	// 1. Find the center of the card
	vec2 half_size = size / 2.0;

	// 2. Move the vertex so (0,0) is at the center of the card
	vec2 p = VERTEX - half_size;

	// 3. Calculate Rotation (Standard 3D Rotation Matrix)
	float sin_y = sin(y_rot * 3.14159 / 180.0);
	float cos_y = cos(y_rot * 3.14159 / 180.0);
	float sin_x = sin(x_rot * 3.14159 / 180.0);
	float cos_x = cos(x_rot * 3.14159 / 180.0);

	mat3 rotation_matrix = mat3(
		vec3(cos_y, 0.0, -sin_y),
		vec3(sin_y * sin_x, cos_x, cos_y * sin_x),
		vec3(sin_y * cos_x, -sin_x, cos_y * cos_x)
	);

	vec3 transformed = rotation_matrix * vec3(p, 0.0);

	// 4. Apply Perspective (The "Z-Divide")
	// We add 1.0 to ensure that at z=0, the scale is exactly 1.0 (no zoom)
	float perspective_factor = 1.0 + (transformed.z / depth);

	// 5. Apply the transform and move the vertex back to its original position
	VERTEX = (transformed.xy / perspective_factor) + half_size;
}