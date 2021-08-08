
float4x4 Projection;
float4x4 View;
float4x4 World;
float4x4 invWVP;
float4x4 VP;

Texture2D tDiffuseView;   
Texture2D tNormalView;    
Texture2D tDepthView;   
Texture2D tMaskView;     

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

float3 SS_GetPosition2(float2 UV, float depth)
{
	float4 position = 1.0f; 
 
	position.x = UV.x * 2.0f - 1.0f; 
	position.y = -(UV.y * 2.0f - 1.0f); 

	position.z = depth; 
 //position.w = 1;
	//Transform Position from Homogenous Space to World Space 
	position = mul(position, invWVP);  
 
	//position *= position.w;
	position /= position.w;

	return position.xyz;
}
float3 SS_GetUV(float3 position)
{
	 float4 pVP = mul(float4(position, 1.0f), VP);
	 //pVP.w = 1;
	 pVP.xy = float2(0.5f, 0.5f) + float2(0.5f, -0.5f) * pVP.xy/ pVP.w ;/// pVP.w
	 return float3(pVP.xy, pVP.z/ pVP.w);// / pVP.w
}
float3 SS_GetColor(float2 position,float level)
{ 
	 return tDiffuseView.SampleLevel(sCC, position,level);
}
float SS_GetDepth2(float2 position)
{ 
	 return tDepthView.Sample(sCC, position).r;
}

float LDelimiter = 2400000;
float4 SSLR(PS_IN input,float reflectiveness,float roughness,float metalness )
{
	//return  SS_GetColor(input.tcrd*1,1.001).rgb;
	float3 texelDiffuse = SS_GetColor(input.tcrd,0);

	float3 localNormal = tNormalView.Sample(sCC, input.tcrd).xyz;
	float3 ssNormal = normalize((localNormal -float3(0.5,0.5,0.5))*2);
	float3 texelNormal =ssNormal;
	float texelDepth = SS_GetDepth2(input.tcrd);

	float3 texelPosition = SS_GetPosition2(input.tcrd,texelDepth);
	float3 viewDir = normalize(texelPosition);
	float3 reflectDir = normalize(reflect(-viewDir, texelNormal));
	 
	 //return texelPosition;
	// return reflectDir*0.5+0.5;//SS_GetColor(getUV(texelPosition),0);
//	 return SS_GetColor(SS_GetUV(texelPosition+reflectDir*-0.003),0).rgb;
	 //return texelNormal;
	 //return (SS_GetUV(texelPosition+texelNormal*0.00003)*float3(1,1,0)-float3(input.tcrd,0))*0.5+0.5;
	float3 currentRay = 0;
	
	float3 nuv = 0;
	float L = 0.001;//0.0000001;
	float endDepth;

	float3 newPosition = texelPosition;
	
	[unroll]
	for(int i = 0; i < 10; i++)
	{
		currentRay = texelPosition + -reflectDir * L;

		nuv = SS_GetUV(currentRay); // проецирование позиции на экран
		endDepth =max(0.00, SS_GetDepth2(nuv.xy)); // чтение глубины из DepthMap по UV
		
		newPosition = SS_GetPosition2(nuv.xy, endDepth);
		L = length(texelPosition - newPosition);
	} 
	//return L*100000; 
	//return (texelDepth-endDepth)*-10000;
	//return (newPosition-texelPosition)*1000;//-float3(input.tcrd,0);
	//return L*200;
	//float cdot2 = saturate(pow(1-dot(viewDir,texelNormal),2));
	//float3 cnuv2 =10 *texelDiffuse* SS_GetColor(nuv.xy,10).rgb*cdot2;
	//return (nuv*float3(1,1,0)-float3(input.tcrd,0))*0.5+0.5;

	if(texelDepth<endDepth) return 0;// texelDiffuse;//+cnuv2*reflectiveness;
	//L = saturate(L * LDelimiter);
	float error = saturate(1 - L);
	if(L>0.99) error = 1;//sky fix
	//if(error!=error) error =0;
	//error = saturate(error);
	
	float cdot = saturate(pow(1-dot(viewDir,-texelNormal),5));
	float blur = 0;//(int)min(9,saturate(L*10000000)+roughness*roughness*10);//+cdot*10;
	
	float darken = saturate(1
	-saturate(nuv.x*4-3)-saturate(1-nuv.x*4)
	-saturate(nuv.y*4-3)-saturate(1-nuv.y*4)
	 
	);
	//return cdot;
	//if(nuv.x<0||nuv.x>1||nuv.y<0||nuv.y>1) return 0;
	float3 cnuv = SS_GetColor(nuv,blur).rgb;
	
	cnuv = max(float3(0,0,0),lerp(cnuv,cnuv*normalize(texelDiffuse),metalness));
	//return nuv.x/3;
	//return  texelPosition;
	//if (!isfinite(cnuv.x)) return float3(1,0,0);
	//return cnuv*10;
 //return L*10000;
	
	return lerp(float4(0,0,0,0),float4(cnuv,1),cdot*reflectiveness*error*darken);  
}


PS_IN VS( VS_IN input ) 
{
	PS_IN output = (PS_IN)0; 
	output.pos =  input.pos;
	output.tcrd = input.tcrd; 
	return output;
} 

float4 PS( PS_IN input ) : SV_Target
{  
	float4 pMask = tMaskView.Sample(sView, input.tcrd);
    float4 rez = SSLR(input,pMask.y,1-pMask.y,pMask.z);
    return rez*1;
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