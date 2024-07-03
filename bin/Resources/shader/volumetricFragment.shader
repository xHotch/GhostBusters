#version 430 core

#define i0  0
#define i1  1
#define i2  2
#define i3  3
#define i4  4
#define i5  5
#define i6  6
#define i7  7

const int MAX_NUMBER_POINTLIGHTS = 8;

out vec4 FragColor;
in vec2 TexCoords;

uniform sampler2D depthTexture;
uniform samplerCubeArray shadowMapArray;


//Space Transformation matrices
uniform mat4 view_inv;
uniform mat4 projection_inv;
uniform vec3 view_pos;

//Frametime for Fog Animation
uniform float frameTime;

//Point Lights
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
    float mTau;
    float mPhi;
    int mNrSamples;
} pointLight[MAX_NUMBER_POINTLIGHTS];



uniform int nr_pointlights;
uniform int num_samples;

#define PI_RCP (0.31830988618379067153776752674503)

float volumetric_directional_light(vec3 fragment_position);
float volumetric_point_light(vec3 fragment_position, int lightID, int shadowmapID);

vec3 world_pos_from_depth(float depth);

float dither_pattern[16] = float[16](
    0.0f, 0.5f, 0.125f, 0.625f,
    0.75f, 0.22f, 0.875f, 0.375f,
    0.1875f, 0.6875f, 0.0625f, 0.5625,
    0.9375f, 0.4375f, 0.8125f, 0.3125
    );

void main()
{
    
    float depth = texture(depthTexture, TexCoords).x;
    vec3 frag_pos = world_pos_from_depth(depth);
    FragColor = vec4(depth);

    vec3 color = vec3(0.0f);
    
    for (int i = 0; i < nr_pointlights; i++) {
       
        if (pointLight[i].mLightID == i0)
            color += volumetric_point_light(frag_pos, i, i0) * pointLight[i].mColorDiffuse;
        else if (pointLight[i].mLightID == i1)
            color += volumetric_point_light(frag_pos, i, i1) * pointLight[i].mColorDiffuse;
        else if (pointLight[i].mLightID == i2)
            color += volumetric_point_light(frag_pos, i, i2) * pointLight[i].mColorDiffuse;
        else if (pointLight[i].mLightID == i3)
            color += volumetric_point_light(frag_pos, i, i3) * pointLight[i].mColorDiffuse;
        else if (pointLight[i].mLightID == i4)
            color += volumetric_point_light(frag_pos, i, i4) * pointLight[i].mColorDiffuse;
        else if (pointLight[i].mLightID == i5)
            color += volumetric_point_light(frag_pos, i, i5) * pointLight[i].mColorDiffuse;
        else if (pointLight[i].mLightID == i6)
            color += volumetric_point_light(frag_pos, i, i6) * pointLight[i].mColorDiffuse;
        else if (pointLight[i].mLightID == i7)
            color += volumetric_point_light(frag_pos, i, i7) * pointLight[i].mColorDiffuse;
        
    }
    //Add depth as 4th component, is used in depth aware upsampling 
    FragColor = vec4(color, depth);
}


//Copied from revision course
float tri(in float x) {
    return abs(fract(x) - .5);
}

//Copied from revision course
vec3 tri3(in vec3 p) {
    return vec3(tri(p.z + tri(p.y * 1.)), tri(p.z + tri(p.x * 1.)), tri(p.y + tri(p.x * 1.)));
}

//Copied from revision course
float triNoise3d(in vec3 p, in float spd, in float time) {
    float z = 1.4; float rz = 0.; vec3 bp = p;
    for (float i = 0.; i <= 3.; i++) {
        vec3 dg = tri3(bp * 2.);
        p += (dg + time * spd);
        bp *= 1.8;
        z *= 1.5;
        p *= 1.2;
        rz += (tri(p.z + tri(p.x + tri(p.y)))) / z;
        bp += 0.14;
    }
    return rz;
}

//Heavily inspired from Revision Course on Volumetric Light
float volumetric_point_light(vec3 frag_pos, int lightID, int shadowmapID) {

    float phi = pointLight[lightID].mPhi;
    float tau = pointLight[lightID].mTau;
    
    vec4 end_pos_worldspace = vec4(view_pos, 1.0);
    vec4 start_pos_worldspace = vec4(frag_pos, 1.0);
    vec4 delta_worldspace = normalize(end_pos_worldspace - start_pos_worldspace);

    float raymarch_distance_worldspace = length(end_pos_worldspace - start_pos_worldspace);
    int numsamples = pointLight[lightID].mNrSamples;
    float step_size_worldspace = raymarch_distance_worldspace / numsamples;

    float dither_value = dither_pattern[(int(gl_FragCoord.x) % 4) * 4 + (int(gl_FragCoord.y) % 4)];
    vec4 ray_position_worldspace = start_pos_worldspace + dither_value * step_size_worldspace * delta_worldspace;

    float light_contribution = 0.0;
    for (float l = raymarch_distance_worldspace; l > step_size_worldspace; l -= step_size_worldspace) {
        
        vec3 cm_lookup_vec = ray_position_worldspace.xyz - pointLight[lightID].mPosition;

        float shadowCoefficient = 1.0;

        float d_S = length(cm_lookup_vec);
        
        
        float d_L;

        //Can not access Array of Samplers with loop variable!!
        //see https://community.khronos.org/t/glsl-dynamic-looping/52133/13
        //Works now with CubeMapArray
        d_L = texture(shadowMapArray, vec4(cm_lookup_vec, shadowmapID)).r;
        d_L = d_L * (pointLight[lightID].near_far.y - pointLight[lightID].near_far.x) + pointLight[lightID].near_far.x;
        float eps = 0.15;

        if (d_L + eps < d_S) {
            shadowCoefficient = 0.0;
        }
              
        float d_rcp = 1.0 / d_S;

        float attenuation = 1.0 / (pointLight[lightID].mAttenuationConstant + pointLight[lightID].mAttenuationLinear * d_S + pointLight[lightID].mAttenuationQuadratic * (d_S * d_S));
        
        float fog = triNoise3d(ray_position_worldspace.xyz * 2.2 / 8.0, 0.2, frameTime);
        light_contribution += fog * attenuation * tau * (shadowCoefficient * (phi * 0.25 * PI_RCP) * d_rcp * d_rcp) * exp(-d_S * tau) * exp(-l * tau) * step_size_worldspace;
        
        ray_position_worldspace += step_size_worldspace * delta_worldspace;
    }
    return min(light_contribution, 1.0);
}

//Not working yet
float volumetric_directional_light(vec3 frag_pos) {

    float phi = 0.7;
    float tau = 0.8;
    //TODO check position
    vec3 light_position = vec3(10.0f, 10.0f, 10.0f);

    vec4 end_pos_worldspace = vec4(view_pos, 1.0);
    vec4 start_pos_worldspace = vec4(frag_pos, 1.0);

    //vec4 end_pos_lightview = light_view_matrix * end_pos_worldspace;
    //vec4 start_pos_lightview = light_view_matrix * start_pos_worldspace;

    //vec4 delta_lightview = normalize(end_pos_lightview - start_pos_lightview);
    vec4 delta_worldspace = normalize(end_pos_worldspace - start_pos_worldspace);

    //float raymarch_distance_lightview = length(end_pos_lightview - start_pos_lightview);
    float raymarch_distance_worldspace = length(end_pos_worldspace - start_pos_worldspace);

    //float step_size_lightview = raymarch_distance_lightview / num_samples;
    int numsamples = 400;
    float step_size_worldspace = raymarch_distance_worldspace / numsamples;

    //vec4 ray_position_lightview = start_pos_lightview;
    vec4 ray_position_worldspace = start_pos_worldspace;

    float light_contribution = 0.0;
    for (float l = raymarch_distance_worldspace; l > step_size_worldspace; l -= step_size_worldspace) {
        
        /**
        /
        vec4 ray_position_lightspace = light_projection_matrix * vec4(ray_position_lightview.xyz, 1);

        //perspective divide
        vec3 proj_coords = ray_position_lightspace.xyz / ray_position_lightspace.w;

        // transform to [0,1] range
        proj_coords = proj_coords * 0.5 + 0.5;

        //Checkshadow
        vec4 closest_depth;
        DIRECTIONAL_SHADOW_MAP(texture, light.shadow_map_index, proj_coords.xy, closest_depth)
         **/

        float shadow_term = 1.0;

        //if (proj_coords.z - light.bias > closest_depth.r) {
        //    shadow_term = 0.0;
        //}

        //float d = length(ray_position_worldspace.xyz - light_position);
        float d = 0.1;
        float d_rcp = 1.0 / d;
        float pi_rcp = 0.3183098;
        
        light_contribution += tau * (shadow_term * (phi * 0.25 * pi_rcp) * d_rcp * d_rcp) * exp(-d * tau) * exp(-l * tau) * step_size_worldspace;

        //ray_position_lightview += step_size_lightview * delta_lightview;
        ray_position_worldspace += step_size_worldspace * delta_worldspace;
        
    }
    return min(light_contribution, 1.0);
}


//Taken from Revision Course Appendix
vec3 world_pos_from_depth(float depth) {
    //helpful: https://learnopengl.com/Getting-started/Coordinate-Systems
    //https://computergraphics.stackexchange.com/questions/6087/screen-space-coordinates-to-eye-space-conversion#:~:text=You%20get%20from%20World%20Space,w%20in%20clip%20space%20coordinates).
    
    //"Hack" to make it work with skybox
    if (depth > 0.9999999) {
        depth = 0.999;
    }
    //Screen Space to Clip Space
    float z = depth * 2.0 - 1.0;
    vec4 clip_space_position = vec4(TexCoords * 2.0 - 1.0, z, 1.0);

    //Clip Space to View Space
    vec4 view_space_position = projection_inv * clip_space_position;

    // Perspective divide
    view_space_position /= view_space_position.w;

    //Clip Space to View Space
    vec4 world_space_position = view_inv * view_space_position;
    return world_space_position.xyz;
}
