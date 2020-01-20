
float4 pad= float4(1,1,1,1);
float4 tint = float4(1,1,1,1);
Texture2D sTexture;     

SamplerState TextureSampler
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
struct PS_IN
{ 
	float4 pos : SV_POSITION;
	float2 tcrd : TEXCOORD;
};

PS_IN VS( VS_IN input) 
{
	PS_IN output = (PS_IN)0; 
	
	output.pos =  input.pos;
	output.tcrd = input.tcrd;
	return output;
} 

float4 PS( PS_IN input ) : SV_Target
{
	return  sTexture.Sample(TextureSampler, input.tcrd);//*tint;
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