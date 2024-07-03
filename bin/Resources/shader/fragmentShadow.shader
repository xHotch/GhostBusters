uniform vec2 near_far;
uniform vec4 lightPos;

in vec4 WS_pos_from_GS;

void main(void)
{
	float WS_dist = distance(WS_pos_from_GS, lightPos);

	float WS_dist_normalized = (WS_dist - near_far.x) / (near_far.y - near_far.x);

	gl_FragDepth = WS_dist_normalized;
}