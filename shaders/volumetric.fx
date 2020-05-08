float4x4 Projection;
float4x4 View;
float4x4 World;


float4x4 WVPInverse;

Texture2D g_MeshTexture;     
float4 color = float4(1,1,1,1);
float global_scale = 1;

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

struct PS_IN
{ 
	float4 pos : SV_POSITION; 
	float3 lpos : TEXCOORD1;
	float3 wpos : TEXCOORD2;
};

PS_IN VS( VS_IN input ) 
{
	//viewspace mesh > get world coordinates values
	PS_IN output = (PS_IN)0; 
	
	float4x4 VP = mul((View),(Projection)); 
	  
	output.wpos = mul(input.pos,(World));
	output.lpos =  mul(input.pos,(WVPInverse));
	output.pos =  mul( output.wpos,VP) ; 
	return output; 
}  
  
float4 PS( PS_IN input ) : SV_Target
{ 
	float3 wp = input.lpos*global_scale;
	float3 color = float3(1,1,1);   
	float alpha = saturate((1-length(wp))/450*10);//saturate(0.01/(length(wp)));
	//return float4(1,1,1,1)/100; 
	return float4(color*alpha,alpha); 
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