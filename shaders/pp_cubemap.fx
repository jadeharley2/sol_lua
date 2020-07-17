float pad=1;

float4x4 Projection;
float4x4 View;
float4x4 World; 

float4x4 InvWVP;
float2 viewSize;

TextureCube tCubemap;   
Texture2D tDiffuseView;     
Texture2D tNormalView;     
Texture2D tDepthView;      
Texture2D tMaskView;   
    

float4 pad2=1;
float pad3=1;
float pad32233=1;
SamplerState sView
{
    Filter = MIN_MAG_MIP_LINEAR;//MIN_MAG_MIP_LINEAR;
    AddressU = Wrap;
    AddressV = Wrap;
};

struct VS_IN 
{
	float4 pos : POSITION; 
	float3 norm : NORMAL; 
	float3 bnorm : BINORMAL; 
	float3 tnorm : TANGENT; 
	float3 color : COLOR0; 
	float2 tcrd : TEXCOORD; 
}; 
struct PS_IN
{ 
	float4 pos : SV_POSITION; 
	float norm : TEXCOORD; 
	float3 wdp : TEXCOORD1; 
    
}; 
struct PS_OUT
{
    float4 light : SV_TARGET0;
    //float stencill : SV_STENCILREF;
};

float2 getUV(float4 pos)
{
    return pos.xy/viewSize;
}
float3 getNormal(float2 uv)
{
    return tNormalView.Sample(sView, uv) * 2.0 - 1.0;
}
float3 SS_GetPosition(float2 UV)
{
    float depth =  tDepthView.Sample(sView, UV).x;
    float4 position = 1.0f; 

    position.x = UV.x * 2.0f - 1.0f; 
    position.y = -(UV.y * 2.0f - 1.0f); 

    position.z = depth; 

    position = mul(position, InvWVP);  
 
    position /= position.w;

    return position.xyz;
}


PS_IN VS( VS_IN input ) 
{ 
	float4x4 VP =mul(View,Projection); 
	float4 wpos = mul(input.pos,World);

	PS_IN output = (PS_IN)0; 
	output.pos =  mul(wpos,VP); 
    float3 xnrm = mul(input.norm,(float3x3)World);
    output.wdp = input.pos;
    output.norm = dot(normalize(xnrm),(wpos.xyz)/output.wdp);
	return output;
} 

PS_OUT PS_PBR( PS_IN input ) : SV_Target
{    
    PS_OUT result = (PS_OUT)0;
    float2 uv = getUV(input.pos); 

    float3 normal = getNormal(uv);
    
    float cdepth = input.pos.z;
    float depth =  tDepthView.Sample(sView, uv).x;
    float4 mask  =  tMaskView.Sample(sView, uv).x;
	float miplevel = (1-saturate(mask.y))*20;
    float3 ctex = tCubemap.SampleLevel(sView,normal,miplevel)*mask.x;
    //float3 pos = SS_GetPosition(uv);
    float diff = saturate((depth-cdepth)*10000);
    result.light =1;// float4(ctex*diff,diff);
    //result.stencill = 1; 
    return result;
}

technique10 Render
{
	pass P0
	{
		SetGeometryShader( 0 );
		SetVertexShader( CompileShader( vs_4_0, VS() ) );
		SetPixelShader( CompileShader( ps_4_0, PS_PBR() ) );
	}
}