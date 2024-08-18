shader_type canvas_item;

//uniform vec2 dimensions = vec2(10.0,10.0);
uniform vec2 offset = vec2(0.5, 0.5);
uniform sampler2D gradient;
uniform float scale = 3.0;
uniform int ITERATIONS = 500;

const vec2 internal_offset = vec2(125.0);

//https://stackoverflow.com/questions/58166329/why-does-this-mandelbrot-calculation-return-a-circle
//gets the number of iterations before we decide it is unbounded
int mandelbrot(int num_iterations, vec2 point)
{
	float z = 0.0;
	float z_re = point.x;
    float z_im = point.y;

    int n;

    for (int i = 1; i <= num_iterations; i++)
    {
		n = i;
        float z_re2 = z_re * z_re;
        float z_im2 = z_im * z_im;

        if (z_re2 + z_im2 > 4.0)
        {
            break;
        }

        // z(n) = z^2 + c
        z_im = 2.0 * z_re * z_im + point.y;
        z_re = z_re2 - z_im2 + point.x;
    }

    return n;
}

int burning_ship(int num_iterations, vec2 point)
{
	float z = 0.0;
	float z_re = point.x;
    float z_im = point.y;

    int n;

    for (int i = 1; i <= num_iterations; i++)
    {
		n = i;
        float z_re2 = z_re * z_re;
        float z_im2 = z_im * z_im;

        if (z_re2 + z_im2 > 4.0)
        {
            break;
        }

        // z(n) = z^2 + c
        z_im = abs(2.0 * z_re * z_im) + point.y;
        z_re = z_re2 - z_im2 + point.x;
    }

    return n;
}

void fragment() {
	float n = float(burning_ship(ITERATIONS, ((UV - internal_offset) / scale) - offset)) / float(ITERATIONS);
	COLOR.rgb = vec3(1) * (1.0 - n);
	COLOR = texture(gradient, vec2(n, 0.0));
}
