#version 430 core
layout(location = 0) in vec2 aPos;
layout(location = 1) in vec2 aTexCoords;

layout(binding = 1) uniform sampler2D depthTexture;

out vec2 TexCoords;
out vec2 TexCoordsLeftTop;
out vec2 TexCoordsRightTop;
out vec2 TexCoordsLeftBottom;
out vec2 TexCoordsRightBottom;

//Taken from ezg17-transition
void main()
{
    vec2 texel_size = 1.0 / textureSize(depthTexture, 0);
    TexCoordsLeftTop = aTexCoords - 0.5 * texel_size;
    TexCoordsRightTop = TexCoordsLeftTop + vec2(texel_size.x, 0);
    TexCoordsLeftBottom = TexCoordsLeftTop + vec2(0, texel_size.y);
    TexCoordsRightBottom = TexCoordsLeftTop + texel_size;

    gl_Position = vec4(aPos.x, aPos.y, 0.0, 1.0);
    TexCoords = aTexCoords;
}