   

SamplerState sView
{
    Filter = MIN_MAG_MIP_POINT;//MIN_MAG_MIP_LINEAR;
    AddressU = Wrap;
    AddressV = Wrap;
};

SamplerState sCC
{
    Filter = MIN_MAG_MIP_LINEAR;//MIN_MAG_MIP_LINEAR;
    AddressU = Clamp;
    AddressV = Clamp;
};
  

Texture2D tDiffuse;   

float2 dir=float2(0.001,0);
bool mode = false;

const float offset[] = {0,1,2,3,4,5,6,7,8};
const float weight[] = {
//  0.2270270270, 
//  0.1945945946, 
//  0.1216216216,
//  0.0540540541, 
//  0.0162162162,
	0.169249, 
	0.165016, 
	0.152951, 
	0.134803,
	0.11301, 
	0.0901575, 
	0.0684875, 
	0.0495723, 
	0.0342152, 
	0.0225381
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

PS_IN VS( VS_IN input ) 
{
	PS_IN output = (PS_IN)0; 
	output.pos =  input.pos;
	output.tcrd = input.tcrd;
	return output;
} 
  
float3 Blur(float2 dir,float2 tcrd)
{ 
	float3 FragmentColor = tDiffuse.Sample(sCC, tcrd) * weight[0];
	//float3 FragmentColor = float3(0.0f, 0.0f, 0.0f);

	//(1.0, 0.0) -> horizontal blur
	//(0.0, 1.0) -> vertical blur
	float hstep = dir.x;
	float vstep = dir.y;

	[unroll]
	for (int i = 1; i < 9; i++) 
	{
		float2 off = offset[i];
		float w = weight[i];
		FragmentColor +=
			tDiffuse.Sample(sCC, tcrd + dir*off)*w +
			tDiffuse.Sample(sCC, tcrd - dir*off)*w;      
	} 
	return FragmentColor;
}   
float4 PS( PS_IN input ) : SV_Target
{   
	if(mode) 
	{ 
		return tDiffuse.Sample(sCC, input.tcrd);
	}
	else
	{
		float3 result =  Blur(dir,input.tcrd);//+ tDiffuse.Sample(sCC, input.tcrd);
		 
		return float4(result,1);
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