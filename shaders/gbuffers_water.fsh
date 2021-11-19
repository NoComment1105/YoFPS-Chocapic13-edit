#version 120
/*
!! DO NOT REMOVE !!
This code is from Chocapic13' shaders
Read the terms of modification and sharing before changing something below please !
!! DO NOT REMOVE !!
*/

/* DRAWBUFFERS:024 */

//////////////////////////////ADJUSTABLE VARIABLES
//////////////////////////////ADJUSTABLE VARIABLES
//////////////////////////////ADJUSTABLE VARIABLES

	#define MIX_TEX 0.7	
	vec4 watercolor = vec4(0.09, 0.7, 0.625, 0.15); 	//water color and opacity (r,g,b,opacity)

//////////////////////////////END OF ADJUSTABLE VARIABLES
//////////////////////////////END OF ADJUSTABLE VARIABLES
//////////////////////////////END OF ADJUSTABLE VARIABLES

const int   MAX_OCCLUSION_POINTS   = 20;
const float MAX_OCCLUSION_DISTANCE = 100.0;
const float bump_distance          = 32.0;		//Bump render distance: tiny = 32, short = 64, normal = 128, far = 256
const float pom_distance           = 32.0;		//POM render distance: tiny = 32, short = 64, normal = 128, far = 256
const float fademult               = 0.1;
const float PI                     = 3.1415927;

varying vec4 color;
varying vec2 texcoord;
varying vec2 lmcoord;
varying vec3 binormal;
varying vec3 normal;
varying vec3 tangent;
varying vec3 wpos;
varying float iswater;

uniform sampler2D texture;
uniform sampler2D noisetex;
uniform int worldTime;
uniform float far;
uniform float rainStrength;
uniform float frameTimeCounter;
uniform vec3 cameraPosition;

float rainx = clamp(rainStrength, 0.0f, 1.0f) / 1.0f;

vec2 dx = dFdx(texcoord.xy);
vec2 dy = dFdy(texcoord.xy);


//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////

void main() {	
	
	vec4 tex = vec4((watercolor * length(texture2D(texture, texcoord.xy).rgb * color.rgb) * color).rgb, watercolor.a);
	
	if (iswater < 0.9) {
		tex = texture2D(texture, texcoord.xy) * color;
	}
	
	vec4 frag2;
		frag2 = vec4((normal) * 0.5f + 0.5f, 1.0f);
		

	gl_FragData[0] = tex;
	gl_FragData[1] = frag2;	
	gl_FragData[2] = vec4(lmcoord.t, mix(1.0, 0.05, iswater), lmcoord.s, 1.0);
}