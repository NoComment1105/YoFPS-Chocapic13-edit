#version 120

/*
!! DO NOT REMOVE !!
This code is from Chocapic13' shaders
Read the terms of modification and sharing before changing something below please !
!! DO NOT REMOVE !!
*/

//////////////////////////////ADJUSTABLE VARIABLES
//////////////////////////////ADJUSTABLE VARIABLES
//////////////////////////////ADJUSTABLE VARIABLES

#define WAVING_GRASS
#define WAVING_FLOWERS
#define WAVING_LEAVES
#define WAVING_FUNGI
#define WAVING_VINES
#define WAVING_FIRE

float GRASS_WAVE_SPEED   = 1.2;   // DEFAULT: 1.2
float FLOWERS_WAVE_SPEED = 0.9;   // DEFAULT: 0.9
float LEAVES_WAVE_SPEED  = 0.75;  // DEFAULT: 0.75
float FUNGI_WAVE_SPEED   = 0.7;   // DEFAULT: 0.7
float VINES_WAVE_SPEED   = 0.75;  // DEFAULT: 0.75 (I reccomend this is the same as leaves, or there is <0.2 difference in value)
float FIRE_WAVE_SPEED    = 1.1;   // DEFAULT: 1.0

//////////////////////////////END OF ADJUSTABLE VARIABLES
//////////////////////////////END OF ADJUSTABLE VARIABLES
//////////////////////////////END OF ADJUSTABLE VARIABLES

#define ENTITY_GRASS	 1.0  // Includes short and tall grass, fern and nether roots
#define ENTITY_FLOWERS	 2.0  // All flowers in minecraft
#define ENTITY_LEAVES    3.0  // Includes all leaves (excludes wart blocks for nether trees)
#define ENTITY_FUNGI	 4.0  // MUSHROOMS (including nether ones)
#define ENTITY_VINES     5.0  // All vines + nether ones.
#define ENTITY_FIRE      6.0  // Fire

const float PI = 3.141592654;

varying vec4 color;
varying vec2 lmcoord;
varying float mat;
varying vec2 texcoord;

varying vec3 normal;

attribute vec4 mc_Entity;
attribute vec4 mc_midTexCoord;

uniform vec3 upPosition;
uniform vec3 sunPosition;
uniform vec3 cameraPosition;
uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;
uniform int worldTime;
uniform float frameTimeCounter;
uniform float rainStrength;

float pi2wt = PI * 2 * (frameTimeCounter * 24);

vec3 calcWave(in vec3 pos, in float fm, in float mm, in float ma, in float f0, in float f1, in float f2, in float f3, in float f4, in float f5) {
    vec3 ret;
    float magnitude, d0, d1, d2, d3;
    magnitude = sin(pi2wt * fm + pos.x * 0.5 + pos.z * 0.5 + pos.y * 0.5) * mm + ma;
    d0 = sin(pi2wt * f0);
    d1 = sin(pi2wt * f1);
    d2 = sin(pi2wt * f2);
    ret.x = sin(pi2wt * f3 + d0 + d1 - pos.x + pos.z + pos.y) * magnitude;
    ret.z = sin(pi2wt * f4 + d1 + d2 + pos.x - pos.z + pos.y) * magnitude;
	ret.y = sin(pi2wt * f5 + d2 + d0 + pos.z + pos.y - pos.y) * magnitude;
    return ret;
}

vec3 calcMove(in vec3 pos, in float f0, in float f1, in float f2, in float f3, in float f4, in float f5, in vec3 amp1, in vec3 amp2) {
    vec3 move1 = calcWave(pos      , 0.0027, 0.0400, 0.0400, 0.0127, 0.0089, 0.0114, 0.0063, 0.0224, 0.0015) * amp1;
	vec3 move2 = calcWave(pos+move1, 0.0348, 0.0400, 0.0400, f0, f1, f2, f3, f4, f5) * amp2;
    return move1 + move2;
}

vec3 calcWaterMove(in vec3 pos) {
	float fy = fract(pos.y + 0.001);
	if (fy > 0.002) {
		float wave = 0.05 * sin(2 * PI / 4 * frameTimeCounter + 2 * PI * 2 / 16 * pos.x + 2 * PI * 5 / 16 * pos.z)
				   + 0.05 * sin(2 * PI / 3 * frameTimeCounter - 2 * PI * 3 / 16 * pos.x + 2 * PI * 4 / 16 * pos.z);
		return vec3(0, clamp(wave, -fy, 1.0 - fy), 0);
	} else {
		return vec3(0);
	}
}

//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////

void main() {
	vec4 vtexcoordam;
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).st;
	vec2 midcoord = (gl_TextureMatrix[0] *  mc_midTexCoord).st;
	vec2 texcoordminusmid = texcoord  -midcoord;
	vtexcoordam.pq  = abs(texcoordminusmid) * 2;
	vtexcoordam.st  = min(texcoord, midcoord - texcoordminusmid);
	vec2 vtexcoord    = sign(texcoordminusmid) * 0.5 + 0.5;
	mat = 1.0f;
	float istopv = 0.0;
	//texcoord = gl_MultiTexCoord0.xy;
	if (gl_MultiTexCoord0.t < mc_midTexCoord.t) {
		istopv = 1.0;
	}
	/* un-rotate */
	vec4 position = gbufferModelViewInverse * gl_ModelViewMatrix * gl_Vertex;
	vec3 worldpos = position.xyz + cameraPosition;
	/*
	//initialize per-entity waving parameters
	float parm0,parm1,parm2,parm3,parm4,parm5 = 0.0;
	vec3 ampl1,ampl2;
	ampl1 = vec3(0.0);
	ampl2 = vec3(0.0);
	*/

	//////////////////// WAVING OBJECTS ////////////////////
	//////////////////// WAVING OBJECTS ////////////////////
	//////////////////// WAVING OBJECTS ////////////////////

	#ifdef WAVING_LEAVES
		if ( mc_Entity.x == ENTITY_LEAVES ) {
			position.xyz += calcMove(worldpos.xyz, 0.0040, 0.0064, 0.0043, 0.0035, 0.0037, 0.0041, vec3(0.9, 0.15, 0.9), vec3(0.4, 0.05, 0.4)) * LEAVES_WAVE_SPEED;
		}
	#endif
	#ifdef WAVING_VINES
		if ( mc_Entity.x == ENTITY_VINES ) {
			position.xyz += calcMove(worldpos.xyz, 0.0040, 0.0064, 0.0043, 0.0035, 0.0037, 0.0041, vec3(0.9, 0.15, 0.9), vec3(0.4, 0.05, 0.4)) * VINES_WAVE_SPEED;
		}
	#endif
	if (istopv > 0.9) {
	#ifdef WAVING_GRASS
		if ( mc_Entity.x == ENTITY_GRASS ) {
			position.xyz += calcMove(worldpos.xyz, 0.0041, 0.0070, 0.0044, 0.0038, 0.0063, 0.0000, vec3(0.8, 0.0, 0.8), vec3(0.4, 0.0, 0.4)) * GRASS_WAVE_SPEED;
		}
	#endif
	#ifdef WAVING_FLOWERS
		if (mc_Entity.x == ENTITY_FLOWERS ) {
			position.xyz += calcMove(worldpos.xyz, 0.0041, 0.005, 0.0044, 0.0038, 0.0240, 0.0000, vec3(0.8, 0.0, 0.8), vec3(0.4, 0.0, 0.4)) * FLOWERS_WAVE_SPEED;
		}
	#endif
	#ifdef WAVING_FIRE
		if ( mc_Entity.x == ENTITY_FIRE ) {
			position.xyz += calcMove(worldpos.xyz, 0.0105, 0.0096, 0.0087, 0.0063, 0.0097, 0.0156, vec3(1.3, 0.5, 1.3), vec3(0.9, 0.9, 0.9)) * FIRE_WAVE_SPEED;
		}
	#endif
	#ifdef WAVING_FUNGI
		if ( mc_Entity.x == ENTITY_FUNGI ) {
			position.xyz += calcMove(worldpos.xyz, 0.0001, 0.0001, 0.0001, 0.0000, 0.0001, 0.0001, vec3(0.8, 0.5, 0.4), vec3(0.8, 0.3, 0.6)) * FUNGI_WAVE_SPEED;
		}
	#endif
	}

	//////////////////// END OF WAVING OBJECTS ////////////////////
	//////////////////// END OF WAVING OBJECTS ////////////////////
	//////////////////// END OF WAVING OBJECTS ////////////////////

	float translucent = 1.0;
	if (mc_Entity.x == ENTITY_LEAVES || mc_Entity.x == ENTITY_VINES || mc_Entity.x == ENTITY_FLOWERS || mc_Entity.x == 30.0 || mc_Entity.x == 175.0	
	|| mc_Entity.x == 115.0 || mc_Entity.x == 32.0) {
		mat = 0.2;
		translucent = 0.5;
	}
	/* projectify */
	gl_Position = gl_ProjectionMatrix * gbufferModelView * position;
	
	color = gl_Color;
	
	lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	normal = normalize(gl_NormalMatrix * gl_Normal);
	
	float ndotl = dot(normalize(sunPosition), normal);
	float ndotup = dot(normalize(upPosition), normal);
	
	float SdotU = dot(normalize(sunPosition), normalize(upPosition));
	float sunVisibility = pow(clamp(SdotU + 0.1, 0.0, 0.1) / 0.1, 2.0);
	
	float t1 = mix(mix(-ndotl, ndotl, sunVisibility), 1.0, rainStrength * 0.8);
	
	float lmult = 0.5 * (sqrt((ndotup * 0.45) + 0.55) + ((t1 * 0.47) + 0.53));
	lmult = mix(1.0, pow(lmult, 0.33), translucent);
	lmcoord.t *= lmult;
}