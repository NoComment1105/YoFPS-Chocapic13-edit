#version 120

/*
!! DO NOT REMOVE !!
This code is from Chocapic13' shaders
Read the terms of modification and sharing before changing something below please !
!! DO NOT REMOVE !!
*/

const int GL_EXP = 2048;
const int GL_LINEAR = 9729;

varying vec2 lmcoord;
varying vec4 color;
varying float mat;
varying vec2 texcoord;
varying vec3 normal;

uniform sampler2D texture;
uniform vec3 sunPosition;
uniform vec3 moonPosition;
uniform int worldTime;
uniform float wetness;




//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////

void main() {
	vec2 adjustedTexCoord = texcoord;

	vec4 c = mix(color, vec4(1.0), float(mat > 0.58 && mat < 0.62));		//fix weird lightmap bug on emissive blocks
/* DRAWBUFFERS:04 */

	gl_FragData[0] = texture2D(texture, texcoord) * c;
	gl_FragData[1] = vec4(lmcoord.t, mat, lmcoord.s, 1.0);
}