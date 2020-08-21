
float4x4 World;
float4x4 View;
float4x4 Projection;
float4x4 InverseWVP;

float time = 0;

float3 PlanetPosition;
float3 PlanetPositionReal;

#include "headers/scatter.fxh"


Texture2D tDepthView;   

SamplerState sCC
{
    Filter = MIN_MAG_MIP_POINT;//MIN_MAG_MIP_LINEAR;
    AddressU = Clamp;
    AddressV = Clamp;
}; 
SamplerState sView
{
    Filter = MIN_MAG_MIP_POINT;//MIN_MAG_MIP_LINEAR;
    AddressU = Wrap;
    AddressV = Wrap;
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
    float4 light: SV_Target0;
    float4 normal: SV_Target1; 
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
	output.Normal = normalize(
		// worldPosition-PlanetPosition//
		//mul(input.norm,(float3x3)(World)).xyz
		input.norm
		);
	output.Pos = worldPosition;
	output.LPOS =worldPosition;//-planetpos;
	output.tcrd = input.tcrd;
	output.data = input.color;

    return output;
}
  
float SS_GetDepth(float2 position)
{ 
	 return tDepthView.Sample(sCC, position).r;//linearDepth(tDepthView.Sample(sCC, position).r);
}
float3 SS_GetPosition(float2 UV)
{
	float depth =  tDepthView.Sample(sView, UV).x;
	float4 position = 1.0f; 

	position.x = UV.x * 2.0f - 1.0f; 
	position.y = -(UV.y * 2.0f - 1.0f); 

	position.z = depth; 
//position.w = 1;
	//Transform Position from Homogenous Space to World Space 
	position = mul(position, InverseWVP);  

	//position *= position.w;
	position /= position.w;

	return position.xyz;
}
float camera_h = 1;
float2 screenSize;
float distanceMultiplier =1;
float horisonDistance = 1;
PS_OUT PS(PS_IN input) : SV_Target
{   
	PS_OUT result = (PS_OUT)0;

	float2 screenPosition = ((float2)input.Position.xy)/screenSize;
	float pdepth =saturate(1-((1000*SS_GetDepth(screenPosition))) ) ;// 0.000006/SS_GetDepth(screenPosition) * distanceMultiplier/1000;
	 float3 pos = SS_GetPosition(screenPosition)*10000;
pdepth = length(pos*10)%1;
	float rpdepth = 0.26;//*(1000000/horisonDistance);
  // 
	

	ray_t rayx = {float3(0,1,0)*earth_radius*camera_h,-input.Normal*1};
	doublecom mierayleigh = get_incident_light(rayx,rpdepth);
	float3 rem = max(float3(0,0,0),mierayleigh.rayleigh+mierayleigh.mie*2);
	

    result.light = float4(
		rem
		+ 1-saturate(abs(dot(input.Normal,float3(0,1,0)))*100)
		,0.1);
   // result.light = float4(input.Normal,0.1);
    result.light =float4(pos,1);  
result.light =float4(pdepth,pdepth,pdepth,1);
    return result;
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