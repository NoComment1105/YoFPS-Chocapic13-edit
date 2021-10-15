#version 120

/*
!! DO NOT REMOVE !!
This code is from Chocapic13' shaders
Read the terms of modification and sharing before changing something below please !
!! DO NOT REMOVE !!
*/

varying vec4 color;
varying vec2 texcoord;
varying vec2 lmcoord;
varying vec3 normal;

attribute vec4 mc_Entity;

uniform vec3 upPosition;
uniform vec3 sunPosition;
uniform vec3 cameraPosition;
uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;
uniform int worldTime;
uniform float frameTimeCounter;
uniform float rainStrength;

//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////

void main() {
	
	texcoord = (gl_MultiTexCoord0).xy;
	lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	
	gl_Position = ftransform();
	
	color = gl_Color;
	
	normal = normalize(gl_NormalMatrix * gl_Normal);
	
	float ndotl = dot(normalize(sunPosition),normal);
	float ndotup = dot(normalize(upPosition),normal);
	
	float SdotU = dot(normalize(sunPosition),normalize(upPosition));
	float sunVisibility = pow(clamp(SdotU+0.1,0.0,0.1)/0.1,2.0);
	
	float t1 = mix(mix(-ndotl,ndotl,sunVisibility),1.0,rainStrength*0.85);
	
	float lmult = 0.5*(sqrt(ndotup*0.45+0.55)+(t1*0.47+0.53));
	lmult = pow(lmult,0.3);
	lmcoord.t *= lmult;
}