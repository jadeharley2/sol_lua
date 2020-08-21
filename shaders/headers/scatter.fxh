
#define PI 3.14159265359
#define BIAS 1e-4 // small offset to avoid self-intersections
 

struct ray_t {
	float3 origin;
	float3 direction;
};

struct sphere_t {
	float3 origin;
	float radius;
	int material;
};

struct plane_t {
	float3 direction;
	float distance;
	int material;
};

float3x3 rotate_around_x(in float angle_degrees)
{
	float angle = radians(angle_degrees);
	float _sin = sin(angle);
	float _cos = cos(angle);
	return float3x3(1, 0, 0, 0, _cos, -_sin, 0, _sin, _cos);
}


ray_t get_primary_ray(
	in float3 cam_local_point,
	inout float3 cam_origin,
	inout float3 cam_look_at
){
	float3 fwd = normalize(cam_look_at - cam_origin);
	float3 up = float3(0, 1, 0);
	float3 right = cross(up, fwd);
	up = cross(fwd, right);

	ray_t r = (ray_t)0;
	r.origin = cam_origin;
	r.direction = normalize(fwd + up * cam_local_point.y + right * cam_local_point.x);
		
	return r;
}

bool isect_sphere( in ray_t ray, in sphere_t sphere, inout float t0, inout float t1)
{
	float3 rc = sphere.origin - ray.origin;
	float radius2 = sphere.radius * sphere.radius;
	float tca = dot(rc, ray.direction);
	float d2 = dot(rc, rc) - tca * tca;
	if (d2 > radius2) return false;
	float thc = sqrt(radius2 - d2);
	t0 = tca - thc;
	t1 = tca + thc;

	return true;
}

// scattering coefficients at sea level (m)
const float3 betaR = float3(5.5e-6, 13.0e-6, 22.4e-6); // Rayleigh 
const float3 betaM = float3(1,1,1)*21e-6; // Mie

// scale height (m)
// thickness of the atmosphere if its density were uniform
const float hR = 7994.0; // Rayleigh
const float hM = 1200.0; // Mie

float rayleigh_phase_func(float mu)
{
	return
			3. * (1. + mu*mu)
	/ //------------------------
				(16. * PI);
}

// Henyey-Greenstein phase function factor [-1, 1]
// represents the average cosine of the scattered directions
// 0 is isotropic scattering
// > 1 is forward scattering, < 1 is backwards
const float g = 0.76;
float henyey_greenstein_phase_func(float mu)
{
	return
						(1. - g*g)
	/ //---------------------------------------------
		((4. * PI) * pow(1. + g*g - 2.*g*mu, 1.5));
}

// Schlick Phase Function factor
// Pharr and  Humphreys [2004] equivalence to g above
#define gcon 0.76
const float k = 1.55*gcon - 0.55 * (gcon*gcon*gcon);
float schlick_phase_func(float mu)
{
	return
					(1. - k*k)
	/ //-------------------------------------------
		(4. * PI * (1. + k*mu) * (1. + k*mu));
}

float earth_radius = 6360e3; // (m)
float atmosphere_radius = 6420e3; // (m)

float3 sun_dir = float3(0, 1, 0);
const float sun_power = 25.0;

const sphere_t atmosphere = { float3(0, 0, 0), 6420e3, 0};

const int num_samples = 16;
const int num_samples_light = 8;

bool get_sun_light(
	in ray_t ray,
	inout float optical_depthR,
	inout float optical_depthM
){
	float t0, t1;
	isect_sphere(ray, atmosphere, t0, t1);

	float march_pos = 0.;
	float march_step = t1 / float(num_samples_light);

	for (int i = 0; i < num_samples_light; i++) {
		float3 s =
			ray.origin +
			ray.direction * (march_pos + 0.5 * march_step);
		float height = length(s) - earth_radius;
		if (height < 0.)
			return false;

		optical_depthR += exp(-height / hR) * march_step;
		optical_depthM += exp(-height / hM) * march_step;

		march_pos += march_step;
	}

	return true;
}
struct doublecom{
	float3 mie;
	float3 rayleigh;
};
doublecom get_incident_light( in ray_t ray,float maxdepth)
{
//	ray.direction.y = abs(ray.direction.y);
	// "pierce" the atmosphere with the viewing ray
	float t0, t1;
	if (!isect_sphere(
		ray, atmosphere, t0, t1)) {
		return (doublecom)0;
	}

	float march_step = t1 / float(num_samples)*maxdepth*maxdepth*10;

	// cosine of angle between view and light directions
	float mu = dot(ray.direction, sun_dir);

	// Rayleigh and Mie phase functions
	// A black box indicating how light is interacting with the material
	// Similar to BRDF except
	// * it usually considers a single angle
	//   (the phase angle between 2 directions)
	// * integrates to 1 over the entire sphere of directions
	float phaseR = rayleigh_phase_func(mu);
	float phaseM =
#if 1
		henyey_greenstein_phase_func(mu);
#else
		schlick_phase_func(mu);
#endif
	// optical depth (or "average density")
	// represents the accumulated extinction coefficients
	// along the path, multiplied by the length of that path
	float optical_depthR = 0.;
	float optical_depthM = 0.;

	float3 sumR = (float3)0;
	float3 sumM = (float3)0;
	float march_pos = 0.;

	for (int i = 0; i < num_samples; i++) {
		float3 s =
			ray.origin +
			ray.direction * (march_pos + 0.5 * march_step);
		float height = length(s) - earth_radius;

		// integrate the height scale
		float hr = exp(-height / hR) * march_step;
		float hm = exp(-height / hM) * march_step;
		optical_depthR += hr;
		optical_depthM += hm;

		// gather the sunlight
		ray_t light_ray = {s,sun_dir};
		float optical_depth_lightR = 0.;
		float optical_depth_lightM = 0.;
		bool overground = get_sun_light(
			light_ray,
			optical_depth_lightR,
			optical_depth_lightM);

		if (overground) {
			float3 tau =
				betaR * (optical_depthR + optical_depth_lightR) +
				betaM * 1.1 * (optical_depthM + optical_depth_lightM);
			float3 attenuation = exp(-tau);

			sumR += hr * attenuation;
			sumM += hm * attenuation;
		}

		march_pos += march_step;
	}
	doublecom result = {sun_power * sumR * phaseR * betaR,
		 sun_power * sumM * phaseM * betaM};
	return result;
}









