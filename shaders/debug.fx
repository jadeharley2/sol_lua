float4x4 Projection;
float4x4 View;
float4x4 World;

float4 Color = float4(1,1,1,1);
float4 Color2 = float4(0.1,0.5,1,1);
 
struct VS_IN
{
	float4 pos : SV_POSITION; 
};
struct I_IN
{
	float4x4 transform : WORLD; 
	float4 color : COLOR;
};
 
struct PS_IN
{ 
	float4 pos : SV_POSITION;
	float z_depth : TEXCOORD1;
	float4 color : TEXCOORD2;
};


PS_IN VS( VS_IN input) 
{
	PS_IN output = (PS_IN)0;
	float4x4 mx = mul(mul(transpose(World) ,	transpose(View)),	transpose(Projection));
	output.pos =  mul( input.pos,	mx) ;
	output.color = float4(1,1,1,1);
	
	return output;
}

PS_IN VSI( VS_IN input, I_IN inst ) 
{
	PS_IN output = (PS_IN)0;
	float4x4 mx = mul(mul(transpose(World) ,	transpose(View)),	transpose(Projection));
	
	output.pos =  mul(	mul(input.pos,transpose(inst.transform)),		 mx);
	output.z_depth = output.pos.z;
	output.color = inst.color;
	
	return output;
}

float4 PS( PS_IN input ) : SV_Target
{
	return input.color*(Color*saturate(50/input.z_depth)+Color2*saturate(1-50/input.z_depth));
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