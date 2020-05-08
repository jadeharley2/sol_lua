float4x4 Projection;
float4x4 View;
float4x4 World;

Texture2D g_MeshTexture;     
bool TextureEnabled = false;
float4 color = float4(1,1,1,1);

SamplerState MeshTextureSampler
{
    Filter = MIN_MAG_MIP_LINEAR;
    AddressU = Wrap;
    AddressV = Wrap;
};



struct VS_IN
{
	float4 pos : SV_POSITION;
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
};

PS_IN VS( VS_IN input, I_IN inst ) 
{
	PS_IN output = (PS_IN)0;
	float4x4 mx = mul(mul((World) ,	(View)),	(Projection));
	
	output.pos =  mul(	mul(input.pos,(inst.transform)),		 mx); 
	output.tcrd = input.tcrd;
	return output;
} 

float4 PS( PS_IN input ) : SV_Target
{
	if(TextureEnabled)
	{
		return //float4(input.tcrd,0,1);//
		g_MeshTexture.Sample(MeshTextureSampler, input.tcrd)*color;
	}
	else
	{
		return color;
	}
}

technique10 Render
{
	pass P0
	{
		SetGeometryShader( 0 );
		SetVertexShader( CompileShader( vs_4_0, VS() ) );
		SetPixelShader( CompileShader( ps_4_0, PS() ) );
	}
}