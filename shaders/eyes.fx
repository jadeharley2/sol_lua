
#include "headers/skin.fxh"
#include "headers/lightning.fxh"
#include "headers/clip.fxh"
#include "headers/enviroment.fxh"

float4x4 Projection;
float4x4 View;
float4x4 World;

float4x4 EyeWorld;

Texture2D g_MeshTexture;  
Texture2D g_IrisTexture;   
 

float hdrMultiplier=1;
float brightness=1;

float2 flipuv = float2(1,1);
float2 texShift = float2(0,0);
float eyeScale = 1;

int eyeId;

SamplerState MeshTextureSampler
{
    Filter = MIN_MAG_MIP_LINEAR;
    AddressU = Clamp;
    AddressV = Clamp;
};
struct I_IN
{
	float4x4 transform : WORLD; 
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
};
struct DCI_PS_IN
{ 
	float4 pos : SV_POSITION;  
	float2 tcrd : TEXCOORD0; 
};
struct PS_OUT
{
    float4 color: SV_Target0;
    float4 normal: SV_Target1;
    //float4 position: SV_Target2;
    float depth: SV_Target2;
    float4 mask: SV_Target3;
};

PS_IN VSI( VSS_IN input, I_IN inst ) 
{
	PS_IN output = (PS_IN)0;
	if(SkinningEnabled)
	{
		Skin(input.pos,input.norm,input.wts,input.inds);
	}
	float4x4 InstWorld = mul(transpose(inst.transform),transpose(World));
	float4 wpos = mul(input.pos,InstWorld);
	float4x4 VP =mul(transpose(View),transpose(Projection));
	
	float3x3 nworld = (float3x3)(InstWorld);
	
	output.pos =  mul(wpos,VP);
	output.wpos =input.pos;// wpos.xyz;///wpos.w;
	output.norm = normalize(mul(input.norm,nworld)); 
	output.bnorm = normalize(mul(input.bnorm,nworld)); 
	output.tnorm = normalize(mul(input.tnorm,nworld)); 
	output.tcrd = input.tcrd;
	output.color = input.color; 
	output.spos = mul(wpos,transpose(View));
	return output;
}
PS_OUT PS( PS_IN input ) : SV_Target
{  
	PS_OUT output = (PS_OUT)0;
	
	//ClipProcess(input.wpos);
	float TBrightness = brightness * hdrMultiplier;
	
	//float4 wmpos = mul(float4(input.wpos,1),transpose(EyeWorld));
	//float2 wmTexCoord = float2(0.5,-0.5) *(wmpos.xy/  wmpos.w  + float2( 1, -1 )) ;// /  wmpos.w
	float4 result =  g_MeshTexture.Sample(MeshTextureSampler, input.tcrd  );
	
	//float4 irisDiffuse  = float4(0,0,0,1);
	//if(wmpos.z<1&&wmpos.z>0)
	//{
		//wmTexCoord = (wmTexCoord - float2(0.5,0.5))*2+float2(0.5,0.5);
		float2 wmTexCoord = (input.tcrd - float2(0.5,0.5)+ texShift*flipuv)/eyeScale  + float2(0.5,0.5);
		
		//(wmTexCoord - float2(0.5,0.5))/10+float2(0.5,0.5);
		float4 irisDiffuse = g_IrisTexture.Sample(MeshTextureSampler, wmTexCoord ); // +float4((wmpos.xyz*1)%1,0)*0.8; 
	//} 
	
	
	result = lerp(result,irisDiffuse,irisDiffuse.a);
	
	float3 camdir = normalize(input.wpos);
	float3 brightness3 = ApplyPointLights(input.wpos,input.norm,camdir,0,0,true);
	float3 reflectcam = reflect(camdir,input.norm);
	float3 ambmap =  EnvSampleLevel(input.norm,0);
	float3 envmap =  EnvSampleLevel(reflectcam,0.99);//
		
	output.color = result*float4((brightness3*0.3+envmap*0.4+ambmap*0.5)*TBrightness,1);// + float4(0,0,eyeId,0);
	output.normal = float4(input.norm*0.5+0.5,1);
	output.depth = input.pos.z/input.pos.w; 
	output.mask = float4(1,1,0,1);
	
	return output;
}

DCI_PS_IN CI_VSI( VSS_IN input, I_IN inst ) 
{
	DCI_PS_IN output = (DCI_PS_IN)0;
	if(SkinningEnabled)
	{
		Skin(input.pos,input.norm,input.wts,input.inds);
	}
	float4x4 InstWorld = mul(transpose(inst.transform),transpose(World));
	float4 wpos = mul(input.pos,InstWorld);
	float4x4 VP =mul(transpose(View),transpose(Projection));
	
	float3x3 nworld = (float3x3)(InstWorld);
	
	output.pos =  mul(wpos,VP);
	///////////////////////////////////
	#ifdef SHADOWWARP_ENABLED
	  output.pos.x=output.pos.x/(abs(output.pos.x)+depth_shadow_bendadd); 
	  output.pos.y=output.pos.y/(abs(output.pos.y)+depth_shadow_bendadd);
	#endif
	///////////////////////////////////

	output.tcrd = input.tcrd;
	return output;
}
float SHADOW_PS_FLOAT( DCI_PS_IN input ) : SV_Target
{  
	float dp = input.pos.z*input.pos.w; 
	return dp; 
}

technique10 Instanced
{
	pass P0
	{
		SetGeometryShader( 0 );
		SetVertexShader( CompileShader( vs_4_0, VSI() ) );
		SetPixelShader( CompileShader( ps_4_0, PS() ) );
	}
}
technique10 shadow
{
	pass P0
	{
		SetGeometryShader( 0 );
		SetVertexShader( CompileShader( vs_4_0, CI_VSI() ) );
		SetPixelShader( CompileShader( ps_4_0, SHADOW_PS_FLOAT() ) );
	}
}