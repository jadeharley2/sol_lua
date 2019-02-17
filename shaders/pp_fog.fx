  
#include "headers/atmosphere.fxh"
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

float4x4 Projection;
float4x4 View;
float4x4 World;
float4x4 invWVP;
float4x4 VP;

Texture2D tDiffuseView;   
Texture2D tNormalView;    
Texture2D tPositionView;    
Texture2D tDepthView;   
Texture2D tMaskView;     
Texture2D tNoise;   
float3 vCameraDirection; 

float2 screenSize = float2(1024,1024);
float exposure = 0.1;
float gamma = 0.5;



float3 planetPos;
float distanceMultiplier=1;
float horisonDistance=1;
bool hasAtmoshphere = true;

float3 lightDir; 
float3 lightColor=float3(1,1,1); 



float SS_GetDepth(float2 position)
{ 
	 return tDepthView.Sample(sCC, position).r;
}
float3 SS_GetPosition(float2 UV, float depth)
{
	float4 position = 1.0f; 
 
	position.x = UV.x * 2.0f - 1.0f; 
	position.y = -(UV.y * 2.0f - 1.0f); 

	position.z = depth; 
 
	//Transform Position from Homogenous Space to World Space 
	position = mul(position, transpose(invWVP));  
 
	//position /= position.w;

	return position.xyz;
}
float3 SS_GetUV(float3 position)
{
	 float4 pVP = mul(float4(position, 1.0f),transpose( VP));
	 pVP.xy = float2(0.5f, 0.5f) + float2(0.5f, -0.5f) * pVP.xy / pVP.w;
	 return float3(pVP.xy, pVP.z / pVP.w);
}
float3 SS_GetColor(float2 position,float level)
{ 
	 return tDiffuseView.SampleLevel(sCC, position,level);
}
float3 SS_GetNormal(float2 position)
{ 
	 return tNormalView.Sample(sCC, position);
}
 
struct VS_IN 
{
	float4 pos : SV_POSITION;
	float2 tcrd : TEXCOORD;
}; 
  

struct PS_IN
{ 
	float4 pos : SV_POSITION;
	float3 wpos : TEXCOORD0;
	float2 tcrd : TEXCOORD1;
};

PS_IN VS( VS_IN input ) 
{ 
	float4 wpos = mul(input.pos,transpose(World));
	float4x4 VP =mul(transpose(View),transpose(Projection));
	
	//float3x3 nworld = (float3x3)(InstWorld);
	
	
	PS_IN output = (PS_IN)0; 
	//output.pos =  input.pos;
	output.pos =  mul(wpos,VP);
	output.wpos = wpos;
	output.tcrd = input.tcrd;
	return output;
} 
   
 
float4 FogSample(float2 tcrd,float pDepth)
{
	float inten = saturate(100/pDepth);
	float3 color = float3(0.1,0.9,0.3)/4;
	return float4( color*inten,inten);
}
  
float4 PS( PS_IN input ) : SV_Target
{  
	input.tcrd = input.pos.xy/screenSize;
	float4 pDiffuse = tDiffuseView.Sample(sView, input.tcrd);
	//return float4(pDiffuse.rgb*0.2,1);
	float4 pNormal = tNormalView.Sample(sView, input.tcrd);//float4((tNormalView.Sample(sView, input.tcrd).xyz-float3(0.5,0.5,0.5))*2,1);
	float pDepth = tDepthView.Sample(sView, input.tcrd);
	float4 pMask = tMaskView.Sample(sView, input.tcrd);
	
	float d2 = SS_GetDepth(input.tcrd);
	input.wpos = SS_GetPosition(input.tcrd,d2) ;
	//return float4(input.wpos*10000,1);
	
	float wposLen = length(input.wpos);
	float surfaceDistance =10/(pDepth /distanceMultiplier);// wposLen * distanceMultiplier;
	
	input.wpos *= surfaceDistance/1000000000000.0;
	  
	float3 cameraDirection = input.wpos/wposLen; 
	float3 globalNormal = normalize(input.wpos-planetPos);//*saturate(surfaceDistance*0.01)); 
	float horizdist = max(5,horisonDistance*distanceMultiplier);  
	float angle = 1-saturate(dot(-globalNormal,normalize(-input.wpos)));
	angle = max(angle,0.6); 
	//return float4(planetPos*10,1);
	//return float4(input.wpos*surfaceDistance/1000,1);//+pDiffuse;
	//if(hasAtmoshphere)
	//{ 
	//	clip(horizdist-surfaceDistance );
	//}
	float camDot = dot(-cameraDirection,globalNormal);
	float planetRim = pow(saturate(1-camDot),1);  
	float globalAFI =  saturate(pow(planetRim,1));  
	float fogDistanceMultiplier = pow(  saturate(surfaceDistance/horizdist),1.0/3); 
	
	float atmosphereFogIntencity =saturate(1*angle*fogDistanceMultiplier*globalAFI);
	 
	float3 atmoLight =3* saturate (GetAtmosphericLight(dot(lightDir,globalNormal), lightColor)*0.33);
	
	float3 finalFog = atmoLight*atmosphereFogIntencity;
	//return atmoLight;
	//return float4(finalFog,1);
	
	 
	//float cdepth =max( input.pos.z/input.pos.w,pDepth); 
	//float cdepth =input.pos.z/input.pos.w; 
	//float mind = min(cdepth,pDepth);
	//float maxd = max(cdepth,pDepth);
	//float difd = cdepth-pDepth;
	//float rez =((1/pDepth)-(1/cdepth))/5;//difd/100;// (1-(cdepth-pDepth)+1000)/2000;
	//float spt = step(pDepth,cdepth);
	//return  float4(rez,rez,rez,spt*rez);
	//
	//float4 fog = FogSample(input.tcrd,cdepth);
	//return float4(globalNormal,1);
	//pDepth = pow(pDepth,1.0/5) *0.1;
	//return float4(finalFog,1);
	//return pDiffuse;
	
	
    float3 mapped = 1 - exp(-finalFog * exposure);
    finalFog = pow(mapped, 1.0 / gamma)*2;
	
	float4 finalColor =float4(finalFog,atmosphereFogIntencity);
	//float4(lerp(pDiffuse,finalFog, atmosphereFogIntencity),1);


	
	return finalColor;
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