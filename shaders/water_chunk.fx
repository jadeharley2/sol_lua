

float4x4 Projection;
float4x4 View;
float4x4 World;
float4x4 EnvInverse; 

#include "headers/enviroment.fxh"

float distanceMultiplier=1;

float time=0;

float3 tint = float3(0.5,0.6,0.7)*0.2;

#define TwoPi 6.28318530718

Texture2D wTexture;  
Texture2D tNoise;  
SamplerState MeshTextureSampler
{
    Filter = ANISOTROPIC;
    AddressU = Clamp;
    AddressV = Clamp;
};
SamplerState NoiseTextureSampler
{
    Filter = ANISOTROPIC;
    AddressU = Wrap;
    AddressV = Wrap;
};
 

//Gerstner
float3 WaveFunction(float Amplitude, float Steepness, float NumWaves, float WaveLength,
	float Speed, float Time, float3 Direction, float3 WorldPosition)
{
	float w = TwoPi/WaveLength;
	float wDot = w * dot(normalize(Direction),float3(WorldPosition.x,0,WorldPosition.z)); 
	float wSTDot = w * Speed * Time + wDot;
	float Qi = Steepness/(w*Amplitude*(NumWaves*TwoPi));
	float QA = Qi * Amplitude;

	float3 shift = 0 ;
	shift.xz = Direction.xz*QA*cos(wSTDot);
	shift.y = 2*Amplitude*sin(wSTDot); 
	return shift;
}
float3 WaveFunctionG(float Am, float St, float Nw, float WL,
	float Sp, float T, float3 WP,
		float3 D1,float D2, float D3, float D4)
{
	return  WaveFunction(Am,St,Nw,WL,Sp,T,D1,WP)
		+ 	WaveFunction(Am,St,Nw,WL,Sp,T,D2,WP)
		+ 	WaveFunction(Am*0.5,St,Nw,WL*0.5,Sp,T,-D3,WP)
		+ 	WaveFunction(Am*0.5,St,Nw,WL*0.5,Sp,T,-D4,WP);
}
 

struct VS_IN
{
	float4 pos : POSITION; 
	float3 normal : NORMAL; 
	float3 bnormal : BINORMAL; 
	float3 tnormal : TANGENT; 
	float3 color : COLOR0; 
	float2 tcrd : TEXCOORD; 
};
struct I_IN
{
	float4x4 transform : WORLD; 
}; 


struct PS_IN
{ 
	float4 pos : SV_POSITION;
	float3 normal : NORMAL;
	float3 bnormal : BINORMAL;
	float3 tnormal : TANGENT;
	float2 tcrd : TEXCOORD; 
	float3 wpos : TEXCOORD1;
	float3 lpos : TEXCOORD2;
	float3 color : TEXCOORD3;
};


PS_IN VS( VS_IN input, I_IN inst ) 
{
	PS_IN output = (PS_IN)0;
	output.tcrd = input.tcrd; 
	 
	float4x4 InstWorld = mul((inst.transform),(World));
	float4x4 mx =mul((View) ,	(Projection));
	float3x3 nworld = (float3x3)(InstWorld);
	float4 wpos = mul(input.pos,InstWorld);
	float4 ffpos = mul(input.pos,(inst.transform));


	float surfaceDistance = length(wpos) * distanceMultiplier;
 
	 
	float3 fwp =  ffpos*100000;
	float fScale = (1-saturate(surfaceDistance/4))*0;
	float rScale = 0.00001*fScale;

	float3 waveDir =normalize(input.bnormal*float3(1,0,1));
 
	float3 sHigh = 0
		//+WaveFunction(3.2,1,2,40000,1000,time,float3(0.5,0,0.7),fwp)
	 	//+WaveFunction(7.8,1,2,80000,500,time,float3(0.4,0,-0.7),fwp)
		 ;
	float3 sMed = 0
	 	//+WaveFunction(3.2,1,2,4000,1000,time,float3(0.2,0,0.7),fwp)
	 	//+WaveFunction(7.8,1,2,8000,500,time,float3(0.3,0,-0.7),fwp)
		 ;
	float3 sSml = 0 
	 	+WaveFunction(20,0.5,2,10000,1000,time,float3(-0.3,0,0.7),fwp)
	 	+WaveFunction(17,0.5,2,10000,1000,time,float3(-0.5,0,0.7),fwp)
	 	+WaveFunction(10,0.5,2,10000,1000,time,float3(-0.5,0,0.2),fwp)

	 	+WaveFunction(30,0.5,2,40000,1000,time,float3(-0.1,0,0.7),fwp)
	 	//+WaveFunction(0.5,0.5,2,400,200,time,float3(0.5,0,0.7),fwp)
	 	//+WaveFunction(0.7,0.5,2,800,300,time,float3(0.4,0,0.7),fwp)
		 ;
	float3 shift = sHigh + sMed + sSml; ;
 
	wpos.xyz+=rScale*shift;
    
	input.color = shift;

	output.pos =  mul(wpos,mx);//mul(Proj, mul( input.pos,World));
	
				 
	output.normal = 
		normalize(mul(input.normal,(World)))
		//+ normalize(sHigh.zyx)*0.2*fScale
		//+ normalize(sMed.zyx)*0.2*fScale
		+ normalize(sSml.zyx)*0.1*fScale
		;//input.normal+0.01*(sHigh*0.001 + sMed*0.01  + sSml)*float3(1,1,1));
	
	
	output.bnormal = input.bnormal;
	output.tnormal = input.tnormal; 
	output.color = input.color;// * saturate(shift.y*5+0.5); 
	output.lpos = normalize(mul(input.bnormal,(World)));  
	output.wpos = wpos.xyz; 
	return output;  
} 

struct PS_OUT
{
    float4 light: SV_Target0;
    float4 normal: SV_Target1;
    //float4 position: SV_Target3;
    float depth: SV_Target2;
    float4 mask: SV_Target3;
    float4 color: SV_Target4;
};


float getWHeight(float2 tcrd)
{ 
	 float tns =
	 tNoise.Sample(NoiseTextureSampler,tcrd+float2(-time,time)*0.1 ).r
	 *tNoise.Sample(NoiseTextureSampler,tcrd*2+float2(time*0.5,time*1.2)*0.1 ).r
	 *tNoise.Sample(NoiseTextureSampler,tcrd*3+float2(time*0.3,-time*0.7)*0.1 ).r 
	 *3 
	 ;  
	return tns;
}

PS_OUT PS( PS_IN input ) : SV_Target
{
	PS_OUT output = (PS_OUT)0;
	 
	output.mask = float4(1,1,0,1);

	float3 normal = (input.normal); 



	float2 shu_tc = input.tcrd/5;
	float tns = getWHeight(shu_tc);
	
	
    float3 camdir = input.wpos;
	float camdist = length(camdir);
	camdir/=camdist;
	
	float d = 0.01;
	float bxm = getWHeight(shu_tc+float2(-d,0));
	float bxp = getWHeight(shu_tc+float2(d,0));
	float bym = getWHeight(shu_tc+float2(0,-d));
	float byp = getWHeight(shu_tc+float2(0,d));
	 
	float2 _step = float2(1.0, 0.0);
   
	float3 va = normalize( float3(_step.xy, bxp-bxm));
	float3 vb = normalize( float3(_step.yx, byp-bym));
    
	 
	float surfaceDistance = length(input.wpos) * distanceMultiplier;
	float maskmul = saturate(1-surfaceDistance);
	float3 newNormal = normalize(cross(va,vb).rbg) ;  
	float3 worldNormal =normalize(input.normal+newNormal*0.5);

	//worldNormal = input.normal;
















	float3 ambmap = EnvSampleLevel(float3(0,1,0),1);

    float3 reflectcam = reflect(camdir,worldNormal); 
	float3 reflectEnv = mul(float4(reflectcam,1),EnvInverse).xyz;
    float3 envmap = saturate(EnvSampleLevel(reflectEnv,output.mask.x));

	float camdot =  dot(camdir,worldNormal);
	float tran = pow(-camdot,3);

	float3 waterA = tint;


 	output.light.rgb =waterA*ambmap+envmap; 
	
 	//output.light.rgb = surfaceDistance*10;
 	//output.light.rgb = reflectEnv*100;
	output.light.a = 0.9*saturate(1-tran);

    output.color = float4(tint,1);
	
    output.depth = input.pos.z; 
	output.normal = float4(worldNormal.x/2+0.5,worldNormal.y/2+0.5,worldNormal.z/2+0.5,1); 

	return output; 
} 


struct SPS_IN
{ 
	float4 pos : SV_POSITION; 
};

float4 VSS( VS_IN input, I_IN inst) : SV_POSITION
{ 
 
	 
	float4x4 InstWorld = mul((inst.transform),(World));
	float4x4 mx =mul((View) ,	(Projection));
	float3x3 nworld = (float3x3)(InstWorld);
	float4 wpos = mul(input.pos,InstWorld);
	float4 ffpos = mul(input.pos,(inst.transform));


	float surfaceDistance = length(wpos) * distanceMultiplier;
 
	 
	float3 fwp =  ffpos*100000;
	float fScale = 1-saturate(surfaceDistance/4);
	float rScale = 0.00001*fScale;

	float3 waveDir =normalize(input.bnormal*float3(1,0,1));
 
	float3 sHigh = 0
		+WaveFunction(3.2,1,2,40000,1000,time,float3(0.5,0,0.7),fwp)
	 	+WaveFunction(7.8,1,2,80000,500,time,float3(0.4,0,-0.7),fwp);
	float3 sMed = 0
	 	+WaveFunction(3.2,1,2,4000,1000,time,float3(0.2,0,0.7),fwp)
	 	+WaveFunction(7.8,1,2,8000,500,time,float3(0.3,0,-0.7),fwp);
	float3 sSml = 0 
	 	+WaveFunction(0.2,0.5,2,1000,100,time,float3(-0.3,0,0.7),fwp)
	 	//+WaveFunction(0.5,0.5,2,400,200,time,float3(0.5,0,0.7),fwp)
	 	//+WaveFunction(0.7,0.5,2,800,300,time,float3(0.4,0,0.7),fwp)
		 ;
	float3 shift = sHigh + sMed + sSml; ;
 
	wpos.xyz+=rScale*shift;
     
	return mul(wpos,mx);
} 
float4 PSS( float4 pos: SV_POSITION) : SV_Target0
{ 
	float dp = pos.z*pos.w; 
	return dp;//-0.001f; 
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
technique10 Shadow
{
	pass P0
	{
		SetGeometryShader( 0 );
		SetVertexShader( CompileShader( vs_4_0, VS() ) );
		SetPixelShader( CompileShader( ps_4_0, PSS() ) );
	}
}