shader_type canvas_item;

void fragment() {
    // Just show the texture exactly as it is.
    COLOR = texture(TEXTURE, UV);
}