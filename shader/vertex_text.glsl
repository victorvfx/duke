#version 330

layout (location = 0) in vec3 Position;
layout (location = 1) in vec2 UV;

uniform ivec2 gViewport;
uniform ivec2 gImage;
uniform ivec2 gPan;
uniform int gChar;

out vec2 vVaryingTexCoord; 

mat4 ortho(int left, int right, int bottom, int top) {
	mat4 Result;
	Result[0][0] = float(2) / (right - left);
	Result[1][1] = float(2) / (top - bottom);
	Result[2][2] = - float(1);
	Result[3][3] = 1;
	Result[3][0] = - (right + left) / (right - left);
	Result[3][1] = - (top + bottom) / (top - bottom);
	return Result;
}

mat4 translate(mat4 m, vec3 v) {
	mat4 Result = mat4(m);
	Result[3] = m[0] * v[0] + m[1] * v[1] + m[2] * v[2] + m[3];
	return Result;
}

mat4 scale(mat4 m, vec3 v) {
	mat4 Result = mat4(m);
	Result[0] = m[0] * v[0];
	Result[1] = m[1] * v[1];
	Result[2] = m[2] * v[2];
	Result[3] = m[3];
	return Result;
}

void main() {
	const ivec2 tiles = ivec2(16);
	ivec2 translating = ivec2(0); // translation must be integer to prevent aliasing
	translating /= 2; // moving to center
	translating += gPan; // moving to center
	vec2 scaling = vec2(1);
	scaling /= 2; // bringing square from [-1,1] to [-.5,.5]
	scaling /= tiles; // to pixel dimension
	scaling *= gImage; // to pixel dimension
	mat4 world = mat4(1);
	world = translate(world, vec3(translating, 0)); // move to center
	world = scale(world, vec3(scaling, 1));
	mat4 proj = ortho(0, gViewport.x, 0, gViewport.y);
	mat4 worldViewProj = proj * world;
	gl_Position = worldViewProj * vec4(Position, 1.0);
	ivec2 charDim = abs(gImage) / tiles;
	ivec2 charPos = ivec2(gChar%tiles.x, gChar/tiles.y);
	vVaryingTexCoord = charDim*(UV+charPos);
}