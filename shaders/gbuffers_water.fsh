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

float wave(float n) {
return sin(2 * PI * (n));
}

float waterH(vec3 posxz) {

float wave = 0.0;


float factor = 1.0;
float amplitude = 0.2;
float speed = 4.0;
float size = 0.2;

float px = posxz.x / 50.0 + 250.0;
float py = posxz.z / 50.0 + 250.0;

float fpx = abs(fract(px * 20.0) - 0.5) * 2.0;
float fpy = abs(fract(py * 20.0) - 0.5) * 2.0;

float d = length(vec2(fpx, fpy));

for (int i = 0; i < 3; i++) {
	wave -= d * factor * cos((1 / factor) * px * py * size + 1.0 * frameTimeCounter * speed);
	factor /= 2;
}

factor = 1.0;
px = -posxz.x / 50.0 + 250.0;
py = -posxz.z / 150.0 - 250.0;

fpx = abs(fract(px * 20.0) - 0.5) * 2.0;
fpy = abs(fract(py * 20.0) - 0.5) * 2.0;

d = length(vec2(fpx, fpy));
float wave2 = 0.0;
for (int i = 0; i < 3; i++) {
	wave2 -= d * factor * cos((1 / factor) * px * py * size + 1.0 * frameTimeCounter * speed);
	factor /= 2;
}

return amplitude * wave2 + amplitude * wave;
}

//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////

void main() {	
	
	vec4 tex = vec4((watercolor * length(texture2D(texture, texcoord.xy).rgb * color.rgb) * color).rgb, watercolor.a);
	if (iswater < 0.9)  
			tex = texture2D(texture, texcoord.xy) * color;
	
	vec3 posxz = wpos.xyz;

	posxz.x += sin(posxz.z + frameTimeCounter) * 0.25;
	posxz.z += cos(posxz.x + frameTimeCounter * 0.5) * 0.25;
	
	float deltaPos = 0.4;
	float h0 = waterH(posxz);
	float h1 = waterH(posxz - vec3(deltaPos, 0.0, 0.0));
	float h2 = waterH(posxz - vec3(0.0, 0.0, deltaPos));
	
	float dX = ((h0 - h1)) / deltaPos;
	float dY = ((h0 - h2)) / deltaPos;
	
	float nX = sin(atan(dX));
	float nY = sin(atan(dY));
	
	vec3 newnormal = normalize(vec3(nX, nY, 1.0));
	
	vec4 frag2;
		frag2 = vec4((normal) * 0.5f + 0.5f, 1.0f);		
		
	// if (iswater > 0.9) {
	// 	vec3 bump = newnormal;
	// 		bump = bump;
			
		
	// 	float bumpmult = 0.05;	
		
	// 	bump = bump * vec3(bumpmult, bumpmult, bumpmult) + vec3(0.0f, 0.0f, 1.0f - bumpmult);
	// 	mat3 tbnMatrix = mat3(tangent.x, binormal.x, normal.x,
	// 						tangent.y, binormal.y, normal.y,
	// 						tangent.z, binormal.z, normal.z);
		
	// 	frag2 = vec4(normalize(bump * tbnMatrix) * 0.5 + 0.5, 1.0);
	// }
	gl_FragData[0] = tex;
	gl_FragData[1] = frag2;	
	gl_FragData[2] = vec4(lmcoord.t, mix(1.0, 0.05, iswater), lmcoord.s, 1.0);
}