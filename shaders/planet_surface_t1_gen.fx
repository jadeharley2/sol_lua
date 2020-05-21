
 
float4x4 Projection;
float4x4 View;
float4x4 World;
   
float hscale = 0.3f; 
//int mode =0;
 
//data 
//g_Spritesheet.rgb   - color 
//g_Spritesheet.a     - blending
//g_Spritesheet_n.rgb - normal
//g_Spritesheet_n.a   - blending
//g_Spritesheet_h.rgb - height
//g_Spritesheet_h.a   - blending
Texture2D g_Spritesheet;   
Texture2D g_Spritesheet_n;   
Texture2D g_Spritesheet_h;  
  
SamplerState MeshTextureSampler
{
    Filter = MIN_MAG_MIP_LINEAR;
    AddressU = Wrap;
    AddressV = Wrap;
};
 

struct VS_IN
{
	float4 pos : POSITION; 
	float3 norm : NORMAL; 
	float3 bnorm : BINORMAL; 
	float3 tnorm : TANGENT; 
	float2 tcrd : TEXCOORD0; 
};

struct VSS_IN
{
	float4 pos : POSITION; 
	float3 norm : NORMAL;  
	float3 bnorm : BINORMAL; 
	float3 tnorm : TANGENT; 
	float4 tcrd : TEXCOORD;  
	float4 data : TEXCOORD1;  
	float3 color : COLOR0; 
	
	 
};

struct I_IN
{
	float4x4 transform : WORLD; 
	float4 spriteCoord : TEXCOORD2;
};
 
struct PS_IN
{ 
	float4 pos : SV_POSITION;
	float2 tcrd : TEXCOORD0; 
	//float3 wpos : TEXCOORD1; 
	float3 norm : TEXCOORD2;  
	float3 bnorm : TEXCOORD3; 
	float3 tnorm : TEXCOORD4;
	
	//float3 color : TEXCOORD5;
	//float3 spos : TEXCOORD6;
	
	//float z_depth : TEXCOORD2;
};
 
struct PS_OUT
{
    float4 color: SV_Target0;
    float4 normal: SV_Target1;
    float4 height: SV_Target2;
};

PS_IN VSI( VSS_IN input, I_IN inst ) 
{
	PS_IN output = (PS_IN)0; 
	float4x4 InstWorld = mul((inst.transform),(World));
	float4 wpos = mul(input.pos,InstWorld);
	float4x4 VP =mul((View),(Projection));
	
	float3x3 nworld = (float3x3)(InstWorld);
	
	output.pos =  mul(wpos,VP);
	//output.wpos = wpos.xyz;
	output.norm = normalize(mul(input.norm,nworld)); 
	output.bnorm = normalize(mul(input.bnorm,nworld)); 
	output.tnorm = normalize(mul(input.tnorm,nworld)); 
	output.tcrd =   input.tcrd;//*spriteCoord.zw+ints.spriteCoord.xy; 
	return output;
}

PS_OUT PS( PS_IN input ) : SV_Target
{ 
	PS_OUT output = (PS_OUT)0;
  
	
	float4 diffMap = g_Spritesheet.Sample(MeshTextureSampler, input.tcrd);
	float4 bumpMap = g_Spritesheet_n.Sample(MeshTextureSampler, input.tcrd);
	float4 heightMap = g_Spritesheet_h.Sample(MeshTextureSampler, input.tcrd);
    
	if(bumpMap.x!=0 && bumpMap.y!=0 && bumpMap.z!=0)
	{
		bumpMap = bumpMap*2-1;
		float3 bumpNormal = (bumpMap.x * input.tnorm) + (bumpMap.y * -input.bnorm) + (bumpMap.z * input.norm);
		input.norm = normalize(bumpNormal); 
	} 
	
	//blend by alpha
	
	//if (mode==0)//add
	//{
		output.color =  diffMap*hscale;//*float4(hscale,hscale,hscale,hscale);
	//} 
	//if (mode==1)//sub
	//{
	//	output.color =  (diffMap-float4(0.5,0.5,0.5,0))*float4(-hscale,-hscale,-hscale,1);  
	//}//
	output.normal = bumpMap;  
	output.height = heightMap; 
	  
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