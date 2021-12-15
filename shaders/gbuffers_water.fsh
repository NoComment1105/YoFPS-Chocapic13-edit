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

vec4 watercolor = vec4(0.09, 0.7, 0.625, 0.15); 	//water color and opacity (r,g,b,opacity)

//////////////////////////////END OF ADJUSTABLE VARIABLES
//////////////////////////////END OF ADJUSTABLE VARIABLES
//////////////////////////////END OF ADJUSTABLE VARIABLES

const float PI = 3.1415927;

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
uniform mat4 gbufferModelViewInverse;
uniform sampler2D depthtex1;
uniform sampler2D gaux1;

float rainx = clamp(rainStrength, 0.0f, 1.0f) / 1.0f;

vec2 dx = dFdx(texcoord.xy);
vec2 dy = dFdy(texcoord.xy);

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
		wave -= d * factor * cos((1 / factor) * px * py * size + 0.5 * frameTimeCounter * speed);
		factor /= 2;
	}

	factor = 1.0;
	px = -posxz.x / 50.0 + 250.0;
	py = -posxz.z / 150 - 250.0;

	fpx = abs(fract(px * 20.0) - 0.5) * 2.0;
	fpy = abs(fract(py * 20.0) - 0.5) * 2.0;

	d = length(vec2(fpx, fpy));
	float wave2 = 0.0;

	for (int i = 0; i < 3; i++) {
		wave2 -= d * factor * cos((1 / factor) * px * py * size + 0.75 * frameTimeCounter * speed);
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
	
	if (iswater < 0.9) {
		tex = texture2D(texture, texcoord.xy) * color;
	}
	
	vec4 frag2;
	frag2 = vec4((normal) * 0.5f + 0.5f, 1.0f);
		
	vec2 newTC = texcoord.st;
	vec3 fragpos = vec3(newTC.st, texture2D(depthtex1, newTC.st).r);
	vec4 worldposition = gbufferModelViewInverse * vec4(fragpos, 1.0);	

	if (iswater > 0.9) {
		vec3 posxz = worldposition.xyz + cameraPosition;
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
	
		vec3 refract = normalize(vec3(nX, nY, 1.0));

		float refMult = 0.005 - dot(normal, normalize(fragpos).xyz) * 0.003;

		float mask = texture2D(gaux1, newTC.st + refract.xy*refMult).g;
		mask =  float(mask > 0.04 && mask < 0.07);
		newTC = (newTC.st + refract.xy*refMult)*mask + newTC.xy*(1-mask);

	}

	gl_FragData[0] = tex;
	gl_FragData[1] = frag2;	
	gl_FragData[2] = vec4(lmcoord.t, mix(1.0, 0.05, iswater), lmcoord.s, 1.0);
}