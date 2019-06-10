 
bool enable_sslr = true;
bool enable_ssao = true;
bool enable_bloom = true;

bool debug_channels=false;

float time = 0;
float hdrMultiplier = 1;
float exposure = 0.1;
float gamma = 0.5;

float camera_near=0.1;
float camera_far=100;
float camera_fovaspect;
float2 viewSize;

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

float hdr_minimum = 1500;
float hdr_maximum = 4000;


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

float linearDepth(float depth)
{
    return 2.0 * camera_near * camera_far /
             (camera_far + camera_near -
             (depth * 2.0 - 1.0) * (camera_far - camera_near));
}
float unlinearDepth(float ldepth)
{
	return (-camera_far*camera_near + camera_far*ldepth)
		/((camera_far - camera_near)*ldepth);
}
float SS_GetDepth(float2 position)
{ 
	 return linearDepth(tDepthView.Sample(sCC, position).r);
}
//float3 getPos(float2 uv, float depth)
//{  
//    return mul( float4(camera_fovaspect * (uv * 2.0 - 1.0) * depth, -depth,1),transpose(invWVP)).xyz;
//}
float3 getPos(float2 uv, float depth)
{  
    return float3(uv,depth);
}
float2 getUV(float3 pos)
{
    return pos.xy/viewSize;//(pos.xy / pos.w) * 0.5 + 0.5;
}
float3 SS_GetPosition(float2 UV, float depth)
{
	float4 position = 1.0f; 
 
	position.x = UV.x * 2.0f - 1.0f; 
	position.y = -(UV.y * 2.0f - 1.0f); 

	position.z =unlinearDepth( depth); 
 //position.w = 1;
	//Transform Position from Homogenous Space to World Space 
	position = mul(position, transpose(invWVP));  
 
	//position *= position.w;
	position /= position.w;

	return position.xyz;
}
float3 SS_GetUV(float3 position)
{
	 float4 pVP = mul(float4(position, 1.0f),transpose( VP));
	 //pVP.w = 1;
	 pVP.xy = float2(0.5f, 0.5f) + float2(0.5f, -0.5f) * pVP.xy/ pVP.w ;/// pVP.w
	 return float3(pVP.xy, pVP.z/ pVP.w);// / pVP.w
}
float3 SS_GetColor(float2 position,float level)
{ 
	 return tDiffuseView.SampleLevel(sCC, position,level);
}
float3 SS_GetNormal(float2 position)
{ 
	 return tNormalView.Sample(sCC, position);
}

#include "headers/effect_pen.fxh"
#include "headers/effect_ssao.fxh"



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


float LDelimiter = 2400000;
float3 SSLR(PS_IN input,float reflectiveness,float roughness,float metalness )
{
	//return  SS_GetColor(input.tcrd*1,1.001).rgb;
	float3 texelDiffuse = SS_GetColor(input.tcrd,0);
	float3 localNormal = tNormalView.Sample(sCC, input.tcrd).xyz;
	float3 ssNormal = normalize((localNormal -float3(0.5,0.5,0.5))*2);
	float3 texelNormal =ssNormal;
	float texelDepth = SS_GetDepth(input.tcrd);

	float3 texelPosition = SS_GetPosition(input.tcrd,texelDepth);
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
		endDepth = SS_GetDepth(nuv.xy); // чтение глубины из DepthMap по UV
		
		newPosition = SS_GetPosition(nuv.xy, endDepth);
		L = length(texelPosition - newPosition);
	} 
	//return L*100000; 
	//return (texelDepth-endDepth)*-10000;
	//return (newPosition-texelPosition)*1000;//-float3(input.tcrd,0);
	//return L*200;
	//float cdot2 = saturate(pow(1-dot(viewDir,texelNormal),2));
	//float3 cnuv2 =10 *texelDiffuse* SS_GetColor(nuv.xy,10).rgb*cdot2;
	//return (nuv*float3(1,1,0)-float3(input.tcrd,0))*0.5+0.5;

	if(texelDepth>endDepth) return texelDiffuse;//+cnuv2*reflectiveness;
	//L = saturate(L * LDelimiter);
	float error = saturate(1 - L);
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
	cnuv = lerp(cnuv,cnuv*normalize(texelDiffuse),metalness);
	//return nuv.x/3;
	//return  texelPosition;
	//if (!isfinite(cnuv.x)) return float3(1,0,0);
	//return cnuv*10;
 //return L*10000;
	return lerp(texelDiffuse,cnuv,cdot*reflectiveness*error*darken);  
}

float rflen=0.02;
float rflen2=0.0175;
float3 Bloom(float2 tcrd)
{
	return (
		tDiffuseView.Sample(sView, tcrd)
		
		+tDiffuseView.Sample(sView, tcrd+float2(rflen,0))
		+tDiffuseView.Sample(sView, tcrd+float2(-rflen,0))
		+tDiffuseView.Sample(sView, tcrd+float2(0,rflen))
		+tDiffuseView.Sample(sView, tcrd+float2(0,-rflen))
		
		+tDiffuseView.Sample(sView, tcrd+float2(rflen2,rflen2))
		+tDiffuseView.Sample(sView, tcrd+float2(rflen2,-rflen2))
		+tDiffuseView.Sample(sView, tcrd+float2(-rflen2,rflen2))
		+tDiffuseView.Sample(sView, tcrd+float2(-rflen2,-rflen2))
		).rgb/9
		;
} 
const float3 blof[] = {
	float3(1,1,0.5),float3(0,2,0.25),float3(0,3,0.125),float3(0,4,0.0125),
	float3(2,1,0.25),float3(1,2,0.125),float3(1,3,0.0125),//float3(1,4,0.00125),
	float3(3,1,0.125),float3(2,2,0.025),//float3(2,3,0.00125),float3(2,4,0.00125),
	float3(4,1,0.125),//float3(3,2,0.025),float3(3,3,0.00125),float3(3,4,0.00125),
};
float3 Bloom2(float2 tcrd,float2 mul)
{
	float4 un = 0;
	[unroll]
	for(int i = 0; i < 10; i++)
	{
		un+=tDiffuseView.Sample(sView, tcrd+blof[i]*mul);
	}
	return un/10;
} 
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

float3 Blur(float2 dir,float2 tcrd)
{
	//float3 ppColour = tDiffuseView.Sample(sCC, tcrd) * weight[0];
	float3 FragmentColor = float3(0.0f, 0.0f, 0.0f);

	//(1.0, 0.0) -> horizontal blur
	//(0.0, 1.0) -> vertical blur
	float hstep = dir.x;
	float vstep = dir.y;

	[unroll]
	for (int i = 1; i < 9; i++) 
	{
		FragmentColor +=
			tDiffuseView.Sample(sCC, tcrd + float2(hstep*offset[i], vstep*offset[i]))*weight[i] +
			tDiffuseView.Sample(sCC, tcrd - float2(hstep*offset[i], vstep*offset[i]))*weight[i];      
	}
	//ppColour += FragmentColor;
	return FragmentColor;
}
float3 Blur2d(float2 dir,float2 tcrd)
{
	float3 FragmentColor = float3(0.0f, 0.0f, 0.0f);
	float hstep = dir.x;
	[unroll]
	for (int i = 1; i < 9; i++) 
	{
		FragmentColor +=
			Blur(float2(0,dir.y),tcrd+ float2(hstep*offset[i],0))*weight[i] +
			Blur(float2(0,dir.y),tcrd- float2(hstep*offset[i],0))*weight[i];
	} 
	return FragmentColor/2;
}
float3 FogSample(float2 tcrd,float pDepth)
{
	return float3(0.1,0.9,0.3)*saturate(pDepth-300);
}

float rand(float2 co){
    return frac(sin(dot(co.xy ,float2(12.9898,78.233))+time/100) * 43758.5453);
}
float3 CBlend(float3 c1,float3 c2,float start,float end,float value)
{
	return lerp(c1,c2,saturate((value-start)/(end-start)));
}
float3 Temperature(float nit)
{
	float lognit = log10(nit)/4;
	//7
	if(lognit>1) return float3(1,1,1);
	else if(lognit>0.85) return CBlend(float3(1,0,1),float3(1,1,1),0.9,0.98,lognit);
	else if(lognit>0.75) return CBlend(float3(1,0,0),float3(1,0,1),0.76,0.8,lognit);
	else if(lognit>0.6) return CBlend(float3(1,1,0),float3(1,0,0),0.62,0.72,lognit);
	else if(lognit>0.4) return CBlend(float3(0,1,0),float3(1,1,0),0.42,0.45,lognit);
	else if(lognit>0.25) return CBlend(float3(0,1,1),float3(0,1,0),0.25,0.32,lognit);
	else if(lognit>0.1) return CBlend(float3(0,0,1),float3(0,1,1),0.15,0.20,lognit);
	else return CBlend(float3(0,0,0),float3(0,0,1),0,0.08,lognit);
}
float4 CHANNELS(PS_IN input ) : SV_Target
{  
	if(input.tcrd.y<0.5 )
	{
		if (input.tcrd.x<0.5)
		{
			return tDiffuseView.Sample(sView, input.tcrd);
		}
		else
		{
			return tNormalView.Sample(sView, input.tcrd);
		}
	}
	else
	{
		if (input.tcrd.x<0.5)
		{
			float d = linearDepth(tDepthView.Sample(sView, input.tcrd));
			//d = ((d)*100)%1;
			//d =(d*10)%1;
			return d;
		}
		else
		{
			return tMaskView.Sample(sView, input.tcrd);
		}
	}
	return 0;
}
float4 PS( PS_IN input ) : SV_Target
{  
	//return 1; 
	if (debug_channels){return CHANNELS(input);}
	//return 1;
	float4 pDiffuse = tDiffuseView.Sample(sView, input.tcrd);
	float4 pNormal = tNormalView.Sample(sView, input.tcrd);//float4((tNormalView.Sample(sView, input.tcrd).xyz-float3(0.5,0.5,0.5))*2,1);
	float pDepth = tDepthView.Sample(sView, input.tcrd);
	float4 pMask = tMaskView.Sample(sView, input.tcrd);
	
	//return pDiffuse;
	//return float4(pDiffuse.rgb*(1-pMask.x),1);
	
	float d2 = SS_GetDepth(input.tcrd);
	float3 wpos = SS_GetPosition(input.tcrd,d2/2);
	//return float4(SS_GetUV(wpos)-float3(input.tcrd,0),1); 
	//return float4(wpos*10000,1);
	float3 shcolor = pDiffuse;
	//return pNormal.a;
	//return float4(wpos*200000,1); 
	if(enable_sslr&&pMask.y>0.01)
	{ 
		shcolor = SSLR(input,pMask.y,1-pMask.y,pMask.z);
		
	//	return float4(shcolor,1);
	} 
	if(enable_ssao)
	{  
		//shcolor = SSAO(shcolor,input.tcrd);
	}  
	float3 result = lerp(pDiffuse,shcolor,pMask.x);
	 
	
	// if(enable_bloom)
	// {  
	// 	float4 pDiffuseD = 
	// 		tDiffuseView.SampleLevel(sCC, input.tcrd,5)
	// 		+tDiffuseView.SampleLevel(sCC, input.tcrd,6)
	// 		+tDiffuseView.SampleLevel(sCC, input.tcrd,7)
	// 		+tDiffuseView.SampleLevel(sCC, input.tcrd,8)
	// 	;
	// 	pDiffuseD = max(float4(0,0,0,1),pDiffuseD);
	// 	
	// 	float3 bloom = Blur2d(float2(0.001,0.0015), input.tcrd);
	// 	
	// 	result = result*0.8 + bloom*bloom/2//pDiffuseD*0.2;//
	// 	//Blur(float2(0.01,0), input.tcrd)+ Blur(float2(0,0.001), input.tcrd)
	// 	//Bloom2(input.tcrd,float2(0.01,0.01))
	// 	//Blur2d(float2(0.002,0.003), input.tcrd) 
	// 	
	// 	;
	// 	
	// }
	if(false)
	{
		float pb = (result.x+result.y+result.z)/3;
		float pixbrightness =pb/hdrMultiplier; //(hdrMultiplier/15)*(1-(pDiffuse.r+pDiffuse.g+pDiffuse.b)/3);
		float darkness = saturate(1-pixbrightness*50);
		float3 desat = result-(result-pb);
		//return float4(desat,1);
		result = lerp(result,desat*(0.5+rand(input.tcrd)*0.5),saturate(1-pixbrightness*50));
	}
	 
	//return pMask.y;
	//result = (result-0.1)*10;
	//return float4(Temperature(pb*10000),1);
	//result = saturate(result*1000)/4+saturate(result*100)/4+saturate(result*10)/4+saturate(result*1)/4;
	
	//float3 step1=saturate((result*1000));
	//step1 *=cos(length(step1));	
	//result = saturate(step1)+saturate(result);//(sqrt(result))*10;
	
	if(enable_bloom)
	{  
		float3 ovb= 0;
		float pw = 1;
		//[unroll]
		for(int i=0;i<50;i++)
		{
			pw = pw*0.86;
			float3 a = saturate(tDiffuseView.Sample(sCC, input.tcrd+float2(0.001*i,0))*pw);
			float3 b = saturate(tDiffuseView.Sample(sCC, input.tcrd+float2(-0.001*i,0))*pw);
			ovb=ovb+a*a+b*b; 
			
		} 
		
		result =(max(0,result)+ovb*0.1)*0.9;
	}



	//float gamma = 0.5;
	//float exposure = 0.01; 
    float3 mapped = 1 - exp(-result * exposure); //exposure
    result = pow(mapped, 1.0 / gamma)*2;
	//result += (result-length(result))*0.3;
	float darken = saturate(1-distance(float2(0.5,0.5),input.tcrd));
	//result = result + FogSample(input.tcrd,pDepth);
	//result = result * darken;
	
	
	
  //result = normalize(result);
	//	float4 cnuv =tDiffuseView.SampleLevel(sView, input.tcrd,1);// SS_GetColor(nuv,0).rgb;
	//	//return nuv.x/3;
	//	//return nuv.x;
	//	if (!isfinite(cnuv.x)) return float4(1,0,0,1);
	//result = lerp(step1,result,saturate(length(result)*10));
	//return float4(wpos*100000*float3(1,1,1),1)/200+ float4(result,1);
	
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