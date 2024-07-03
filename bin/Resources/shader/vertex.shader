#version 430 core
layout(location = 0) in vec3 aPos;
layout(location = 2) in vec2 aTexCoord;
layout(location = 4) in vec3 normal;
layout(location = 5) in vec3 tangent;
layout(location = 6) in vec3 bitangent;
layout(location = 7) in ivec4 boneIDs;
layout(location = 8) in vec4 weights;


uniform mat4 modelMatrix;
uniform mat4 viewMatrix;
uniform mat4 projectionMatrix;
uniform vec3 camera_world;
uniform mat4 bones[200];
uniform bool hasAnimations;

uniform struct DirectionalLight {
	vec3 color;
	vec3 direction;
} dirLight;

out VertexData {
	vec3 position_world;
	vec3 normal_world;
	vec2 texCoord; 
	vec3 T;
	vec3 B;
	vec3 N;
} vert;

mat4 test(mat4 m)
{
	return transpose(inverse(m));
}

void main()
{
	mat4 boneTransform = bones[boneIDs[0]] * weights[0];
	boneTransform += bones[boneIDs[1]] * weights[1];
	boneTransform += bones[boneIDs[2]] * weights[2];
	boneTransform += bones[boneIDs[3]] * weights[3];
	if (!hasAnimations) boneTransform = mat4(1.0);

	vec4 position_world_ = modelMatrix * boneTransform * vec4(aPos, 1);
	vert.position_world = position_world_.xyz / position_world_.w;
	gl_Position = projectionMatrix * viewMatrix * position_world_;
    vert.texCoord = aTexCoord;

	vert.T = normalize(vec3(modelMatrix * boneTransform * vec4(tangent, 0.0)));
	vert.B = normalize(vec3(modelMatrix * boneTransform * vec4(bitangent, 0.0)));
	vert.N = normalize(vec3(modelMatrix * boneTransform * vec4(normal, 0.0)));
	
	vert.normal_world = mat3(transpose(inverse(modelMatrix))) * normal;
}

