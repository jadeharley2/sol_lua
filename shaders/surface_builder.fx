
SamplerState TextureSampler { Filter = ANISOTROPIC; AddressU = Wrap; AddressV = Wrap; };
 
 
 

struct VS_IN
{
	float4 pos : POSITION; 
	float4 tcrd : TEXCOORD;  
};
 
struct PS_IN
{ 
	float4 pos : SV_POSITION; 
	float2 tcrd : TEXCOORD; 
};


struct PS_OUT
{
    float4 diffuse: SV_Target0; //rgba
    float4 normal: SV_Target1;  //xyz? 
    float4 specular: SV_Target2;//ip?? (intensity, power)
};

PS_IN VS( VS_IN input) 
{
	PS_IN output = (PS_IN)0;  
	output.pos =  input.pos; 
	output.tcrd = input.tcrd;
	return output;
}

PS_OUT PS( PS_IN input ) : SV_Target
{
	PS_OUT output = (PS_OUT)0;
	
	output.diffuse = float4(1,1,1,1);
	output.normal = float4(0,0,0,1);
	output.specular = float4(0,0,0,1);
	
	return output;
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