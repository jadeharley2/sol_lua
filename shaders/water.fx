#include "headers/lightning.fxh"
#include "headers/atmosphere.fxh"
#include "headers/enviroment.fxh"


float4x4 Projection;
float4x4 View;
float4x4 World;

float4x4 EnvInverse;
 
float3 lightDir; 
float3 lightColor=float3(1,1,1); 

float albedoSurface = 1;
float albedoLiquid = 1;
float hdrMultiplier =1;
float distanceMultiplier=1;

float time=0;
  
 
float3 Tint = float3(1,1,1);
  
float2 screenSize = float2(1024,1024);
 
Texture2D wTexture;  
Texture2D tNoise;  
Texture2D tReflection;  
   
//TextureCube g_EnvTexture;  
  
bool hasAtmoshphere = false;
bool isCameraUnderWater;

float3 Delight(float3 SUNLIGHT,float to)
{
	 
    float from = 1 - to;
	float middle = abs(to);
    float to2 = clamp((to) * 2  , 0, 1);
    float3 result = 
		SUNLIGHT * base 
		- SUNLIGHT * base * to2            
		+ clamp(SUNLIGHT - base * to * 3, float3(0,0,0), float3(1,1,1)) * to2 * from * 2 ;
	
	return result;
}

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
 
  
struct VS_IN
{
	float4 pos : POSITION;
	float3 normal : NORMAL;
	float3 bnormal : BINORMAL;
	float3 tnormal : TANGENT;
	float4 tcrd : TEXCOORD;  //xy = bigTcrd(-1..+1,fullplane), zw = smallTcrd(0..+1,~1m)
	float4 data : TEXCOORD1; //x = height, y = temperature, z = humidity, w = none
	float3 color : COLOR;
};
struct IS_IN
{
	float3 pos : POSITION1;
};
struct PS_IN
{ 
	float4 pos : SV_POSITION;
	float3 normal : NORMAL;
	float3 bnormal : BINORMAL;
	float3 tnormal : TANGENT;
	float4 tcrd : TEXCOORD;
	float4 data : TEXCOORD1;
	float3 wpos : TEXCOORD2;
	float3 lpos : TEXCOORD3;
	float3 color : TEXCOORD4;
};


struct PS_OUT
{
    float4 color: SV_Target0;
    float4 normal: SV_Target1;
    //float4 position: SV_Target3;
    float depth: SV_Target2;
    float4 mask: SV_Target3;
};

float getLWHeight(float2 tcrd)
{ 
	float tns =//0;
	 tNoise.SampleLevel(NoiseTextureSampler,tcrd+float2(-time,time)*0.1,0 ).r
	 *tNoise.SampleLevel(NoiseTextureSampler,tcrd*2+float2(time*0.5,time*1.2)*0.1,0 ).r
	 *tNoise.SampleLevel(NoiseTextureSampler,tcrd*3+float2(time*0.3,-time*0.7)*0.1,0 ).r
	 *3 
	;
	return tns;
}

float getWHeight(float2 tcrd)
{ 
	 float tns =
	 tNoise.Sample(NoiseTextureSampler,tcrd+float2(-time,time)*0.1 ).r
	 *tNoise.Sample(NoiseTextureSampler,tcrd*2+float2(time*0.5,time*1.2)*0.1 ).r
	 *tNoise.Sample(NoiseTextureSampler,tcrd*3+float2(time*0.3,-time*0.7)*0.1 ).r 
	 *3 
	 ;
	//// float tns =0
	//// //tNoise.Sample(NoiseTextureSampler,tcrd+float2(-time,time)*0.1 ).r
	//// //*tNoise.Sample(NoiseTextureSampler,tcrd*2+float2(time*0.5,time*1.2)*0.1 ).r
	//// //*tNoise.Sample(NoiseTextureSampler,tcrd*3+float2(time*0.3,-time*0.7)*0.1 ).r
	//// //+tNoise.Sample(NoiseTextureSampler,tcrd*5+float2(time*0.2,-time*0.3)*0.1 ).r
	//// +tNoise.Sample(NoiseTextureSampler,tcrd*0.07+float2(time*0.13,-time*0.133)*0.1 ).r
	//// +tNoise.Sample(NoiseTextureSampler,tcrd*0.3+float2(time*0.13,-time*0.133)*0.1 ).r
	//// +tNoise.Sample(NoiseTextureSampler,tcrd*1+float2(time*0.13,-time*0.133)*0.1 ).r
	//// +tNoise.Sample(NoiseTextureSampler,tcrd*3+float2(time*0.3,-time*0.7)*0.1 ).r*0.1
	//// //+tNoise.Sample(NoiseTextureSampler,tcrd*3+float2(time*0.13,-time*0.133)*0.05 ).r
	//// //*3 
	//// ;
	return tns;
}
PS_IN VS( VS_IN input)//, IS_IN input2 ) 
{
	PS_IN output = (PS_IN)0;
	output.tcrd = float4(1- input.tcrd.y, input.tcrd.x, input.tcrd.w, input.tcrd.z); 
	 
	float4 pos = input.pos; 
	float4 wpos = mul( pos,transpose(World));
	output.normal = normalize(mul(input.normal,transpose(World))); 
	float wh = getLWHeight(input.tcrd.zw)*0; 
	wpos.xyz+=output.normal*wh*0.0002/distanceMultiplier;
	
	output.pos =  mul(mul(wpos,transpose(View)),transpose(Projection));//mul(Proj, mul( input.pos,World));
	
				
	output.normal = input.normal;
	
	
	output.bnormal = input.bnormal;
	output.tnormal = input.tnormal;
	output.data = input.data;
	output.color = input.color; 
	output.lpos = normalize(mul(input.bnormal,transpose(World)));  
	output.wpos = wpos.xyz; 
	return output;  
} 

//float3 skycolor = float3(0.7,0.9,1);
//float3 skycolor = float3(0.9,0.5,0.1);

PS_OUT PS( PS_IN input ) : SV_Target
{
	PS_OUT output = (PS_OUT)0;
	
	float2 tc = input.tcrd.zw;
	
	float tns = getWHeight(tc);
	
	
	
	float d = 0.01;
	float bxm = getWHeight(tc+float2(-d,0));
	float bxp = getWHeight(tc+float2(d,0));
	float bym = getWHeight(tc+float2(0,-d));
	float byp = getWHeight(tc+float2(0,d));
	 
	float2 _step = float2(1.0, 0.0);
   
	float3 va = normalize( float3(_step.xy, bxp-bxm));
	float3 vb = normalize( float3(_step.yx, byp-bym));
    
	 
	float surfaceDistance = length(input.wpos) * distanceMultiplier;
	float maskmul = saturate(1-surfaceDistance);
	float3 newNormal = normalize(cross(va,vb).rbg*float3(1,1000*saturate(surfaceDistance),1)
	*float3(1,1,1));  
	float3 worldNormal =normalize( mul( newNormal,transpose(World)).xyz);//input.normal;
	
	//lerp(saturate(surfaceDistance*10),normalize( mul( newNormal,transpose(World)).xyz),input.normal);//newNormal.x * input.bnormal +newNormal.y * input.normal + newNormal.z * input.tnormal;
	
	float globalLightIntencity = saturate(dot(lightDir,input.normal));
	float3 lightcolor = Delight(lightColor, saturate(0.3-(globalLightIntencity)-0.2f));
	float atmosphereFogIntencity =  saturate(surfaceDistance);
	
	float3 cameraDirection = normalize(input.wpos);
	float topDot = saturate(dot(worldNormal,input.normal));
	float camDot =saturate(-dot(worldNormal,cameraDirection)/4);
	tns = 0.5 + tns;
 
	float3 brightness3 =ApplyPointLights(input.wpos,worldNormal,cameraDirection,0.8);
	//globalLightIntencity*base/2+ 
	
	float2 screenTexCoord = input.pos.xy/screenSize;
	
	//input.wpos
	
	//float4 reflectionTex = tReflection.Sample(NoiseTextureSampler,float2(screenTexCoord.x,1-screenTexCoord.y) );
	//+reflectionTex
	float rim =  saturate(1-camDot*20);
	float3 rampcolor = float3(0.8,1,0.8)*wTexture.Sample(MeshTextureSampler, float2(1+input.data.x*3,input.data.z) ).rgb;
	
	//float3 skycolor = base*lightcolor+float3(117,144,48)/128;
	
	//float3 color = (skycolor+rampcolor*0.8f*2)*tns*brightness3/2 +rim*base*lightcolor;
	float3 color =float3(0.1,0.2,0.3)/10;// (rampcolor*0.8f*2);//*tns*brightness3/2/10;
	
	float1 alpha = saturate(1-camDot*camDot);
	
	
	
	output.color = float4(color,0.9-camDot);
	 
	atmosphereFogIntencity*=0.3;
	atmosphereFogIntencity= saturate(atmosphereFogIntencity);
	
	//output.color =  
	//(output.color + float4(base,1)*atmosphereFogIntencity)*hdrMultiplier;
	
	
	output.color.a =
	(saturate(saturate(-input.data.x*2)+1-saturate(1-camDot))+surfaceDistance/4)
	-saturate(surfaceDistance*2)
	;
	//clip(5-surfaceDistance);
	////clip(0.5-surfaceDistance);
	//output.color = output.color+float4(( lightcolor-output.color.rgb)*atmosphereFogIntencity,0);  
	 
	output.color.rgb = normalize(worldNormal*0.5+0.5);
	
	float3 ambmap = EnvSampleLevel(worldNormal,0.9);//g_EnvTexture.SampleLevel(MeshTextureSampler, worldNormal,10);
	float3 reflectcam = reflect(cameraDirection,worldNormal);
	float3 reflectEnv =  mul(float4(reflectcam,1),EnvInverse).xyz;
	float3 envmap = EnvSample(reflectEnv*float3(1,1,1));//
	//g_EnvTexture.SampleLevel(MeshTextureSampler, reflectcam*float3(-1,1,1),0);
	//float3 depthcolor = float3(0);
	float rim2 =  saturate(1-camDot*2);
	
	float waterA = 1;//(saturate(0.2-camDot));
	 
	output.color.rgb = waterA*envmap;//envmap;// brightness3*color +lerp(envmap*rim*0.7+ambmap*0.3,float3(0,0,0),maskmul);
	//output.color.a = alpha;//rim2;
	
	output.color.a =
	(saturate(saturate(-input.data.x*2)+1-saturate(1-camDot))  )//+surfaceDistance/4
	-saturate(surfaceDistance/5)
	; 
	 
	//output.color.a *=waterA*0;
	//output.color.a = length(output.color.rgb);
	//output.color.rgb =worldNormal*0.5+0.5;
	
	output.mask = float4(1,maskmul,0,1);
	if(isCameraUnderWater)
	{ 
		output.mask = float4(1-saturate(surfaceDistance*20),maskmul,0,1); 
		//output.color.rgb = lerp(output.color.rgb,brightness3*(rampcolor*2),saturate(surfaceDistance*20));
		//output.color.a = 1;
	}  
	output.normal = float4(worldNormal*0.5+0.5,1);
	output.depth =// input.pos.w;//
	input.pos.z;///input.pos.w;
	 
	return output; 
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