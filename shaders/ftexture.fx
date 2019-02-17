float4x4 Projection;
float4x4 View;
float4x4 World;

float4 Color = float4(1,1,1,1); 
 
Texture2D texS;   
Texture2D texH;     
 
SamplerState TextureSampler
{
    Filter = ANISOTROPIC;
    AddressU = Clamp;
    AddressV = Clamp;
};

struct VS_IN
{
	float4 pos : POSITION; 
	float2 tcrd : TEXCOORD;
};
struct I_IN
{
	float4x4 transform : WORLD; 
	float4 color : COLOR;
};
 
struct PS_IN
{ 
	float4 pos : SV_POSITION;
	float2 tcrd : TEXCOORD;
	float4 color : TEXCOORD1;
	//float z_depth : TEXCOORD2;
};


PS_IN VS( VS_IN input) 
{
	PS_IN output = (PS_IN)0;
	
	output.pos =  mul(mul(mul(	input.pos,	World),	View),	Projection);
	output.tcrd = input.tcrd;
	output.color = float4(1,1,1,1);
	return output;
}

PS_IN VSI( VS_IN input, I_IN inst ) 
{
	PS_IN output = (PS_IN)0;
	
	output.pos =  mul(mul(mul(	mul(input.pos,transpose(inst.transform)),		World),	View),	Projection);
	output.tcrd = input.tcrd;
	output.color = inst.color;
	
	return output;
}

float4 PS( PS_IN input ) : SV_Target
{
	float4 diffuse = texS.Sample(TextureSampler,input.tcrd);
	//float height = texH.Sample(TextureSampler,input.tcrd);
	float result = diffuse * input.color;
	return result;
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
technique10 Normal
{
	pass P0
	{
		SetGeometryShader( 0 );
		SetVertexShader( CompileShader( vs_4_0, VS() ) );
		SetPixelShader( CompileShader( ps_4_0, PS() ) );
	}
}