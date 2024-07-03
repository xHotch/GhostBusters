#version 430 core

in vec2 TexCoords;
out vec4 color;

uniform sampler2D tex;

uniform int horizontal;

const int M = 5;

//taken from https://www.shadertoy.com/view/3stGWl
float Luminance(vec3 rgb)
{
    return dot(rgb, vec3(0.2125, 0.7154, 0.0721));
}

float gaussian(float x, float sigma) {
    float sig2 = sigma * sigma;
    return (1.0 / sqrt(2.0 * 3.141592 * sig2)) * exp((-x * x) / (2.0 * sig2));
}

// sigma = 10 http://demofox.org/gauss.html not in use
//const float coeffs[M + 1] = float[M + 1](0.3829, 0.2417, 0.0606, 0.0060, 0.0002);

// sigma = 3 http://demofox.org/gauss.html
//const float coeffs[M + 1] = float[M + 1](0.1365, 0.1292, 0.1095, 0.0832, 0.0566, 0.0345, 0.0188);

//Inspired by https://lisyarus.github.io/blog/graphics/2022/04/21/compute-blur.html https://www.rastergrid.com/blog/2010/09/efficient-gaussian-blur-with-linear-sampling/
void main()
{
    vec2 direction;
    if (horizontal==0) {
        direction = vec2(1.0 / textureSize(tex, 0).x, 0.);
    }
    else {
        direction = vec2(0., 1.0 / textureSize(tex, 0).y);
    }
    vec4 original_value = texture(tex, TexCoords);
    vec4 sum = vec4(0);
    float weightSum = 0;
    for (int i = -M; i < M; i += 1)
    {

        vec4 tex_value = texture(tex, TexCoords + direction * float(i));

        float gaussDistance = 1.0;
        float depthDiff = gaussian(abs(original_value.w - tex_value.w), 0.0008);
        gaussDistance = gaussian(i, M*0.2);
        //colorDiff = 1.0;
        weightSum += depthDiff * gaussDistance;

        sum += gaussDistance * tex_value * depthDiff;

    }
    color = sum / weightSum;
}



