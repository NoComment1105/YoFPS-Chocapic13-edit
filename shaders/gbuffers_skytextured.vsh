#version 120

/*
!! DO NOT REMOVE !!
This code is from Chocapic13' shaders
Read the terms of modification and sharing before changing something below please !
!! DO NOT REMOVE !!
*/

varying vec4 color;
varying vec2 texcoord;

//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////

void main() {
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).st;

	color = gl_Color;

	vec4 viewVertex = gl_ModelViewMatrix * gl_Vertex;

	gl_Position = gl_ProjectionMatrix * viewVertex;
	
	gl_FogFragCoord = 1.0;
	//gl_FogFragCoord = distance*sqrt(3.0);
}
