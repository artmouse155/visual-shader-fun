const float SDF_AIR = 1e5;

//Primitives
float SDFSphere(vec3 p, float radius) { return length(p) - radius; }
float SDFCube(vec3 p, float radius) { p = abs(p); return max(max(p.x, p.y), p.z) - radius; }
float SDFTorus(vec3 p, float r1, float r2) { return length(vec2(length(p.xz) - r1, p.y)) - r2;; }
float SDFFunkyPlane(vec3 p) { return p.x + p.y + p.z; }

//Combining SDF's
float SDFUnion(float s1, float s2) { return min(s1, s2); }
float SDFDifference(float s1, float s2) { return max(-s1, s2); }
float SDFIntersection(float s1, float s2) { return max(s1, s2); }

float SDFCross(vec3 p, float side_length) {
	float c1 = max(abs(p.x), abs(p.y)) - side_length;
	float c2 = max(abs(p.x), abs(p.z)) - side_length;
	float c3 = max(abs(p.y), abs(p.z)) - side_length;
	return SDFUnion(SDFUnion(c1, c2), c3); }

float SDFMengerCrossIteration(vec3 p, float cube_side_length, int iteration)
{
	float side_length = cube_side_length * pow(3.0, -1.0 * float(iteration + 1));
	float d = SDF_AIR;
	
	if (iteration == 0)
	{
		return SDFCross(p, side_length);
	}
	int num_pipes = int(pow(3.0, float(iteration)));
	
	float separation = 2.0 * cube_side_length / (float(num_pipes));
	vec3 offset = (vec3(1.0, 1.0, 1.0) * separation * (floor(float(num_pipes) / 2.0)));// - (vec3(1.0, 1.0, 1.0) * separation * 0.5);
	p = p + offset;
	
	for (int i = 0; i < num_pipes; i++)
	{
		for (int j = 0; j < num_pipes; j++)
		{
			float i_offset = separation * float(i);
			float j_offset = separation * float(j);
			float c1 = max(abs(p.x - i_offset), abs(p.y - j_offset)) - side_length;
			float c2 = max(abs(p.x - i_offset), abs(p.z - j_offset)) - side_length;
			float c3 = max(abs(p.y - i_offset), abs(p.z - j_offset)) - side_length;
			d = SDFUnion(d, SDFUnion(SDFUnion(c1, c2), c3));
		}
	}
	return d;
}

float SDFMengerSponge(vec3 p, float cube_side_length, int iteration){
	float d = SDF_AIR;
	for (int i = 0; i < iteration; i++)
		{
			d = SDFUnion(d, SDFMengerCrossIteration(p, cube_side_length, i));
		}
	float cube = SDFCube(p, cube_side_length);
	return SDFDifference(d, cube);
}