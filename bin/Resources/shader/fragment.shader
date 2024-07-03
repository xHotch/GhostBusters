#version 430 core
const int MAX_NUMBER_POINTLIGHTS = 8;
out vec4 FragColor;

#define i0  0
#define i1  1
#define i2  2
#define i3  3
#define i4  4
#define i5  5
#define i6  6
#define i7  7



in VertexData {
	vec3 position_world;
	vec3 normal_world;
	vec2 texCoord;
	vec3 T;
	vec3 B;
	vec3 N;
} vert;

layout (location = 1) uniform vec4 color;
uniform sampler2D texture_diffuse1;
uniform sampler2D texture_normal1;
uniform samplerCubeArray shadowMapArray;
uniform samplerCube skybox;
uniform bool environment_mapping;
uniform bool normal_mapping;

uniform bool shadows;

uniform vec3 materialCoefficients; // x = ambient, y = diffuse, z = specular 
uniform float specularAlpha;
uniform vec3 diffuseColor;
uniform vec3 camera_world;
uniform int nr_pointlights;

uniform struct DirectionalLight {
	vec3 color;
	vec3 direction;
} dirLight;

uniform struct PointLight {

	float mAttenuationConstant;
	float mAttenuationLinear;

	float mAttenuationQuadratic;
	vec3 mColorAmbient;
	vec3 mColorDiffuse;
	vec3 mColorSpecular;

	vec3 mPosition;
	vec2 near_far;
	int mLightID;
	//near_far
} pointLight[MAX_NUMBER_POINTLIGHTS];



vec3 phong(vec3 n, vec3 l, vec3 v, vec3 diffuseC, float diffuseF, vec3 specularC, float specularF, float alpha, bool attenuate, vec3 attenuation) {
	float d = length(l);
	l = normalize(l);
	float att = 1.0;	
	if(attenuate) att = 1.0f / (attenuation.x + d * attenuation.y + d * d * attenuation.z);
	vec3 r = reflect(-l, n);
	return (diffuseF * diffuseC * max(0, dot(n, l)) + specularF * specularC * pow(max(0, dot(r, v)), alpha)) * att; 
}

//https://learnopengl.com/Lighting/Multiple-lights
vec3 pointLightAttribution(int lightID, vec3 normal, vec3 fragPos, vec3 viewDir, vec3 diffuseC, float shadowCoefficient)
{
	vec3 lightDir = normalize(pointLight[lightID].mPosition - fragPos);
	// diffuse shading
	float diff = max(dot(normal, lightDir), 0.0);
	// specular shading
	vec3 reflectDir = reflect(-lightDir, normal);
	float spec = pow(max(dot(viewDir, reflectDir), 0.0), specularAlpha);
	// attenuation
	float distance = length(pointLight[lightID].mPosition - fragPos);
	float attenuation = 1.0 / (pointLight[lightID].mAttenuationConstant + pointLight[lightID].mAttenuationLinear * distance +
		pointLight[lightID].mAttenuationQuadratic * (distance * distance));
	// combine results

	//TODO check source remove ambient??
	//why do we need material coefficients? we already have textures no?
	vec3 ambient = pointLight[lightID].mColorAmbient * diffuseC * materialCoefficients.x;
	vec3 diffuse = pointLight[lightID].mColorDiffuse * diff * diffuseC * materialCoefficients.y * (1 - shadowCoefficient);
	vec3 specular = pointLight[lightID].mColorSpecular * spec * materialCoefficients.z * (1 - shadowCoefficient);
	ambient *= attenuation;
	diffuse *= attenuation;
	specular *= attenuation;
	return (ambient + diffuse + specular);
}

void main()
{
	
	vec3 n = vert.N;
	if (normal_mapping)
	{
		n = texture(texture_normal1, vert.texCoord).rgb;
		n = normalize(n * 2.0 - 1.0);  // this normal is in tangent space
		mat3 TBN = mat3(normalize(vert.T), normalize(vert.B), normalize(vert.N));
		n = normalize(TBN * n);
	}

	vec3 v = normalize(camera_world - vert.position_world);
	vec3 c = texture(texture_diffuse1, vert.texCoord).rgb;

	// environment mapping
	if (environment_mapping)
	{
		vec3 i = normalize(vert.position_world - camera_world);
		vec3 r = reflect(i, normalize(vert.normal_world));
		FragColor = vec4(texture(skybox, r).rgb, 1.0) * 0.2;
	}

	FragColor += vec4(c * diffuseColor * materialCoefficients.x, 1); // ambient light

	//Loop over Lights for shadow and light calculation
	for (int i = 0; i < nr_pointlights; i++) {
		int lightID;
		if (pointLight[i].mLightID == i0)
			lightID = 0;
		if (pointLight[i].mLightID == i1)
			lightID = 1;
		if (pointLight[i].mLightID == i2)
			lightID = 2;
		if (pointLight[i].mLightID == i3)
			lightID = 3;
		if (pointLight[i].mLightID == i4)
			lightID = 4;
		if (pointLight[i].mLightID == i5)
			lightID = 5;
		if (pointLight[i].mLightID == i6)
			lightID = 6;
		if (pointLight[i].mLightID == i7)
			lightID = 7;

		float shadowCoefficient = 0.0;
		// source: https://learnopengl.com/Advanced-Lighting/Shadows/Point-Shadows
		if (shadows)
		{
			vec3 gridSamplingDisk[20] = vec3[]
			(
				vec3(1, 1, 1), vec3(1, -1, 1), vec3(-1, -1, 1), vec3(-1, 1, 1),
				vec3(1, 1, -1),vec3(1, -1, -1),vec3(-1, -1, -1),vec3(-1, 1, -1),
				vec3(1, 1, 0), vec3(1, -1, 0), vec3(-1, -1, 0), vec3(-1, 1, 0),
				vec3(1, 0, 1), vec3(-1, 0, 1), vec3(1, 0, -1),  vec3(-1, 0, -1),
				vec3(0, 1, 1), vec3(0, -1, 1), vec3(0, -1, -1), vec3(0, 1, -1)
			);

			vec3 cm_lookup_vec = vert.position_world.xyz - pointLight[lightID].mPosition;
			//vec3 cm_lookup_vec = vert.position_world.xyz - WS_pos_light.xyz;
			float d_L = texture(shadowMapArray, vec4(cm_lookup_vec, lightID)).r;
			//float d_L = texture(shadowMap[lightID], cm_lookup_vec).r;
			
			// PCF
			float d_S = length(cm_lookup_vec);
			int samples = 20;
			float bias = 0.15;
			float viewDistance = length(camera_world.xyz - vert.position_world.xyz);
			float diskRadius = (1.0 + (viewDistance / pointLight[lightID].near_far.y)) / 25.0;
			for (int i = 0; i < samples; ++i)
			{
				float closestDepth = texture(shadowMapArray, vec4(cm_lookup_vec + gridSamplingDisk[i] * diskRadius, lightID)).r;
				closestDepth *= pointLight[lightID].near_far.y;
				if (d_S - bias > closestDepth)
				{
					shadowCoefficient += 1.0;
				}
			}
			shadowCoefficient /= float(samples);
		}

		// add directional light contribution
		// FragColor.rgb += phong(n, -dirLight.direction, v, dirLight.color * c, shadowCoefficient * materialCoefficients.y, dirLight.color, shadowCoefficient * materialCoefficients.z, specularAlpha, false, vec3(0));

		FragColor.rgb += pointLightAttribution(lightID, n, vert.position_world, v, c, shadowCoefficient);
	}
}