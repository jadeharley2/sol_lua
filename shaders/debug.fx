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
	float4x4 mx = mul(mul((World) ,	(View)),	(Projection));
	output.pos =  mul( input.pos,	mx) ;
	output.color = float4(1,1,1,1);
	
	return output;
}

PS_IN VSI( VS_IN input, I_IN inst ) 
{
	PS_IN output = (PS_IN)0;
	float4x4 mx = mul(mul((World) ,	(View)),	(Projection));
	
	output.pos =  mul(	mul(input.pos,(inst.transform)),		 mx);
	output.z_depth = output.pos.z;
	output.color = inst.color;
	
	return output;
}

float4 PS( PS_IN input ) : SV_Target
{
	return input.color*(Color*saturate(50/input.z_depth)+Color2*saturate(1-50/input.z_depth));
}

struct CVS_IN
{
	float4 pos : SV_POSITION; 
	float4 normal : NORMAL;
	float4 color : COLOR;
}; 
 
struct CPS_IN
{ 
	float4 pos : SV_POSITION; 
	float3 normal : TEXCOORD0;
	float3 color : TEXCOORD1;
};
struct CPS_OUT
{ 
    float4 light: SV_Target0;
    float4 normal: SV_Target1; 
    float depth: SV_Target2;
    float4 mask: SV_Target3;// r - deferred_intensity, g - smootheness, b - metallness, a - subsurface_scattering_transparency
    float4 diffuse: SV_Target4; 
};

CPS_IN CVSI( CVS_IN input, I_IN inst ) 
{
	CPS_IN output = (CPS_IN)0;
	float4x4 world =  mul( (inst.transform),(World));
	float4x4 vp = mul((View),	(Projection));
	
	float3x3 mxr = (float3x3)world;

	float4x4 mx = mul(mul((World) ,	(View)),	(Projection));
	output.pos =  mul( input.pos,	mx) ;
	//output.pos =  mul(mul(input.pos,world), vp); 
	output.normal = mul(input.normal,mxr);
	output.color = inst.color.xyz*input.color.xyz;
	
	return output;
}
  
CPS_OUT CPS( CPS_IN input )  
{
	CPS_OUT output = (CPS_OUT)0;
	output.diffuse =float4( input.color*Color.xyz,1);
	output.normal = float4(input.normal,1);
	output.depth = input.pos.z;
	output.mask = float4(1,0,0,0);
	output.light = output.diffuse*0.1;
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
technique10 Normal
{
	pass P0
	{
		SetGeometryShader( 0 );
		SetVertexShader( CompileShader( vs_4_0, VS() ) );
		SetPixelShader( CompileShader( ps_4_0, PS() ) );
	}
}
technique10 ComplexInstanced
{
	pass P0
	{
		SetGeometryShader( 0 );
		SetVertexShader( CompileShader( vs_4_0, CVSI() ) );
		SetPixelShader( CompileShader( ps_4_0, CPS() ) );
	}
}  