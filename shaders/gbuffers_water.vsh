#version 120

/*
!! DO NOT REMOVE !!
This code is from Chocapic13' shaders
Read the terms of modification and sharing before changing something below please !
!! DO NOT REMOVE !!
*/

#include "/lib/common.glsl"

#define WATER 7.0 //Define water in block.properties

varying vec4 color;
varying vec2 texcoord;
varying vec2 lmcoord;
varying vec3 normal;
varying vec3 wpos;
varying float iswater;

attribute vec4 mc_Entity;

uniform vec3 cameraPosition;
uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;
uniform int worldTime;
uniform float frameTimeCounter;
uniform int isEyeInWater;

const float PI = 3.1415927;

//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////

void main() {

    vec4 position = gl_ModelViewMatrix * gl_Vertex;
    iswater = 0.0f;
    float displacement = 0.0;

    /* un-rotate */
    vec4 viewpos = gbufferModelViewInverse * position;

    vec3 worldpos = viewpos.xyz + cameraPosition;
    wpos = worldpos;

    if (mc_Entity.x == WATER) {
        iswater = 1.0;
        float fy = fract(worldpos.y + 0.001);

        #ifdef WAVING_WATER
            float wave = 0.05 * sin(2 * PI * (frameTimeCounter * 0.75 + worldpos.x /  7.0 + worldpos.z / 13.0))
                       + 0.05 * sin(2 * PI * (frameTimeCounter * 0.6 + worldpos.x / 11.0 + worldpos.z /  5.0));
            displacement = clamp(wave, -fy, 1.0 - fy);
            viewpos.y += displacement * 0.5;
        #endif
    }

    /* re-rotate */
    viewpos = gbufferModelView * viewpos;

    /* projectify */
    gl_Position = gl_ProjectionMatrix * viewpos;

    color = gl_Color;

    texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).st;

    lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).st;

    gl_FogFragCoord = gl_Position.z;

    normal = normalize(gl_NormalMatrix * gl_Normal);

}