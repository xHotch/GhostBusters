#version 430 core
out vec4 FragColor;

in vec2 TexCoords;

layout(binding = 0) uniform sampler2D screenTexture;
layout(binding = 1) uniform sampler2D depthTexture;
layout(binding = 7) uniform sampler2D volumetricLightTexture;

uniform bool useVolumetric;

in vec2 TexCoordsCenter;
in vec2 TexCoordsLeftTop;
in vec2 TexCoordsRightTop;
in vec2 TexCoordsLeftBottom;
in vec2 TexCoordsRightBottom;


//Nearest Depth upsampling: https://developer.download.nvidia.com/assets/gamedev/files/sdk/11/OpacityMappingSDKWhitePaper.pdf
void main()
{

    vec4 scene_color = texture(screenTexture, TexCoords);
    if (useVolumetric) {
        

        float depth = texture(depthTexture, TexCoords).r;

        //Get the 4 values from the low resolution texture
        vec4 volumetric_tex_left_top = texture(volumetricLightTexture, TexCoordsLeftTop);
        vec4 volumetric_tex_right_top = texture(volumetricLightTexture, TexCoordsRightTop);
        vec4 volumetric_tex_left_bottom = texture(volumetricLightTexture, TexCoordsLeftBottom);
        vec4 volumetric_tex_right_bottom = texture(volumetricLightTexture, TexCoordsRightBottom);

        //Compare which depth value is closest to the high resolution depth
        vec4 depthVec = vec4(depth);
        vec4 depthVecLowResolution = vec4(volumetric_tex_left_top.w, volumetric_tex_right_top.w, volumetric_tex_left_bottom.w, volumetric_tex_right_bottom.w);

        vec4 diffDepthVec = abs(depthVec - depthVecLowResolution);

        //Chose the color from the nearest Depth
        float minDepth = diffDepthVec[0];
        vec3 chosenValue = volumetric_tex_left_top.xyz;

        if (diffDepthVec[1] < minDepth) {
            chosenValue = volumetric_tex_right_top.xyz;
            minDepth = diffDepthVec[1];
        }
        if (diffDepthVec[2] < minDepth) {
            chosenValue = volumetric_tex_left_bottom.xyz;
            minDepth = diffDepthVec[2];
        }
        if (diffDepthVec[3] < minDepth) {
            chosenValue = volumetric_tex_right_bottom.xyz;
        }

        FragColor = scene_color + vec4(chosenValue, 1);
    }
    else {
        FragColor = scene_color;
    }

    //https://learnopengl.com/Advanced-Lighting/HDR
    const float gamma = 2.2;

    // reinhard tone mapping
    vec3 mapped = FragColor.xyz;
    mapped = mapped / (mapped + vec3(1.0));
    // gamma correction 
    mapped = pow(mapped, vec3(1.0 / gamma));

    FragColor = vec4(mapped, FragColor.w);
}