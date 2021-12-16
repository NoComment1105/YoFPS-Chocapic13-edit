#version 120

/*
!! DO NOT REMOVE !!
This code is from Chocapic13' shaders
Read the terms of modification and sharing before changing something below please !
!! DO NOT REMOVE !!
*/

varying vec4 color;
varying vec4 texcoord;
varying vec4 lmcoord;

uniform sampler2D texture;

uniform float rainStrength;

float rainx = clamp(rainStrength, 0.0f, 1.0f) / 1.0f;

//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////

void main() {
	
	vec4 tex = texture2D(texture, texcoord.st);
	
/* DRAWBUFFERS:04 */
	
	vec3 indlmap = texture2D(texture, texcoord.xy).rgb * color.rgb;
	
	gl_FragData[0] = vec4(indlmap, texture2D(texture, texcoord.xy).a * color.a);
	
	//x = specularity / y = land(0.0 / 1.0) / shadow early exit(0.2) / water(0.05) / z = torch lightmap
	
	gl_FragData[1] = vec4(lmcoord.t, 1.0, lmcoord.s, 1.0);
}