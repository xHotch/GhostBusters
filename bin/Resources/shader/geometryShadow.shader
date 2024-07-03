#version 430 core
layout(triangles) in;
layout(triangle_strip, max_vertices = 90) out;

const int MAX_NUMBER_POINTLIGHTS = 5;
uniform mat4 cm_mat[6];
uniform int lightID;
out vec4 WS_pos_from_GS;

void main(void)
{
	//int i = 0;
	for (int i = 0; i < 6; ++i)
	{
		for (int tri_vert = 0; tri_vert < 3; ++tri_vert)
		{
			gl_Layer = lightID * 6 + i;
			WS_pos_from_GS = gl_in[tri_vert].gl_Position;
			gl_Position = cm_mat[i] * WS_pos_from_GS;
			EmitVertex();
		}
		EndPrimitive();
	}
}