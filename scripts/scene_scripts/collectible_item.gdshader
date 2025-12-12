shader_type canvas_item;

uniform vec4 glow_color = vec4(1.0, 1.0, 0.5, 1.0);
uniform float glow_strength = 0.5;

void fragment() {
    vec4 tex = texture(TEXTURE, UV);
    COLOR = tex;

    // Simple glow: add color based on alpha
    vec4 glow = glow_color * tex.a * glow_strength;
    COLOR.rgb += glow.rgb;
}
