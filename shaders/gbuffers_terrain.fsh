#version 120

/*
!! DO NOT REMOVE !!
This code is from Chocapic13' shaders
Read the terms of modification and sharing before changing something below please !
!! DO NOT REMOVE !!
*/

#define NORMAL_MAP_MAX_ANGLE 1.0
#define POM
#define POM_MAP_RES 128.0
#define POM_DEPTH 0.1

/* Here, intervalMult might need to be tweaked per texture pack.  
   The first two numbers determine how many samples are taken per fragment.  They should always be the equal to eachother.
   The third number divided by one of the first two numbers is inversely proportional to the range of the height-map. */
const vec3 intervalMult = vec3(1.0, 1.0, 1.0 / POM_DEPTH) / POM_MAP_RES; 

const float MAX_OCCLUSION_DISTANCE = 22.0;
const float MIX_OCCLUSION_DISTANCE = 18.0;

const int   MAX_OCCLUSION_POINTS   = 50;
const int GL_EXP = 2048;
const int GL_LINEAR = 9729;

const float bump_distance = 64.0;		//bump render distance: tiny = 32, short = 64, normal = 128, far = 256
const float pom_distance = 32.0;		//POM render distance: tiny = 32, short = 64, normal = 128, far = 256
const float fademult = 0.1;

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