#version 430 core

uniform sampler2D depthTexture;

in vec2 TexCoordsLeftTop;
in vec2 TexCoordsRightTop;
in vec2 TexCoordsLeftBottom;
in vec2 TexCoordsRightBottom;

void main() {

	float top_left = texture(depthTexture, TexCoordsLeftTop).x;
	float top_right = texture(depthTexture, TexCoordsRightTop).x;
	float bottom_left = texture(depthTexture, TexCoordsLeftBottom).x;
	float bottom_right = texture(depthTexture, TexCoordsRightBottom).x;

	gl_FragDepth = min(min(top_left, top_right), min(bottom_left, bottom_right));
}
