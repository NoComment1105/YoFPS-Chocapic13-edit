// Shader options

// Final Fragment //
//----------Lighting----------//
	
#define TORCH_COLOR_LIGHTING 3.5, 3.0, 3.0 	// Torch Color RGB - Red, Green, Blue

#define TORCH_INTENSITY 8					//[6 7 8 9 10 11 12]

//Minecraft lightmap (used for sky)

#define ATTENUATION 1.45

//----------End of Lighting----------//

//----------Visual----------//

const float	sunPathRotation	= -40.0f;		//determines sun/moon inclination /-40.0 is default - 0.0 is normal rotation

//----------End of Visual----------//

//#define VIGNETTE
#define VIGNETTE_STRENGTH 0.7	//[0.1 0.15 0.2 0.25 0.3 0.35 0.4 0.45 0.5 0.55 0.6 0.65 0.7 0.75 0.8 0.85 0.9 0.95 1.0]
#define VIGNETTE_START 0.45		//[0.25 0.3 0.35 0.4 0.45 0.5 0.55 0.6 0.65 0.7]
#define VIGNETTE_END 0.9		//[0.75 0.8 0.85 0.9 0.95 1.0]


//#define RAIN_DROPS

//tonemapping constants			
const float A = 1.1;		
const float B = 0.4;		
const float C = 0.1;
// End of Final Fragment

// Final Vertex //
#define HANDHELD_LIGHT
// End of Final Vertex //

// gbuffers_terrain Vertex //
#define WAVING_GRASS
#define WAVING_FLOWERS
#define WAVING_LEAVES
#define WAVING_FUNGI
#define WAVING_VINES
#define WAVING_FIRE

#define GRASS_WAVE_SPEED   1.2   //[0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0]
#define FLOWERS_WAVE_SPEED 0.7   //[0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0]
#define LEAVES_WAVE_SPEED  0.7  //[0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0]
#define FUNGI_WAVE_SPEED   0.7   //[0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0]
#define VINES_WAVE_SPEED   0.7  //[0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0]
#define FIRE_WAVE_SPEED    1.1   //[0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0]
// End of gbuffers_terrain Vertex

// gbuffers_water Vertex //
//#define WAVING_WATER
// End of gbuffers_water Vertex //