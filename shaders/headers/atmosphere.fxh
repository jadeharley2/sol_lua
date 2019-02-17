
float atm_desaturation=0.3;
float atm_minfog=10;
float atm_transparency=0.3;
float atm_refraction=0.5;
float3 base= float3(107,115,178)/150;

float3 atm_color;
float3 atm_glow_indark= float3(30,10,30)/3500;

float atmosphere_width;
 
Texture2D tLightRamp;

SamplerState RampSampler
{ 
    Filter = ANISOTROPIC;//MIN_MAG_MIP_POINT;
    AddressU = Clamp;
    AddressV = Clamp;
};  

/*
 
	float3 lightcolor = Delight(lightColor, saturate(0.3-(globalLightIntencity)-0.2f));
	float3 brightness3 = ApplyPointLights(input.wpos,input.normal,cameraDirection,specular_intensity,100,cshadow,false);
	float3 brightness4 = ApplyPointLights(input.wpos,globalNormal,cameraDirection,10,100);
	//brightness3 = float3(1,1,1);
	//brightness4 = float3(1,1,1);
	//float3 starcolor =  lightcolor;//saturate(lightcolor * atmosphereFogIntencity  );
	float3 totalLight = (globalLightIntencity+0.2f) * Exposition(lightcolor,saturate(globalLightIntencity* localLightIntencity*2)) * localLightIntencity;
	//
	output.color = float4(brightness3+globalLightIntencity*base,0) 
	
*/

float3 GetAtmosphericLight(float light_brigtness_0_to_1, float3 lightColor)
{  
	float3 rampValue = lightColor*saturate(light_brigtness_0_to_1)+atm_glow_indark;//tLightRamp.Sample(RampSampler, float2(globalLightIntencity*0.5+0.5,0)).rgb;
	float3 lcol = lightColor*rampValue;//base*
	return lcol *2;
}