#version 120
#define MAX_COLOR_RANGE 48.0
const int RGB16 = 3;
const int gnormalFormat = RGB16;

#include "/lib/common.glsl"
/*
!! DO NOT REMOVE !!
This code is from Chocapic13' shaders
Read the terms of modification and sharing before changing something below please !
!! DO NOT REMOVE !!
*/

/*
Disable an effect by putting "//" before "#define" when there is no number after
You can tweak the numbers, the impact on the shaders is self-explained in the variable's name or in a comment
*/



varying vec4 texcoord;

varying vec3 lightVector;
varying vec3 sunVec;
varying vec3 moonVec;
varying vec3 upVec;

varying vec4 lightS;

varying vec3 sunlight;
varying vec3 moonlight;
varying vec3 ambient_color;

varying float handItemLight;
varying float eyeAdapt;

varying float SdotU;
varying float MdotU;
varying float sunVisibility;
varying float moonVisibility;

uniform sampler2D noisetex;
uniform sampler2D gnormal;
uniform sampler2D gcolor;
uniform sampler2D gaux1;
uniform sampler2D gaux4;
uniform sampler2D depthtex0;
uniform sampler2D depthtex1;
uniform sampler2D composite;

uniform vec3 cameraPosition;
uniform vec3 previousCameraPosition;
uniform vec3 sunPosition;
uniform vec3 moonPosition;
uniform mat4 gbufferProjection;
uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferPreviousProjection;
uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferModelView;
uniform mat4 gbufferPreviousModelView;
uniform ivec2 eyeBrightnessSmooth;
uniform int isEyeInWater;
uniform int worldTime;
uniform float aspectRatio;
uniform float near;
uniform float far;
uniform float viewWidth;
uniform float viewHeight;
uniform float rainStrength;
uniform float wetness;
uniform float frameTimeCounter;
vec3 sunPos = sunPosition;
float pw = 1.0 / viewWidth;
float ph = 1.0 / viewHeight;
float timefract = worldTime;


//Raining
float rainx = clamp(rainStrength, 0.0f, 1.0f) / 1.0f;
float wetx  = clamp(wetness, 0.0f, 1.0f);

//Calculate Time of Day
float TimeSunrise  = ((clamp(timefract, 23000.0, 24000.0) - 23000.0) / 1000.0) + (1.0 - (clamp(timefract, 0.0, 4000.0) / 4000.0));
float TimeNoon     = ((clamp(timefract, 0.0, 4000.0)) / 4000.0) - ((clamp(timefract, 8000.0, 12000.0) - 8000.0) / 4000.0);
float TimeSunset   = ((clamp(timefract, 8000.0, 12000.0) - 8000.0) / 4000.0) - ((clamp(timefract, 12000.0, 12750.0) - 12000.0) / 750.0);
float TimeMidnight = ((clamp(timefract, 12000.0, 12750.0) - 12000.0) / 750.0) - ((clamp(timefract, 23000.0, 24000.0) - 23000.0) / 1000.0);
vec2 wind[4] = vec2[4](vec2(abs(frameTimeCounter / 1000.-0.5), abs(frameTimeCounter / 1000.-0.5)) + vec2(0.5),
					   vec2(-abs(frameTimeCounter / 1000.-0.5), abs(frameTimeCounter / 1000.-0.5)),
					   vec2(-abs(frameTimeCounter / 1000.-0.5), -abs(frameTimeCounter / 1000.-0.5)),
					   vec2(abs(frameTimeCounter / 1000.-0.5), -abs(frameTimeCounter / 1000.-0.5)));

vec3 nvec3(vec4 pos) {
    return pos.xyz / pos.w;
}

vec4 nvec4(vec3 pos) {
    return vec4(pos.xyz, 1.0);
}

float getDepth(float depth) {
    return 2.0 * near * far / (far + near - (2.0 * depth - 1.0) * (far - near));
}

float ld(float depth) {
    return (2.0 * near) / (far + near - depth * (far - near));
}

float luma(vec3 color) {
	return dot(color, vec3(0.299, 0.587, 0.114));
}


vec3 getSkyColor(vec3 fposition) {
	/*--------------------------------*/
	vec3 sky_color = vec3(0.1, 0.35, 1.);
	vec3 nsunlight = normalize(pow(sunlight, vec3(2.2)) * vec3(1, 0.9, 0.8));
	vec3 sVector = normalize(fposition);
	/*--------------------------------*/
	sky_color = normalize(mix(sky_color, vec3(0.25, 0.3, 0.45) * length(ambient_color), rainStrength)); //normalize colors in order to not change luminance
	/*--------------------------------*/
	float Lz = 1.0;
	float cosT = dot(sVector, upVec); 
	float absCosT = max(cosT, 0.0);
	float cosS = dot(sunVec, upVec);
	float S = acos(cosS);							
	float cosY = dot(sunVec, sVector);
	float Y = acos(cosY);		
	/*--------------------------------*/
	float a = -1.;
	float b = -0.24;
	float c = 6.0;
	float d = -0.8;
	float e = 0.45;
	/*--------------------------------*/

	//sun sky color
	float L =  (1 + a * exp(b / (absCosT + 0.01))) * (1 + c * exp(d * Y) + e * cosY * cosY); 
	L = pow(L, 1.0 - rainStrength * 0.81) * (1.09 - rainStrength * 0.81); //modulate intensity when raining
	/*--------------------------------*/
	vec3 skyColorSun = mix(sky_color, nsunlight, 1 - exp(-0.005 * pow(L ,4) * (1 - rainStrength * 0.5))) * L * 0.5 * vec3(0.8, 0.9, 1); //affect color based on luminance (0% physically accurate)
	skyColorSun *= sunVisibility;
	/*--------------------------------*/

	//moon sky color
	float McosS = MdotU;
	float MS = acos(McosS);
	float McosY = dot(moonVec, sVector);
	float MY = acos(McosY);
	/*--------------------------------*/
	float L2 = (1 + a * exp( b / (absCosT + 0.01))) * (1 + c * exp(d * MY) + e * McosY * McosY) + 0.2;
	L2 = pow(L2 , 1.0 - rainStrength * 0.8) * (1.0 -rainStrength * 0.83); //modulate intensity when raining
	/*--------------------------------*/
	vec3 skyColormoon = mix(moonlight, normalize(vec3(0.25, 0.3, 0.4)) * length(moonlight), rainStrength * 0.8) * L2 * 0.8 ; //affect color based on luminance (0% physically accurate)
	skyColormoon *= moonVisibility;
	sky_color = skyColormoon * 2.0 + skyColorSun;
	/*--------------------------------*/
	return sky_color;
}


vec3 drawSun(vec3 fposition, vec3 color, int land) {
	vec3 sVector = normalize(fposition);

	float angle = (1 - max(dot(sVector, sunVec), 0.0)) * 350.0;
	float sun = exp(-angle * angle);
	sun *= land * (1.03 - rainStrength * 0.9925) * sunVisibility;
	vec3 sunlight = mix(sunlight, vec3(0.25, 0.3, 0.4) * length(ambient_color), rainStrength * 0.75);

	return mix(color, sunlight * 4, sun);

}

vec3 skyGradient (vec3 fposition, vec3 color, vec3 fogclr) {
	const float density = 1500.0;
	const float start = 0.0;
	float rainFog = 1.0 + 4.0 * rainStrength;
	
	float fog = min(exp(-length(fposition) / density / sunVisibility * 0.7 + 0.3 * rainFog + start) * sunVisibility * (1 - rainStrength), 1.0);
	
	vec3 fc = fogclr;
	return mix(fc, color, fog);		
	

}

float getAirDensity(float h) {
	return min((pow((max((h), 58.0) - 58.0) / 30, 2.0) * 20.0 + 10.0), 35.0);
}

vec3 calcFog(vec3 fposition, vec3 color, vec3 fogclr) {
	float density = 5000. + max(1500 * (1 - (abs(worldTime - 6000) / 6000.0)), 0.0) * (1.05 - rainStrength) - rainStrength * 3000;
	/*--------------------------------*/
	vec3 worldpos = (gbufferModelViewInverse * vec4(fposition, 1.0)).rgb + cameraPosition;
	float d = length(fposition);
	float height = mix(getAirDensity (worldpos.y), 0.1, rainStrength * 0.8);
	/*--------------------------------*/
	float fog = clamp(24.0 * exp(-getAirDensity (-cameraPosition.y) / density) * (1.0 - exp(-d * height / density )) / height - 0.3 + rainStrength * 0.25, 0.0, 0.6 + rainStrength * .4);
	/*--------------------------------*/
	return mix(color, fogclr * mix(vec3(0.35, 0.4, 0.5) * 2., vec3(1.0), max(moonVisibility * (1 - sunVisibility), rainStrength)), fog);		
}



vec3 Uncharted2Tonemap(vec3 x) {
	float D = 0.09;		
	float E = 0.02;
	float F = 0.3;
	float W = MAX_COLOR_RANGE;
	/*--------------------------------*/
	return ((x * (A * x + C * B) + D * E) / ( x * (A * x + B) + D * F)) - E / F;
}

float distratio(vec2 pos, vec2 pos2) {
	float xvect = pos.x * aspectRatio - pos2.x * aspectRatio;
	float yvect = pos.y - pos2.y;
	return sqrt(xvect * xvect + yvect * yvect);
}
								
float gen_circular_lens(vec2 center, float size) {
	float dist = distratio(center, texcoord.xy) / size;
	return exp(-dist * dist);
}

vec2 noisepattern(vec2 pos) {
	return vec2(abs(fract(sin(dot(pos, vec2(18.9898f, 28.633f))) * 4378.5453f)), abs(fract(sin(dot(pos.yx, vec2(18.9898f, 28.633f))) * 4378.5453f)));
}

float getnoise(vec2 pos) {
	return abs(fract(sin(dot(pos, vec2(18.9898f, 28.633f))) * 4378.5453f));
}

float cdist(vec2 coord) {
	return max(abs(coord.s), abs(coord.t)) * 1.9;
}

float subSurfaceScattering(vec3 vec, vec3 pos, float N) {
	return pow(max(dot(vec, normalize(pos)), 0.0), N) * (N + 1) / 6.28;
}

float subSurfaceScattering2(vec3 vec,vec3 pos, float N) {
	return pow(max(dot(vec, normalize(pos)) * 0.5 + 0.5, 0.0), N) * (N + 1) / 6.28;
}

vec3 alphablend(vec3 c, vec3 ac, float a) {
	vec3 n_ac = normalize(ac) * (1 / sqrt(3.));
	vec3 nc = sqrt(c * n_ac);
	return mix(c, nc, a);
}

vec3 underwaterFog(float depth, vec3 color) {
	const float density = 48.0;
	float fog = exp(-depth / density);
	vec3 Ucolor = normalize(pow(vec3(0.1, 0.4, 0.6), vec3(2.2))) * (sqrt(3.0));
	
	vec3 c = mix(color * Ucolor, color, fog);
	vec3 fc = Ucolor * length(ambient_color) * 0.05;
	return mix(fc, c, fog);
}

vec3 underlavaFog(float depth, vec3 color) {
	const float density = 0.75;
	float fog = exp(-depth / density);
	vec3 Ucolor = normalize(pow(vec3(1, 0.2, 0.1), vec3(3))) * (sqrt(5.0));
	
	vec3 c = mix(color * Ucolor, color, fog);
	vec3 fc = Ucolor * length(ambient_color) * 0.05;
	return mix(fc, c, fog);
}

vec3 undersnowFog(float depth, vec3 color) {
	const float density = 0.75;
	float fog = exp(-depth / density);
	vec3 Ucolor = normalize(pow(vec3(0.75, 0.9, 1), vec3(4.2))) * (sqrt(3.0));
	
	vec3 c = mix(color * Ucolor, color, fog);
	vec3 fc = Ucolor * length(ambient_color) * 0.07;
	return mix(fc, c, fog);
}

float Blinn_Phong(vec3 ppos, vec3 lvector, vec3 normal, float fpow, float gloss, float visibility)  {
	vec3 lightDir = vec3(lvector);
	
	vec3 surfaceNormal = normal;
	float cosAngIncidence = dot(surfaceNormal, lightDir);
	cosAngIncidence = clamp(cosAngIncidence, 0.0, 1.0);
	
	vec3 viewDirection = normalize(-ppos);
	
	vec3 halfAngle = normalize(lightDir + viewDirection);
	float blinnTerm = dot(surfaceNormal, halfAngle);
	
	float normalDotEye = dot(normal, normalize(ppos));
	float fresnel = clamp(pow(1.0 + normalDotEye, 5.0), 0.0, 1.0);
	fresnel = (fresnel * 0.85 + 0.15) * (1.0 - fresnel);
	float pi = 3.1415927;
	float n =  pow(2.0, gloss * 10.0);
	return (pow(blinnTerm, n ) * ((n + 8.0) / (8 * pi))) * visibility;
}

float smStep (float edge0, float edge1, float x) {
	float t = clamp((x - edge0) / (edge1 - edge0), 0.0, 1.0);
	return t * t * (3.0 - 2.0 * t); 
}
	
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////

void main() {


	/*--------------------------------*/
	const float pi = 3.14159265359;
	float rainlens = 0.0;
	const float lifetime = 4.0;		//water drop lifetime in seconds
	/*--------------------------------*/
	float ftime = frameTimeCounter * 2.0 / lifetime;  
	vec2 drop = vec2(0.0, fract(frameTimeCounter / 20.0));
	/*--------------------------------*/
	#ifdef RAIN_DROPS
		if (rainStrength > 0.02) {
			/*--------------------------------*/
			float gen = 0.8 - fract((ftime + 0.5) * 0.5);
			vec2 pos = (noisepattern(vec2(-0.94386347 * floor(ftime * 0.5 + 0.25), floor(ftime * 0.5 + 0.25)))) * 0.9 + 0.1 - drop;
			rainlens += gen_circular_lens(fract(pos), 0.04) * gen * rainStrength;
			/*--------------------------------*/
			gen = 0.8 - fract((ftime + 1.0) * 0.5);
			pos = (noisepattern(vec2(0.9347 * floor(ftime * 0.5 + 0.5), -0.2533282 * floor(ftime * 0.5 + 0.5)))) * 0.8 + 0.1 - drop;
			rainlens += gen_circular_lens(fract(pos), 0.023) * gen * rainStrength;
			/*--------------------------------*/
			gen = 0.8 - fract((ftime + 1.5) * 0.5);
			pos = (noisepattern(vec2(0.785282 * floor(ftime * 0.5 + 0.75), -0.285282 * floor(ftime * 0.5 + 0.75)))) * 0.8 + 0.1- drop;
			rainlens += gen_circular_lens(fract(pos), 0.03) * gen * rainStrength;
			/*--------------------------------*/
			gen =  0.8 - fract(ftime * 0.5);
			pos = (noisepattern(vec2(-0.347 * floor(ftime * 0.5), 0.6847 * floor(ftime * 0.5)))) * 0.8 + 0.1 - drop;
			rainlens += gen_circular_lens(fract(pos), 0.05) * gen * rainStrength;
			/*--------------------------------*/
			rainlens *= clamp((eyeBrightnessSmooth.y - 220) / 15.0, 0.0, 1.0);
		}
	#endif

	vec2 newTC = texcoord.st;

	/*--------------------------------*/

	vec3 fragpos = vec3(newTC.st, texture2D(depthtex1, newTC.st).r);

	vec3 aux = texture2D(gaux1, newTC).rgb;

	int land = int(aux.g < 0.000001);
	float iswater = float(aux.g > 0.04 && aux.g < 0.07);
	int hand  = int(aux.g > 0.905 && aux.g < 0.915);
	float translucent = float(aux.g > 0.19 && aux.g < 0.21);
	
	vec3 normal = texture2D(gnormal, newTC).rgb * 2.0 - 1.0;
	
	fragpos = nvec3(gbufferProjectionInverse * nvec4(fragpos * 2.0 - 1.0));

	if (land > 0.9) { 
		fragpos = (gbufferModelView * (gbufferModelViewInverse * vec4(fragpos, 1.0) + vec4(.0, max(cameraPosition.y - 70., .0), .0, .0))).rgb; 
	}

	float cosT = dot(normalize(fragpos), upVec);
	vec3 fogclr = getSkyColor(fragpos.xyz);


	float uDepth = texture2D(depthtex0, newTC.xy).x;
	vec4 t  = (gbufferProjectionInverse * vec4(vec3(newTC.xy, uDepth) * 2.0 - 1.0, 1.0));	
	vec3 uPos = t.xyz / t.w;
	vec3 color = pow(texture2D(gcolor, newTC).rgb, vec3(2.2));
	color = color * (1.0 + translucent * 0.3);

	
	float handlight = handItemLight;
	float mfp = min(1 - clamp(length(fragpos.xyz), 0.0, 16.0) / 16.0, 0.85);		
	float handLight = (1.0 / pow((1 - mfp) * 16.0, 2.0)) * TORCH_INTENSITY * handlight * 0.25;
	
	float modlmap = clamp(aux.b, 0.0, 0.9);
	vec3 torch_lightmap = (max((1.0 / pow((1 - modlmap) * 16.0, 2.0)) - 0.00390625, 0.0) + handLight) * vec3(TORCH_COLOR_LIGHTING) * eyeAdapt * TORCH_INTENSITY;


	float sky_lightmap = pow(max(aux.r - 1.5 / 16., 0.0) * (1 / (1 - 1.5 / 16.)), ATTENUATION);
	vec3 skycolor = ambient_color;
	vec3 lc = mix(pow(sunlight, vec3(2.2)), moonlight, moonVisibility);
	lc = mix(lc,vec3(length(lc)) * 0.3,rainStrength * 0.9);
	
	vec3 Ucolor = normalize(vec3(0.1, 0.4, 0.6));

	//we'll suppose water plane have same height above pixel and at pixel water's surface
	
	vec3 uVec = fragpos.xyz - uPos;
	float UNdotUP = abs(dot(normalize(uVec), normal));
	float depth = length(uVec) * UNdotUP;
	float isEyeInWaterFloat = isEyeInWater;  // This is necessary for this due to Mesa being weird and allowing int, but other drivers not
	float sky_absorbance = mix(mix(1.0, exp(-depth / 2.5) * 0.4, iswater), 1.0, isEyeInWaterFloat);
	
	vec3 sun_light = lc * pow(aux.r, 8.0) * 2. * (1.1 - rainStrength * 0.95);
	vec3 skylight = skycolor * sky_lightmap * 0.05;
	color.rgb = (sun_light + skylight + torch_lightmap) * sky_absorbance * color * 1.12;
	
	if (iswater > 0.9) { 
		color = mix(Ucolor * length(ambient_color) * 0.01 * sky_lightmap, color, exp(-depth / 16)); 
	}
	
	if (iswater > 0.9 && isEyeInWater == 0) {
		float normalDotEye = dot(normal, normalize(fragpos));
		float fresnel = pow(max(1.0 + normalDotEye, 0.0), 5.);
		fresnel = mix(1., fresnel, 0.9) * 0.5;
		float spec = clamp(Blinn_Phong(fragpos.xyz, lightVector, normal, 1.0, 1.0, max(dot(lightVector, normal), 0.0)) * (1.0 - isEyeInWater), 0.0, 1.0);
		/*--------------------------------*/
		vec3 lc = mix(vec3(0.0), sunlight, sunVisibility);
		vec4 reflection = vec4(0.0);
		vec3 npos = normalize(fragpos);
		vec3 reflectedVector = reflect(normalize(fragpos), normalize(normal));
		reflectedVector = fragpos + reflectedVector * (2000.0 - fragpos.z);
		vec3 skyc = getSkyColor(reflectedVector);
		vec3 sky_color = skyGradient(reflectedVector, vec3(0.0), skyc) * clamp(sky_lightmap * 2.0 - 2 / 16.0, 0.0, 1.0);
		
		reflection.rgb = sky_color + spec * lc * (1.0 - rainStrength) * (5 + SdotU * 45);			
		reflection.a = min(reflection.a, 1.0);
		reflection.rgb = reflection.rgb;
		color.rgb = fresnel * reflection.rgb + (1 - fresnel) * color.rgb;
		/*--------------------------------*/
    }

	if (land > 0.9) {
		fragpos.xyz = normalize(fragpos) * vec3(2000 * (0.25 + sunVisibility * 0.75));
	}

	if (land < 0.9) {
		color.rgb = calcFog(fragpos.xyz, color.rgb, (fogclr));
	} else {
		color = pow(texture2D(gcolor, newTC.xy).rgb, vec3(2.2)) * (1 - sunVisibility) * 16.0 * sqrt(max(dot(upVec, normalize(fragpos.xyz)), 0.0)) ;	
		color.rgb = skyGradient(fragpos.xyz, color.rgb, fogclr);
		color.rgb = drawSun(fragpos, color.rgb, land);
	
	}
	
	if (isEyeInWater == 1) { 
		color.rgb = underwaterFog(length(fragpos), color.rgb); 
	} else if (isEyeInWater == 2) {
		color.rgb = underlavaFog(length(fragpos), color.rgb);
	} else if (isEyeInWater == 3) {
		color.rgb = undersnowFog(length(fragpos), color.rgb);
	}


	vec4 tpos = vec4(sunPosition,1.0) * gbufferProjection;
	tpos = vec4(tpos.xyz / tpos.w, 1.0);
	vec2 pos1 = tpos.xy / tpos.z;
	vec2 lightPos = pos1 * 0.5 + 0.5;
	float gr = 0.0;	

	/*--------------------------------*/
	//draw rain
	vec4 rain = pow(texture2D(gaux4, texcoord.xy), vec4(vec3(2.2), 1));
	if (length(rain) > 0.0001) {
		rain.rgb = normalize(rain.rgb) * 0.001 * (0.5 + length(rain.rgb) * 0.25) * length(ambient_color);
		color.rgb = ((1 - (1 - color.xyz / 48.0) * (1 - rain.xyz * rain.a)) * 48.0);
	}
	/*--------------------------------*/

	#ifdef RAIN_DROPS
		vec3 c_rain = rainlens * ambient_color * 0.0008;
		color = (((1 - (1 - color.xyz / 42.0) * (1 - c_rain.xyz)) * 42.0));
	#endif
	/*--------------------------------*/

	

	/*--------------------------------*/
	vec3 curr = Uncharted2Tonemap(color);
	vec3 whiteScale = 1.0f / Uncharted2Tonemap(vec3(MAX_COLOR_RANGE));
	color = pow(curr * whiteScale, vec3(1 / 2.2));
	/*--------------------------------*/
	float saturation = 0.98;         
	float avg = (color.r + color.g + color.b);    
	color = (((color - avg) * saturation) + avg) ;
	/*--------------------------------*/

	#ifdef VIGNETTE
		float len = length(texcoord.xy - vec2(.5));
		float len2 = distratio(texcoord.xy, vec2(.5));
		/*--------------------------------*/
		float dc = mix(len, len2, 0.3);
		float vignette = smStep(VIGNETTE_END, VIGNETTE_START, dc);
		/*--------------------------------*/
		color = color * (1 + vignette) * 0.5;
	#endif	

	gl_FragColor = vec4(color, 1.0);
}
