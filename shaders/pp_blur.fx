 


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
Texture2D tMask;  

float2 dir=float2(0.001,0);

const float offset[] = {0.0, 1.3846153846, 3.2307692308};
const float weight[] = {0.2270270270, 0.3162162162, 0.0702702703};

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
   // return 1-tMask.Sample(sCC, tcrd).y;
	float3 FragmentColor = tDiffuse.Sample(sCC, tcrd) * weight[0];
	//float3 FragmentColor = float3(0.0f, 0.0f, 0.0f);

	//(1.0, 0.0) -> horizontal blur
	//(0.0, 1.0) -> vertical blur
	float hstep = dir.x;
	float vstep = dir.y;

    float3 mask = tMask.Sample(sCC, tcrd);
    float blurpower = (1-mask.y)*6;

	[unroll]
	for (int i = 1; i < 3; i++) 
	{
		float off = offset[i]*blurpower;
		float w = weight[i];
		FragmentColor +=
			tDiffuse.Sample(sCC, tcrd +  float2(hstep*off,vstep*off))*w +
			tDiffuse.Sample(sCC, tcrd -  float2(hstep*off,vstep*off))*w;      
	} 
	return FragmentColor*mask.x;
}   
float4 PS( PS_IN input ) : SV_Target
{   
    //return  tDiffuse.Sample(sCC, input.tcrd);
    float3 result =  Blur(dir,input.tcrd);//+ tDiffuse.Sample(sCC, input.tcrd);
        
    return float4(result,1);
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