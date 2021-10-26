#version 120

/*
!! DO NOT REMOVE !!
This code is from Chocapic13' shaders
Read the terms of modification and sharing before changing something below please !
!! DO NOT REMOVE !!
*/

const int GL_EXP = 2048;
const int GL_LINEAR = 9729;

varying vec4 color;
varying vec2 texcoord;
varying vec2 lmcoord;


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
	
	vec2 adjustedTexCoord = texcoord.st;
	vec3 albedo = texture2D(texture, adjustedTexCoord).rgb * color.rgb;


/* DRAWBUFFERS:04 */
	gl_FragData[0] = vec4(albedo, texture2D(texture, adjustedTexCoord).a * color.a);
	gl_FragData[1] = vec4(lmcoord.t, 0.91, lmcoord.s, 1.0);
}