 
float3 hazeColor =float3(209,199,154)/255;// float3(210,216,225)/255;//0.7,0.6,0.5);

float3 dust_color=float3(209,199,154)/255;

float4x4 World;
float4x4 View;
float4x4 Projection;

bool postmode;

float4x4 invWVP;
 
float distanceMultiplier=1;

float hdrMultiplier=1;
float time =0;
  
float3 planetpos;
float planetradius=1;
float horisonDistance=1;
float horisonDistanceLocal=1;
float absheight =0;
float rheight = 1;
 
int mode = 1;

float3 pcam;
float atm_width=1;
float atm_floor=1;

float3 ldir0=normalize(float3(1,0,1));
float3 lcol0=float3(1,1,1);

bool isCameraUnderWater;

float2 screenSize = float2(1024,1024);
 
float3 atmosphereColor = float3(0.4,0.8,1);
 
float3 campos = float3(0.4,0.8,1);

Texture2D tLightView;  
Texture2D tDepthView;   
Texture2D tDiffuseView;   
Texture2D tMaskView;   
Texture2D tSkyRamp;   
 
Texture3D tClouds;   
Texture2D tCloudsB;   
 

SamplerState sCC
{
    Filter = MIN_MAG_MIP_POINT;//MIN_MAG_MIP_LINEAR;
    AddressU = Clamp;
    AddressV = Clamp;
}; 

SamplerState sCL
{
    Filter = MIN_MAG_MIP_LINEAR;//MIN_MAG_MIP_LINEAR;
    AddressU = Wrap;
    AddressV = Wrap;
}; 
  
SamplerState sFCL
{
    Filter = MIN_MAG_MIP_LINEAR;//MIN_MAG_MIP_LINEAR;
    AddressU = Wrap;
    AddressV = Wrap;
    AddressW = Wrap;
}; 
  








































float CloudDensity(float3 pt){

}












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

const float earth_radius = 6360e3; // (m)
const float atmosphere_radius = 6420e3; // (m)

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
































float camera_near=0.1;
float camera_far=100;



float linearDepth(float depth)
{
    return 2.0 * camera_near * camera_far /
             (camera_far + camera_near -
             (depth * 2.0 - 1.0) * (camera_far - camera_near));
}

float SS_GetDepth(float2 position)
{ 
	 return linearDepth(tDepthView.Sample(sCC, position).r);
}
//float3 SS_GetPosition(float2 UV, float depth)
//{
//	float4 position = 1.0f; 
// 
//	position.x = UV.x * 2.0f - 1.0f; 
//	position.y = -(UV.y * 2.0f - 1.0f); 
//
//	position.z = depth; 
// 
//	//Transform Position from Homogenous Space to World Space 
//	position = mul(position,  (invWVP));  
// 
//	//position *= position.w;
//	position /= position.w;
//
//	return position.xyz;
//}

 

///////////////////////////////////

struct VertexShaderInput
{
    float4 Position : SV_POSITION; 

};
struct VSS_IN
{
	float4 Position : POSITION; 
	float3 norm : NORMAL;  
	float3 bnorm : BINORMAL; 
	float3 tnorm : TANGENT; 
	float2 tcrd : TEXCOORD; 
    float4 wts  : BLENDWEIGHT;
    float4 inds  : BLENDINDICES;
	float3 color : COLOR0; 
	
	 
};

struct PS_IN
{
    float4 Position : SV_POSITION;
	float3 Normal :TEXCOORD0;
	float3 Pos :TEXCOORD1;
    float3 LPOS : TEXCOORD2;
	float2 tcrd : TEXCOORD3;  // local position
	float3 data : TEXCOORD4;
};
struct PS_OUT
{
    float4 color: SV_Target0;
    float4 normal: SV_Target1;
    //float4 position: SV_Target2;
    float depth: SV_Target2;
    float4 mask: SV_Target3;
    float4 diffuse: SV_Target4;
};

PS_IN VS(VSS_IN input)
{
    PS_IN output = (PS_IN)0;

    float4 worldPosition = mul(input.Position, (World));
    float4 viewPosition = mul(worldPosition, (View));
    output.Position = mul(viewPosition, (Projection));
	output.Normal = normalize( input.Position);//mul(-input.Position,(float3x3)(World)).xyz);
	output.Pos = worldPosition;
	output.LPOS =worldPosition;//-planetpos;
	output.tcrd = input.tcrd;
	output.data = input.color;

    return output;
}
   
bool IsNAN(float n)
{
    return (n < 0.0f || n > 0.0f || n == 0.0f) ? false : true;
}
float3 SS_GetPosition(float2 UV,float depth)
{ 
	float4 position = 1.0f; 

	position.x = UV.x * 2.0f - 1.0f; 
	position.y = -(UV.y * 2.0f - 1.0f); 

	
	position.z = depth; 
//position.w = 1;
	//Transform Position from Homogenous Space to World Space 
	position = mul(position, invWVP);  

	//position *= position.w;
	if(position.w==0) return position.xyz;
	position /= position.w;

	return position.xyz;
}

float tcdensity(float3 pos){
	return saturate(
			//tClouds.Sample(sFCL, pos*2).a
			tCloudsB.Sample(sFCL,pos.xz*0.2).r*2
			*saturate(1-abs(pos.y*10+2))-0.3 
			
			)
			
			*(k/128);
} 
float3 tctest(float2 screenPosition,PS_IN input, float3 light){
	  
	float depth =  min(0.99997,tDepthView.Sample(sCL, screenPosition).x);
    float3 pos =(SS_GetPosition(screenPosition,depth ))	;// SS_GetPosition(screenPosition,depth);
	float3 dir =  (pos -(campos*float3(1,-1,-1)));
	float len = length(dir);
	//float maxlen = 1;
	
	//if(len>maxlen) {
	//	dir = (dir/len) * maxlen;
	//}
	float3 ddt = dir/128;
	float testcloud = 0;
	float3 enclight =0;
	float3 samplepos = campos*float3(1,-1,-1);

	float3 lightenergy = 0;
	float transmittance = 0;//1;

	float Density = 0.01;
	for(float k=1;k<128;k++){
		float cursample = tcdensity(samplepos)*100;
		//if( cursample > 0.001)
		//{
	 	float inlight = 1;
	 
	 	float3 lpos = samplepos;
	 	for(float j=1;j<8;j++){
	 		lpos = lpos + ldir0;
	 		inlight  -=(tcdensity(lpos)+0.01);
	 	}
	 	//
     	//float curdensity = saturate(cursample * Density);
	 	//float shadowterm = exp(-shadowdist * 0.3);
	 	//float3 absorbedlight = shadowterm * curdensity;
	 	//lightenergy += absorbedlight * transmittance  ;
 
        	transmittance += cursample+inlight*cursample; 
		//}
		samplepos +=ddt; 
	}
	
	//transmittance +=	tcdensity(samplepos)*100;
	return   max(0,light
	 )
	 +transmittance
	//+lightenergy 
	  ;//+testcloud*enclight
}


PS_OUT PS(PS_IN input) : SV_Target
{   
	PS_OUT ou = (PS_OUT)0;
	
	//return float4(0.5,0,1,0.5);
	float2 screenPosition = ((float2)input.Position.xy)/screenSize;
	 

	float dpdepth = input.Position.z/input.Position.w;
	float rpdepth =SS_GetDepth(screenPosition) 
		//*sqrt(distanceMultiplier)/1000;
		/1000;//*sqrt(distanceMultiplier)/100;
		
	float density =saturate(rpdepth*10);///horisonDistance*300000*1);///distanceMultiplier/100);
	
	
	float horisonangle = horisonDistanceLocal/length(planetpos);
	
	//different halo radiuses 
	float sunPowerh1 = 0.5;
	float sunPowerh2 = 0.4;
	float sunPowerh3 = 0.3;
	float sunPowerh4 = 0.2;
	float topDot =1;
	
	float liquidDepth = -absheight/100;
	float terrainLightDivider = max(1,(10-rpdepth));
	if(isCameraUnderWater) 
	{
		horisonangle = (absheight/300);
		
		topDot = dot(input.Normal,float3(0,-1,0))+horisonangle;
		
		sunPowerh1 = sunPowerh1 / max(1,liquidDepth*1);
		sunPowerh2 = sunPowerh2 / max(1,liquidDepth*5);
		sunPowerh3 = sunPowerh3 / max(1,liquidDepth*10);
		sunPowerh4 = sunPowerh4 / max(1,liquidDepth*100); 
		terrainLightDivider = 1;
	}
	else
	{
		topDot = dot(input.Normal,float3(0,-1,0));//+horisonangle;
	}


	float3 normalAtHorison =-normalize(planetpos);// normalize(input.Pos*6/rpdepth-planetpos);
	float lightIntencity = 0;//saturate(dot(-normalAtHorison,ldir0)*20+0.2	);

	float atmdencityByDist = max(1,absheight/30000);
	
	topDot = topDot*atmdencityByDist;
	float horison = 1-abs(topDot);
	
	float3 sunTotal = float3(0,0,0);
	float3 totalLightColor = float3(0,0,0);
	
	float3 ldir = -ldir0;
	float3 lcol = lcol0; 
	float llen = length(ldir);
	if(llen>0) 
	{
		ldir/=llen;//-normalize(ldir);
		lcol/=llen*llen;
		
		//lcol = lcol0//-=(1-saturate(dot(-normalAtHorison,ldir)*5))*atmosphereColor*lcol*1.9
		//	*saturate(horison)*saturate(horison)*2
		//	;
			totalLightColor +=max(0,lcol);
		//float ldsq = ldir.x*ldir.x+ldir.y*ldir.y+ldir.z*ldir.z;
		//ldir/=sqrt(ldsq);
		//lcol/=

		float sunDot1 = max(0,dot(input.Normal,ldir));
		float sunDotC = 
			(pow(sunDot1,1)/10*sunPowerh1
			+
			pow(sunDot1,10)*sunPowerh2
			+
			pow(sunDot1,100)*sunPowerh3
			+
			pow(sunDot1,1000)*sunPowerh4
			)/terrainLightDivider
			;
		sunTotal += sunDotC * lcol*2;
		lightIntencity +=saturate(dot(-normalAtHorison,ldir)*5+0.5);
		
	}
	totalLightColor = float3(1,1,1);
	lightIntencity = saturate(lightIntencity+0.2);
	
	float sunUpDot = normalize(ldir0).y/2+0.5;
	float3 acolor = tSkyRamp.Sample(sCC, float2(sunUpDot,0.1));//atmosphereColor
		
	float starLumAmount =  density = density * lightIntencity;
	
	//atmosphereColor
		//*sunTotal
	float3 topColor = acolor*saturate(topDot)/ atmdencityByDist;//*totalLightColor;
	float3 horisonColor =hazeColor*totalLightColor
	
	// lerp(
		//hazeColor*lerp(lcol0,totalLightColor,0.5)*0.5,
		//,
		//saturate(dot(input.Normal,ldir0)+0.1)+saturate(dot(-normalAtHorison,ldir0))
		//);/// atmdencityByDist
		;
	float3 bottomColor = acolor;
	
	
	
	if(isCameraUnderWater)
	{ 
		density = max(0.5,density); 
		
		horisonColor = totalLightColor*float3(0.1,0.25,0.3)/2/max(1,liquidDepth);
		bottomColor = totalLightColor*float3(0.1,0.25,0.3)/2/max(1,liquidDepth); 
		
	}
	
	float4 tBackColor = tLightView.Sample(sCC, screenPosition+float2(cos(time),sin(time))*0);
	tBackColor.a = 1;
	float angleDensity  =
		saturate(-topDot)/ atmdencityByDist
		+saturate(horison)/  max(1,atmdencityByDist/100) 
				
		+saturate(topDot)/ atmdencityByDist;// saturate(horison) +saturate(topDot)
		;
		
	//return float4(density,density,density,1);
	float notTop =  1-saturate(topDot);

	if (IsNAN(tBackColor.r)) tBackColor.rgb  = 0;

	float3 additive =  
	 (topColor+atmosphereColor*totalLightColor+sunTotal*10)*density*2*2;//*angleDensity*1;//4

	float3 dust = (saturate(horison)+saturate(-topDot))*horisonColor*2;
	
	float light_dust_blend = saturate(horison)*saturate(density*angleDensity*3)/ max(1,atmdencityByDist/5) ;


	float4 result =  float4( lerp(additive,dust,light_dust_blend),1);

	result.rgb =lerp( tBackColor.rgb,dust/2+ additive,saturate(rpdepth*10)) ;

	float surfacecorrector = 1-saturate(-topDot*1000.8);
	float surfacecorrectorb= saturate(-topDot*2);
	input.Normal.y=input.Normal.y*surfacecorrector+0.1*surfacecorrectorb;  

	ray_t rayx = {float3(0,earth_radius,0),-input.Normal*1.4*saturate(rpdepth*10)};
	doublecom mierayleigh = get_incident_light(rayx,rpdepth);

	float3 rem = max(float3(0,0,0),mierayleigh.rayleigh+mierayleigh.mie*2);
	result.rgb =rem*2;//lerp( tBackColor.rgb,rem*2,saturate(rpdepth)) ;
	result.a = saturate(rpdepth*rpdepth*100*1.1)*saturate(length(result.rgb));
	
	float3 inlight =  tLightView.Sample(sCC, screenPosition);
	float4 inmask =  tMaskView.Sample(sCC, screenPosition);
	
	inmask.r *= saturate(1-result.a);
	result.rgb = lerp(inlight,result.rgb,result.a);



 
	//if(postmode){ 
	//	result.rgb = tctest(screenPosition,input,result.rgb );
	//	//result.rgb  = tctest(screenPosition,input);
	//}









	
	//result = tLightView.Sample(sCC, screenPosition);
	//result.r = 1;
	result.a = 1;
	//result = rpdepth*10;//*float4(dust,1);
	//if(rpdepth<0.0001) result = 1;
	//result = tBackColor;
	//result = float4(dust,1);
	//ou.normal.r = 1; 
	//ou.mask.r =0;// density*angleDensity;


	//result.rgb = sunTotal;
	//result.a =0.9; 
	//result = surfacecorrector;

	ou.mask =inmask;
	ou.color = result;//*0.5; 
	ou.normal = float4(0.5,0.5,1,1);
	ou.depth =  1;
	ou.diffuse = tDiffuseView.Sample(sCC, screenPosition);



	return ou;//return result; 
}
technique10 DefaultTech
{
	pass P0
	{
		SetGeometryShader( 0 );
		SetVertexShader( CompileShader( vs_4_0, VS() ) );
		SetPixelShader( CompileShader( ps_4_0, PS() ) );
	} 
}