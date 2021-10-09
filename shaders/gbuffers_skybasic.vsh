#version 120
/*
!! DO NOT REMOVE !!
This code is from Chocapic13' shaders
Read the terms of modification and sharing before changing something below please !
!! DO NOT REMOVE !!
*/
varying vec4 color;

void main() {
	gl_Position = ftransform();
	
	color = vec4(0.0,0.0,.0,1.0);

	gl_FogFragCoord = 0.0;
}