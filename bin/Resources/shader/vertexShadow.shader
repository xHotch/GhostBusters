#version 430 core
uniform mat4 modelMatrix;
layout(location = 0) in vec3 attr_vertex;

void main(void) 
{
	gl_Position = modelMatrix * vec4(attr_vertex, 1.0);
}