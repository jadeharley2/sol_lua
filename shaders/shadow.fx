
#include "headers/skin.fxh" 

float4x4 Projection;
float4x4 View;
float4x4 World;

//Texture2D g_MeshTexture;   
//bool TextureEnabled = false;

struct VS_IN
{
	float4 pos : POSITION; 
	float2 tcrd : TEXCOORD; 
};

struct I_IN
{
	float4x4 transform : WORLD; 
};
 
struct PS_IN
{ 
	float4 pos : SV_POSITION; 
	float2 tcrd : TEXCOORD;
	//float z_depth : TEXCOORD2;
};

struct PS_OUT
{
    float depth: SV_Target0; 
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
	output.tcrd = input.tcrd; 
	return output;
}


PS_OUT PS( PS_IN input ) : SV_Target
{ 
	PS_OUT output = (PS_OUT)0;
	
	output.depth = input.pos.z;
	
	return output;
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
