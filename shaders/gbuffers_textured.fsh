#version 120

/*
!! DO NOT REMOVE !!
This code is from Chocapic13' shaders
Read the terms of modification and sharing before changing something below please !
!! DO NOT REMOVE !!
*/
const int GL_LINEAR = 9729;
const int GL_EXP = 2048;

varying vec4 color;
varying vec4 texcoord;
varying vec3 normal;

uniform sampler2D texture;
uniform int fogMode;

//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////

void main() {
	
/* DRAWBUFFERS:0 */
	gl_FragData[0] = texture2D(texture,texcoord.xy)*color;
}