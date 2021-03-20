
 
#include "headers/enviroment.fxh"

float4x4 Projection;
float4x4 View;
float4x4 World;
   
float4x4 EnvInverse;

float3 Color = float3(1,1,1)*0.9;

float global_scale=1; 
float hdrMultiplier=1;
float brightness=1;

float time =0;
float2 textureshiftdelta = float2(0,0);
float2 texcoordmul = float2(1,1);

 
Texture2D g_MeshTexture;  
Texture2D g_MeshTexture2;  

Texture2D g_NoiseTexture;  
Texture2D g_DetailTexture;   
Texture2D g_DetailTexture_n;   
 
bool TextureEnabled = true;
bool DetailEnabled = true; 
bool is_blackhole = false;
  
float2 detailscale = float2(0.01,0.01);
   

SamplerState MeshTextureSampler
{
    Filter = MIN_MAG_MIP_LINEAR;
    AddressU = Wrap;
    AddressV = Wrap;
};
 
 

struct VSS_IN
{
	float4 pos : POSITION; 
	float3 norm : NORMAL;  
	float3 bnorm : BINORMAL; 
	float3 tnorm : TANGENT; 
	float2 tcrd : TEXCOORD; 
    float4 wts  : BLENDWEIGHT;
    float4 inds  : BLENDINDICES;
	float3 color : COLOR0; 
	
	 
};

struct I_IN
{
	float4x4 transform : WORLD; 
};
 
struct PS_IN
{ 
	float4 pos : SV_POSITION;
	float2 tcrd : TEXCOORD0; 
	float3 wpos : TEXCOORD1; 
	float3 norm : TEXCOORD2;  
	float3 bnorm : TEXCOORD3; 
	float3 tnorm : TEXCOORD4;
	
	float3 color : TEXCOORD5;
	float3 spos : TEXCOORD6;
	
	half layer :TEXCOORD7;
	//float z_depth : TEXCOORD2;
};
 
struct PS_OUT
{
    float4 light: SV_Target0;
    float4 normal: SV_Target1; 
    float depth: SV_Target2;
    float4 mask: SV_Target3;// r - deferred_intensity, g - smootheness, b - metallness, a - subsurface_scattering_transparency
    float4 diffuse: SV_Target4; 
};


PS_IN VSI( VSS_IN input, I_IN inst ) 
{
	PS_IN output = (PS_IN)0; 
	float4x4 InstWorld = mul(inst.transform,World);
	float4 wpos = mul(input.pos,InstWorld);
	float4x4 VP =mul(View,Projection);
	
	float3x3 nworld = (float3x3)(InstWorld);
	
	output.pos =  mul(wpos,VP);
	output.wpos = wpos.xyz;
	output.norm = normalize(mul(input.norm,nworld)); 
	output.bnorm = normalize(mul(input.bnorm,nworld)); 
	output.tnorm = normalize(mul(input.tnorm,nworld)); 
	output.tcrd = input.tcrd;
	output.color = input.color;//((float3)input.inds.xyz);
	output.spos = input.pos;
	return output;
}
   

PS_OUT PS( PS_IN input ) : SV_Target
{ 
	PS_OUT output = (PS_OUT)0;
	    
	 
	float3 rer = normalize(input.norm); 
	float dotz = saturate(rer.y);

	float2 texCoord = input.tcrd;
	float4 dtexIn1 = g_MeshTexture.Sample(MeshTextureSampler, input.spos.xz*0.1);
	float4 dtexIn1b = g_MeshTexture.Sample(MeshTextureSampler, input.spos.xz*0.01);
	float4 dtexIn2 = g_MeshTexture2.Sample(MeshTextureSampler, input.spos.xz*0.1);
	float4 dtexIn2b = g_MeshTexture2.Sample(MeshTextureSampler, input.spos.xz*0.01);

    float noise = g_NoiseTexture.Sample(MeshTextureSampler, input.spos.xz*0.004)-0.5;
    float noise2 = g_NoiseTexture.Sample(MeshTextureSampler, input.spos.xz*0.02)-0.5;
			
	float3 camdir = normalize(input.wpos);		 
	float3 reflectcam = reflect(camdir,input.norm);
    float3 reflectEnv =  mul(float4(reflectcam,1),EnvInverse).xyz;
	float3 envmap = max(float3(0,0,0),EnvSampleLevel(reflectEnv,1));
  
    output.diffuse =  lerp(dtexIn2*dtexIn2b*2,dtexIn1*dtexIn1b*2,saturate(pow(dotz,6)*2+(noise*2+noise2*1)-0.5));
    output.depth = input.pos.z;
    output.mask = float4(1,0,0,0);
	    
	output.normal = float4(rer.x/2+0.5,rer.y/2+0.5,rer.z/2+0.5,1); 
    output.light = float4(envmap,0);

	return output;
}

 
technique10 Instanced
{
	pass P0
	{
		SetVertexShader( CompileShader( vs_4_0, VSI() ) );
		SetGeometryShader(  0 ); 
		SetPixelShader( CompileShader( ps_4_0, PS() ) );
	}
} 