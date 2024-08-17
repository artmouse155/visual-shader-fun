//Uses https://godotshaders.com/shader/raymarch-in-a-box/

shader_type spatial;
render_mode unshaded, cull_front, depth_draw_always;

uniform sampler2D DEPTH_TEXTURE: hint_depth_texture, filter_linear_mipmap;

uniform int menger_iterations = 2;
uniform float cube_size = 2.0;
uniform bool show_cross_section = true;

varying vec3 world_camera;
varying vec3 world_position;

const int MAX_STEPS = 200;
const float MAX_DIST = 300.0;
const float SURF_DIST = 1e-4;

#include "res://sdf_class.gdshaderinc"

float GetDist(vec3 p){
	float d = SDF_AIR;
	
	//float spheres = SDFSphere(mod(p, vec3(sin(2.0 * TIME) * 10.0 + 20.0)) - vec3(2.0), 2);
	
	
	//float cubes = SDFCube(mod(p, vec3(2.0)), 1.0);
	//return cubes;
	
	return SDFMengerSponge(mod(p, vec3(12.0)) - vec3(2.0), cube_size, menger_iterations);
	
	//return SDFDifference(-SDFFunkyPlane(p), spheres);
}

float RayMarch(vec3 ro, vec3 rd) {
	float dO = 0.0;
	float dS;

	for (int i = 0; i < MAX_STEPS; i++)
	{
		vec3 p = ro + dO * rd;
		dS = GetDist(p);
		dO += dS;

		if (dS < SURF_DIST || dO > MAX_DIST)
			break;
	}
	return dO;
}

vec3 GetNormal(vec3 p) {
	vec2 e = vec2(SURF_DIST, 0);

	vec3 n = GetDist(p) - vec3(
		GetDist(p - e.xyy),
		GetDist(p - e.yxy),
		GetDist(p - e.yyx)
	);

	return normalize(n);
}

void vertex() {
	world_position = VERTEX;
	world_camera = (inverse(MODELVIEW_MATRIX) * vec4(0, 0, 0, 1)).xyz; //object space
}

void fragment() {
	
	float depth = texture(DEPTH_TEXTURE, SCREEN_UV).x;
	
	vec3 ro = world_camera;
	vec3 rd =  normalize(world_position - ro);

	vec3 col;

	float d = RayMarch(ro, rd);

	if (d >= MAX_DIST)
		discard;
	else
	{
		vec3 p = ro + rd * d;
		vec3 n = GetNormal(p);
		col = n.rgb;
	}
	
	vec3 surfacePoint = ro + rd * d;
	vec4 viewSpaceSurfacePoint = VIEW_MATRIX * vec4(surfacePoint, 1.);
	vec4 clipSpaceSurfacePoint = PROJECTION_MATRIX * viewSpaceSurfacePoint;
	
	NORMAL = (VIEW_MATRIX * vec4(GetNormal(surfacePoint), 0.)).xyz;
	
	ALBEDO = col;
}