#include "headers/lightning.fxh"
#include "headers/atmosphere.fxh"
#include "headers/enviroment.fxh"


float4x4 Projection;
float4x4 View;
float4x4 World;


float4x4 EnvInverse;
 
float albedoSurface = 1;
float albedoLiquid = 1;
float hdrMultiplier =1;
float distanceMultiplier=1;

float3 lightDir; 
float3 lightColor=float3(1,1,1); 

bool isCameraUnderWater;
bool isStar;
float3 Tint = float3(1,1,1);

Texture2D sTexture;   
Texture2D wTexture;   
Texture2D nTexture;  
 
Texture2D tileTexture;  
Texture2DArray tileNearTexture_d;  
Texture2DArray tileNearTexture_n;  
Texture2DArray tileSpaceTexture_d;  
Texture2DArray tileSpaceTexture_n;  
 
Texture2D tNoise;  
Texture2D tNoise2;  

Texture2D cTexture;  
Texture2D tGradient;  

//TextureCube g_EnvTexture;  
 
float globalHumidityModifier =0;
float globalTemperatureModifier =0;
float horisonDistance=1;
   

float heightMapSizeY = 512;
float heightMapSizeX = 512;
float bumpHeightScale = 10;

bool nearMode;
bool hasAtmoshphere = false;
bool hasHydrosphere = false;

bool displayMode = false;
bool customBlend = false;

float3 planetpos;
float planetradius=1;
float time =0;

float3 oceanColor = 
float3(0.1,0.6,0.9*2)*0.2;//*0.5
//float3(0.1,0.2,0.6)/10;

SamplerState MeshTextureSampler
{
    Filter = ANISOTROPIC;
    AddressU = Clamp;
    AddressV = Clamp;
};

SamplerState NoiseTextureSampler
{ 
    Filter = ANISOTROPIC;//MIN_MAG_MIP_POINT;
    AddressU = Wrap;
    AddressV = Wrap;
};
SamplerState NearTextureSapler
{ 
    Filter = ANISOTROPIC;//MIN_MAG_MIP_POINT;
    AddressU = Wrap;
    AddressV = Wrap;
}; 


float4 SampleTile(float x,float y, float2 tileTC,Texture2D tex,float dist)
{
	return tex.Sample(NoiseTextureSampler,tileTC+float2(x/8,y/8));
}  
//float4 SampleTile2(float2 texcoord,Texture2DArray tex)
//{
//	return tex.Sample(NoiseTextureSampler,float3(texcoord,id));
//}  
float4 SampleTileS(float2 tileTC,Texture2DArray tex,float z)
{
	return  tex.Sample(NearTextureSapler,float3(tileTC.xy,z)) ;
}  
float4 SampleTileSM(float2 tileTC,Texture2DArray tex,float z)
{
	return 
	
		tex.Sample(NearTextureSapler,float3(tileTC.xy,z))
		*tex.Sample(NearTextureSapler,float3(tileTC.xy/10,z))
		*1.75;
}  



float4 BlendT(float4 A,float4 B, float mix)
{
	return A*mix+B*(1-mix);
}
float4 BlendB(float4 A,float4 B, float min,float max,float val)
{
	float mix = saturate((val-min) / (max-min));
	return A*mix+B*(1-mix);
}

float4 BlendTileset(float4 data, float2 texCoord, float topDot,float dist)
{ //data : x = height, y = humidity, z = temperature, w = none
	
	float2 mTC = texCoord*8*2 ;
	//mTC = mTC*(1)+float2(0.05,0.05);
	//float2 tileTC = (mTC%1)/8*0.93+float2(1.2/512,1.2/512);
	//
	
	
	  
	float4 grass = SampleTileS(mTC,tileNearTexture_d,0)*float4(1,0.8,0.5,1);//
		//SampleTile(0,0,tileTC,tileTexture,dist)*float4(1,0.8,0.5,1);
	float4 rockygrass = SampleTileS(mTC,tileNearTexture_d,16)*float4(1,0.8,0.7,1);//
		//SampleTile(0,2,tileTC,tileTexture,dist)*float4(1,0.8,0.7,1);
	float4 rock =SampleTileS(mTC,tileNearTexture_d,3)*float4(1,0.8,0.8,1);// 
		//SampleTile(3,0,tileTC,tileTexture,dist)*float4(1,0.8,0.8,1);
	float4 rock2 = SampleTileS(mTC,tileNearTexture_d,8+3);// 
		//SampleTile(3,1,tileTC,tileTexture,dist);
	float4 snow = SampleTileS(mTC,tileNearTexture_d,4);// 
		//SampleTile(4,0,tileTC,tileTexture,dist);
	float4 snow2 = SampleTileS(mTC,tileNearTexture_d,8+4);//
		//SampleTile(4,1,tileTC,tileTexture,dist);
	float4 dirt =  SampleTileS(mTC,tileNearTexture_d,1);//
		//SampleTile(1,0,tileTC,tileTexture,dist);
	float4 sand =  SampleTileS(mTC,tileNearTexture_d,2);//
		//SampleTile(2,0,tileTC,tileTexture,dist);
	
	float temp = data.z;
	float height = data.x*1000000;
	
	float4 bl_hot_ravn = BlendB(dirt,sand,1,10,height/topDot);
	bl_hot_ravn = BlendB(sand ,bl_hot_ravn,0.87,0.99,topDot); 
	float4 bl_hot = BlendB(bl_hot_ravn,rock2 ,0.85,0.87,topDot); 
	float4 bl_cold = BlendB(snow, BlendB(snow2,rock ,0.82,0.85,topDot) ,0.85,0.89,topDot); 
	float4 bl_temp =BlendB(
		BlendB(grass,sand,0.1,1,height),
		BlendB(
			BlendB(rockygrass,sand,0.1,1,height),
			rock ,0.85,0.87,topDot)
		,0.87,0.98,topDot); 
	 
	
	float4 result = BlendB( BlendB(bl_hot,bl_temp,0.099,0.1,temp),bl_cold,-0.01,0,temp);
	
	return result;
}

float4 BlendTilesetSpace(float4 data, float2 texCoord)
{ //data : x = height, y = humidity, z = temperature, w = none
	 
	
	float temp = data.z;
	float height = data.x*1000000;
	
	
	
	float4 sand = SampleTileSM(texCoord,tileSpaceTexture_d,0);
	float4 sand_rock = SampleTileSM(texCoord*10,tileSpaceTexture_d,1);
	float4 steppe = SampleTileSM(texCoord,tileSpaceTexture_d,6);
	float4 grass = SampleTileSM(texCoord,tileSpaceTexture_d,3);  
	float4 forest = SampleTileSM(texCoord,tileSpaceTexture_d,4);  
	float4 tundra = SampleTileSM(texCoord*2,tileSpaceTexture_d,7);   
	float4 tundra_snow = SampleTileSM(texCoord*2,tileSpaceTexture_d,8);  
	float4 rock = SampleTileSM(texCoord*2,tileSpaceTexture_d,10); 
	 
	//desert = height: sandrock<1000|200>sand
	float4 desert_all =BlendB(sand_rock,sand, 100,1000,height);
	// tundra = temp: snow<-0.5|-0.4>tundra
	float4 tundra_all = BlendB(tundra,tundra_snow,-0.5,-0.4,temp);
	// temperate = height: rock<1000|200>forest<200|100>grass<20|0>sand
	float4 temperate_all = BlendB(BlendB(rock,BlendB(forest,grass,100,200,height),200,1000,height),sand,0,20,height);
	// result = temp: tundra<-0.2|-0.1>temperate<0.08|0.12>desert 
	float4 result =BlendB( desert_all, BlendB(temperate_all,tundra_all,-0.1,0,temp) ,0.08,0.12,temp); 
	return result;
}
 //data : x = height, y = humidity, z = temperature, w = none
struct blendProcess
{ 
	int a;
	int b;
	int to;
	int data;
	float min;
	float max;
	float unused0;
	float unused1;
};
int sourceIndex[12];
blendProcess blendIndex[12];
float4 BlendTilesetTest(float4 data, float2 texCoord)
{ 
	float temp = data.z;
	float height = data.x*1000000;
	
	float4 data1[12];
	[unroll] 
	for(int i=0;i<12;i++)
	{
		data1[i] = SampleTileS(texCoord, tileSpaceTexture_d, i);//sourceIndex[i]);
	}
	[unroll]
	for(int i=0;i<12;i++)
	{
		blendProcess bid = blendIndex[i];
		if(bid.to>=0)
		{
			data1[bid.to] = BlendB(data1[bid.a], data1[bid.b], bid.min, bid.max, data[bid.data]);
		}   
	}
	return data1[0];
}
 


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
float3 Exposition(float3 color,float exposition)// e = +1 -> white
{
	float3 dir = float3(1,1,1)-color;
	return color+dir*exposition;
}
float SampleNoise(float2 tcrd)// e = +1 -> white
{
	return
		tNoise.Sample(NoiseTextureSampler, tcrd *10 )/2
		-tNoise.Sample(NoiseTextureSampler,tcrd *40 )/3
		+tNoise.Sample(NoiseTextureSampler,tcrd *80 )/4
	;
}

struct VS_IN
{
	float4 pos : POSITION;
	float3 normal : NORMAL;
	float3 bnormal : BINORMAL;
	float3 tnormal : TANGENT;
	float4 tcrd : TEXCOORD;  //xy = bigTcrd(-1..+1,fullplane), zw = smallTcrd(0..+1,~1m)
	float4 data : TEXCOORD1; //x = height, y = temperature, z = humidity, w = cover layer thickness
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

struct DCI_PS_IN
{ 
	float4 pos : SV_POSITION;   
};

struct PS_OUT
{
    float4 color: SV_Target0;//light
    float4 normal: SV_Target1;
    //float4 position: SV_Target3;
    float depth: SV_Target2;
    float4 mask: SV_Target3;
    float4 diffuse: SV_Target4;
};

PS_IN VS( VS_IN input)//, IS_IN input2 ) 
{
	PS_IN output = (PS_IN)0;
	output.tcrd = float4(1- input.tcrd.y, input.tcrd.x, 1-input.tcrd.w, input.tcrd.z);//input.tcrd;
	
	
	float4 pos = input.pos;
	
	
	float4 wpos = mul( pos,transpose(World));
	output.normal = normalize(mul(input.normal,transpose(World)));
	
	
	
	float3 tcol = float3(62,85,53)/255;
	 
	
	output.pos =  mul(mul(wpos,transpose(View)),transpose(Projection));//mul(Proj, mul( input.pos,World));
	
	output.bnormal = input.bnormal;
	output.tnormal = input.tnormal;
	output.data = input.data;
	output.color = input.color;
	if(nearMode)
	{
		output.lpos = normalize(mul(input.bnormal,transpose(World))); 
	}
	else
	{
		output.lpos = normalize(mul(pos.xyz,transpose(World))); 
	}
	output.wpos = wpos.xyz;
	 
	
	output.color  = input.color; 
	
	return output;
}


PS_IN VSPGS( VS_IN input)//, IS_IN input2 ) 
{
	PS_IN output = (PS_IN)0;
	output.tcrd = float4(1- input.tcrd.y, input.tcrd.x, 1-input.tcrd.w, input.tcrd.z);//input.tcrd; 
	float4 pos = input.pos; 
	float4 wpos = mul( pos,transpose(World));
	output.normal = normalize(mul(input.normal,transpose(World))); 
	if(nearMode)
	{
		output.lpos = normalize(mul(input.bnormal,transpose(World))); 
		//if(input.data.x<0)
		//{
		//	float surfaceDistance = length(wpos) * distanceMultiplier;
		//	wpos +=float4(output.lpos*input.data.x*-1000,0)*saturate(surfaceDistance*10-50);
		//}
	}
	else
	{
		output.lpos = normalize(mul(pos.xyz,transpose(World))); 
	}
		if(input.data.x<0)
		{
			float surfaceDistance = length(wpos) * distanceMultiplier;
			wpos +=float4(output.lpos*input.data.x*-(1672.36621/distanceMultiplier),0)*saturate(surfaceDistance*10-50);
		}
	output.pos =  float4(wpos.xyz,1);  
	output.bnormal = input.bnormal;
	output.tnormal = input.tnormal;
	output.data = input.data;
	output.color = input.color;
	output.wpos = wpos.xyz; 
	output.color  = input.color; 
	
	return output;
}

float3 ToSpherical(float3 pos)
{
	float r = length(pos);
	float t = (acos(pos.y/r)/3.1415926);
	float y = (atan2(pos.z,pos.x)/3.1415926/2+0.5);
	return float3(y,t,r);
}

/*
SamplerComparisonState ShadowSampler
{
   // sampler state
   Filter = COMPARISON_MIN_MAG_LINEAR_MIP_POINT;
   AddressU = CLAMP;
   AddressV = CLAMP;

   // sampler comparison state
   ComparisonFunc = LESS;
};
float2 poissonDisk[4] = {
  float2( -0.94201624, -0.39906216 )/700,
  float2( 0.94558609, -0.76890725 )/700,
  float2( -0.094184101, -0.92938870 )/700,
  float2( 0.34495938, 0.29387760 )/700
};
float  SampleForShadowInnerC(float2 ShadowTexCoord,Texture2D g_ShadowMap,float bias,float depth)
{  
	float vis =0;
	[unroll]
	for (int i=0;i<4;i++)
	{
	  vis +=g_ShadowMap.SampleCmp(ShadowSampler, ShadowTexCoord+poissonDisk[i],depth-bias)*0.25;
	}
	return vis;  
}

float  SampleForShadowC(float4 worldposition,float dotNL)
{ 
	float camdist = max(1,pow(length(worldposition.xyz)*100,4)/100);
	//bias = 0.0001*tan(acos(dotNL)); 
	float bias = bias_base + bias_slopemul*tan(acos(dotNL));//*camdist; 
	// dotNL is dot( n,l ), clamped between 0 and 1
	bias = clamp(bias, 0,0.01); 

	//ShadowMap matrix VP space depth  
	float4 smpos = mul(worldposition,transpose(ShadowMapVPMatrix));
	///////////////////////////////////
	#ifdef SHADOWWARP_ENABLED
		smpos.x=smpos.x/(abs(smpos.x)+depth_shadow_bendadd);
		smpos.y=smpos.y/(abs(smpos.y)+depth_shadow_bendadd);
	#endif
	///////////////////////////////////
	//if(ShadowTexCoord.x<=0||ShadowTexCoord.y<=0||ShadowTexCoord.x>=1||ShadowTexCoord.y>=1) return 9e20;
	
	float2 ShadowTexCoord = float2(0.5,-0.5) * smpos.xy /  smpos.w + float2( 0.5, 0.5 );
	
	if(smpos.x>-1&&smpos.x<1&&smpos.y>-1&&smpos.y<1)
	{
		return	SampleForShadowInnerC(ShadowTexCoord,g_ShadowMap,bias*biasCascadeMul.x,smpos.z);
	}
	else 
	{
		smpos = mul(worldposition,transpose(ShadowMapVPMatrix_c2)); 
		if(smpos.x>-1&&smpos.x<1&&smpos.y>-1&&smpos.y<1)
		{
			ShadowTexCoord = float2(0.5,-0.5) * smpos.xy /  smpos.w + float2( 0.5, 0.5 ); 
			return SampleForShadowInnerC(ShadowTexCoord,g_ShadowMap_c2,bias*biasCascadeMul.y,smpos.z);
		}
		else
		{
			smpos = mul(worldposition,transpose(ShadowMapVPMatrix_c3)); 
			if(smpos.x>-1&&smpos.x<1&&smpos.y>-1&&smpos.y<1)
			{
				ShadowTexCoord = float2(0.5,-0.5) * smpos.xy /  smpos.w + float2( 0.5, 0.5 );  
				return SampleForShadowInnerC(ShadowTexCoord,g_ShadowMap_c3,bias*biasCascadeMul.z,smpos.z);
			}
		}
	} 
	
	return 1; 
}
*/


 float3 ApplyPointLights3(float3 surface_color, float3 position, float3 normal, float3 camdir,
	float smoothness = 0, float metallness = 0, float reflectiveness = 0,
	bool applyShadow = false,float starbrmul = 1,float shadow_intencity=1)
{
	//diffuse + specular = 1
	
	//return float3(smf,smf,smf);
	
	float shadowmap_mul = 1;
	if(shadowid>=-1)
	{
		float3 light_pos = pointlightPosition[shadowid];
		float3 light_col = pointlightColor[shadowid];
		float3 light_direction = (light_pos-position);
		float light_dist = length(light_direction); 
		light_direction/=light_dist;
		float diffuse_intencity = saturate(dot(normal,light_direction));
		shadowmap_mul = saturate(SampleForShadow(float4(position,1),diffuse_intencity))*diffuse_intencity;  
	}
	
	float3 result = float3(0,0,0);
	[unroll]
	for(int i=0;i<4;i++)
	{
		float3 light_pos = pointlightPosition[i];
		float3 light_col = pointlightColor[i];
		float3 light_direction = (light_pos-position);
		float light_dist = length(light_direction); 
		light_direction/=light_dist;
		float3 light_reflection = reflect(light_direction,normal); 
		//float cam_angle = saturate(dot(-normalize(position),normal)); 
		 
		float light_power = 1/(light_dist*light_dist);
		float diffuse_intencity = saturate(dot(normal,light_direction));
		float specular_intencity = diffuse_intencity*pow(saturate(dot(light_reflection,camdir)),smoothness*smoothness*500);
		
		//shadowmap_mul=1;
		
		float3 diffuse = saturate(1-smoothness) * light_col * diffuse_intencity * surface_color;
		float3 specular = saturate(smoothness) * light_col * specular_intencity * lerp(float3(1,1,1),surface_color,metallness);
		 
		if(i==shadowid)
		{
			//shadowmap_mul = saturate(SampleForShadow(float4(position,1),diffuse_intencity))*diffuse_intencity;  
	
			light_power = light_power*starbrmul*shadowmap_mul; 
		}
		
		float3 lresult = Lightbleed((diffuse + specular) * light_power);
	
		result += lerp(lresult,lresult,shadow_intencity);
	}
	return result;//
} 

float3 GetSpaceColor(PS_IN input)
{
	float3 globalNormal = normalize(input.lpos);
	float3 cameraDirection = normalize(input.wpos);
	float2 tcrd = input.tcrd.xy;
	float4 tex =  BlendTilesetSpace(input.data,tcrd*4);//tileSpaceTexture_d.Sample(NearTextureSapler,float3(tcrd*8,3));
	float4 norm = tileSpaceTexture_n.Sample(NearTextureSapler,float3(tcrd*4,0));
	float specular = 0.001;
	bool isunderwater = hasHydrosphere && input.data.x<0.00;
	if(isunderwater)
	{
		tex.rgb= oceanColor/(1-input.data.x*1000);
		input.normal = globalNormal;
		specular = 0.4;
	}
	//tex.rgb= input.data.x*10000*float3(1,1,1);
	float3 brightness3 = ApplyPointLights3(tex.rgb,input.wpos,input.normal,cameraDirection,specular,0,false)*0.9+tex.rgb*0.1;
	
	return brightness3;
}

float4 SpaceColor(PS_IN input,float wposLen,float surfaceDistance, inout PS_OUT output)
{ 
	float blend_clouds = saturate(surfaceDistance/100-1); 
	float blend_nearfog = saturate(surfaceDistance/10-1); 
 
	
	float2 tcrdBig = input.tcrd.xy;
	float2 tcrdSmall = input.tcrd.zw;
	 
	float3 globalNormal = normalize(input.lpos);
	float3 cameraDirection = input.wpos/wposLen; 
	float camDot = dot(-cameraDirection,globalNormal);
	
	float3 lightReflection = reflect(lightDir,input.normal); 
	float specularIntencity = saturate(dot(lightReflection,cameraDirection));//pow(,10);//+0.2f
	float globalLightIntencity = saturate(dot(lightDir,globalNormal));
	float localLightIntencity = saturate(dot(lightDir,input.normal));  
	//float3 ambientlightIntencity =  EnvSampleLevel(input.normal,0.9);
	float totallightIntencity = (globalLightIntencity*localLightIntencity);// max(min(globalLightIntencity,localLightIntencity),ambientlightIntencity);
	
	float3 globalNormal2 = normalize(input.wpos);
	
	float horizdist = max(5,horisonDistance*distanceMultiplier); 
	//return atmdencity/30;
	//return input.data.x*100; 
	float angle = 1-saturate(dot(-globalNormal,normalize(-input.wpos)));
	angle = max(angle,0.6);
	//angle = angle+saturate( atmosphere_width/(length(planetpos)- planetradius));
	////////if(hasAtmoshphere)
	////////{ 
	////////	clip(horizdist-surfaceDistance );
	////////}
	float planetRim = pow(saturate(1-camDot),1); 
	
	
	float3 atmoLight = GetAtmosphericLight(dot(lightDir,globalNormal), lightColor);
	
	
	float noise_big = SampleNoise(tcrdBig);
	float noise_medium = SampleNoise(tcrdBig*100);
	float noise_small = SampleNoise(tcrdSmall);
	
	float noise_total = noise_big*0.2 + noise_medium*0.2;
	
	
	//float2 surface_tcoord = float2(
	//			input.data.y+noise_total*3.2+globalHumidityModifier,
	//			input.data.z+noise_total*0.2+globalTemperatureModifier + input.data.x*100
	//			);
	float4 surface_rampcolor = 1;//sTexture.Sample(MeshTextureSampler,surface_tcoord);
	if (customBlend)
	{
		surface_rampcolor = BlendTilesetTest(input.data,tcrdBig*4*2);
	}
	else
	{
		//float noise_bigA = SampleNoise(tcrdBig*0.005);
		//float noise_bigB = SampleNoise(tcrdBig*0.005+0.24);
		//+float2(noise_bigA,noise_bigB)
		//float angle22 =   1-pow(dot(-globalNormal,-input.normal),10);
		surface_rampcolor = BlendTilesetSpace(input.data,tcrdBig*4*2 );
		//surface_rampcolor = lerp(surface_rampcolor,surface_rampcolor*float4(1,0.6,0.6,1),angle22); 
	//	return float4(noise_bigA,noise_bigB,0,1);
	//surface_rampcolor = angle22;
	}
	
	
	bool isunderwater = hasHydrosphere;// && input.data.x<0.00;
	float specular_intensity = 0.001;
	  
	  
	float topDot = saturate(dot(globalNormal,input.normal)); 
	
	if(isunderwater)
	{
		localLightIntencity = globalLightIntencity;

		
		
		//float2 water_tcoord = float2(1+input.data.x*3,input.data.z+globalTemperatureModifier);
		//float4 water_rampcolor = wTexture.Sample(MeshTextureSampler,water_tcoord);
		surface_rampcolor.rgb =lerp(surface_rampcolor.rgb, oceanColor/(1-input.data.x*1000),saturate(-input.data.x*1000000));// water_rampcolor; 
	
		float wetness =  saturate(-input.data.x*10000000+1);
		surface_rampcolor.rgb *=1-wetness*0.8;
		specular_intensity =wetness*0.7*saturate((1-topDot)*5);
		if( input.data.x<0.00 && 0.99<saturate(surfaceDistance*10-10	)) //!nearMode && 
		{
			input.normal = globalNormal;
			topDot =1;
			specular_intensity =0.7;
		}
	}  
	float clouds_dencity =0;
	float clouds_shadow_rampcolor = 1;
	//////if(hasAtmoshphere)
	//////{ 
	//////	float2 clouds_timeshift = float2(time*0.0001f,0);
	//////	float3 ambmapEnv = normalize(mul(float4(input.wpos-planetpos
	//////		-globalNormal2/distanceMultiplier*3
	//////		,1),EnvInverse).xyz);//mul(float4(globalNormal,1),EnvInverse).xyz;
	//////	float2 tcoordSphere = ToSpherical(ambmapEnv).xy+clouds_timeshift;//*float2(1.15,1);
	//////	float4 clouds_rampcolor = cTexture.Sample(NearTextureSapler,tcoordSphere);
	//////	clouds_dencity = blend_clouds* clouds_rampcolor.a*clouds_rampcolor.a;
	//////	
	//////	float3 shiftedAmbmapEnv =normalize(mul(float4(input.wpos-planetpos+lightDir*6/distanceMultiplier,1),EnvInverse).xyz);//  mul(float4(globalNormal+lightDir*0.005,1),EnvInverse).xyz; 
	//////	clouds_shadow_rampcolor = saturate(1-blend_clouds*cTexture.Sample(NearTextureSapler,
	//////		ToSpherical(shiftedAmbmapEnv).xy+clouds_timeshift).a);
	//////	
	//////	 
	//////	 specular_intensity =  (specular_intensity - clouds_dencity*0.3);
	//////}
	 
	if(input.data.w>10)
	{
		if(input.data.w>10000)
		{   
			float2 tile_textcoord = float2(1-tcrdSmall.x,tcrdSmall.y)/200;
			float4 forest = tNoise2.Sample(NoiseTextureSampler,tile_textcoord); 
			float4 forest2 = tNoise.Sample(NoiseTextureSampler,tcrdBig*100); 
		//	surface_rampcolor = float4(1,0,0,1);
			clip(forest.r-saturate(input.data.w/10000-1)-forest2.r);
			surface_rampcolor *=forest.r*0.8;
		}
		else
		{ 
			float2 grassTcrd =input.tnormal.yx;/// float2(input.data.w-10000,(tcrdSmall.x+tcrdSmall.y));  
			float4 grass = sTexture.Sample(MeshTextureSampler,grassTcrd);
		//	float4 forest2 = tNoise.Sample(NoiseTextureSampler,tcrdBig*10000); 
			//surface_rampcolor *= saturate(grass*8*grassTcrd.y);
//UPDATE//surface_rampcolor *=lerp(grass.r*2,1, saturate(grassTcrd.y*grassTcrd.y*grassTcrd.y));
			//surface_rampcolor =grassTcrd.y*grassTcrd.y*grassTcrd.y;
			clip(grass.a-0.5);//-forest2.r 
		}
	}
	  
	 
	float4 ambient = (1-blend_nearfog) * saturate(EnvSampleLevel(input.normal,0));
  
	

	float3 brightness3 =//ApplyPointLights(input.wpos,input.normal,cameraDirection,specular_intensity,100);//
	ApplyPointLights3(surface_rampcolor,input.wpos,input.normal,cameraDirection,specular_intensity,0,true,globalLightIntencity,saturate(1));
	 
	//float3 brightness4 = 
	//ApplyPointLights3(float3(1,1,1),input.wpos,globalNormal,cameraDirection,0,0);
	float3 total_brightness =(brightness3);// max(min(brightness3,brightness4),ambientlightIntencity);
	//total_brightness =(total_brightness - total_brightness*0.3+brightness4*0.3)*saturate(atmoLight);
	 
	//return pow(asd,1.0/3);
	
	
	 float globalAFI =  saturate(pow(planetRim,1)*0.5);//+pow(planetRim,5)+0.2f); 
	 float localAFI =   1; 
	 float fogDistanceMultiplier = pow(  saturate(surfaceDistance/(horizdist)),1.0/3); 
	 float atmosphereFogIntencity =angle*fogDistanceMultiplier*globalAFI;//lerp(1,globalAFI,blend_nearfog);// lerp(localAFI,globalAFI,blend_clouds); 
	 float3 finalFog = atmoLight*atmosphereFogIntencity;//atmoLight*saturate(brightness4)*atmosphereFogIntencity; 
	 
	 
	//mapmode
	//total_brightness = 0.1;
	//clouds_dencity=0;
	//clouds_shadow_rampcolor=1;
	//specular_intensity=0;
	//if(isunderwater)
	//{
	//	total_brightness=total_brightness*float3(0.1,0.2,0.5);
	//}
	//end
	
	
	float3 finalColor =surface_rampcolor;// 
	
	//+total_brightness*atmoLight;// input.color*surface_rampcolor*total_brightness;
	
	
	float blend_medium = saturate(1 - surfaceDistance*2); 
	float blend_far = saturate(1-blend_medium);
	float2 tile_textcoord = float2(1-tcrdSmall.x,tcrdSmall.y);
	float4 tilecolor = lerp(float4(0.1,0.1,0.1,1),BlendTileset(input.data,tile_textcoord,topDot,surfaceDistance)*0.1,1-blend_nearfog)*2;
	
	if(!isunderwater)
	{
		//tilecolor *= float4(input.color,1);
	}
	finalColor = finalColor*tilecolor*2+tilecolor.rgb;//*ambient*2;//0.125;
	
	//output.color +=float4((total_brightness+atmoLight*0.02)*finalColor,0);
	////if(hasAtmoshphere)
	////{ 
	//////	float3 finalClouds = clouds_dencity*atmoLight*globalLightIntencity*0.5;
	////	
	//////	finalColor = finalColor*saturate(clouds_shadow_rampcolor*3); 
	//////	finalColor = lerp(finalColor,finalClouds,clouds_dencity);
	//////	finalColor = lerp(finalColor,finalFog, atmosphereFogIntencity*blend_clouds); 
	////	// finalColor = finalFog;
	////	
	//////finalColor += GetIsInViewMatrix(float4(input.wpos,1),ShadowMapVPMatrix)/2;
	//// 
	////}
	//return float4(ToSpherical(globalNormal).xy,0,1);
	output.color+=float4(finalColor*ambient*2,1);
	output.mask = float4(1,specular_intensity,0,0);

	return float4(finalColor,specular_intensity); 
}
 
float3 NearbyColor(PS_IN input,float wposLen,float surfaceDistance)
{ 
	float2 tcrdSmall = input.tcrd.zw;
	
	float blend_medium = saturate(1 - surfaceDistance*2); 
	float blend_far = saturate(1-blend_medium);
	float3 globalNormal = normalize(input.lpos);
	float3 cameraDirection = normalize(input.wpos);
	float topDot = saturate(dot(globalNormal,input.normal));
	
	float specular_intensity = 0.1;
	
	float3 atmoLight = GetAtmosphericLight(dot(lightDir,globalNormal), lightColor);
	
	float2 tile_textcoord = float2(1-tcrdSmall.x,tcrdSmall.y);
	float4 tilecolor = float4(0.5,0.5,0.5,1)* blend_far + BlendTileset(input.data,tile_textcoord,topDot,surfaceDistance);
	
	float3 ambient =  EnvSampleLevel(input.normal,0.9);
	float3 brightness3 = //ApplyPointLights(input.wpos,input.normal,cameraDirection,specular_intensity,100,false,false);
	ApplyPointLights3(tilecolor.rgb,input.wpos,input.normal,cameraDirection,specular_intensity,0,false);
	//float3 brightness4 = ApplyPointLights(input.wpos,globalNormal,cameraDirection,10,100);
	float3 totalbrightness = ambient + brightness3;//+ (brightness3*brightness4);
	
	
				
	float3 finalColor =tilecolor.rgb* ambient +  brightness3;
	
	bool isunderwater = hasHydrosphere && input.data.x<0.00;
	
	 
	float2 water_tcoord = float2(1+input.data.x*3,input.data.z+globalTemperatureModifier);
	float4 water_rampcolor = wTexture.Sample(MeshTextureSampler,water_tcoord); 
  
	if(isCameraUnderWater)
	{ 
		finalColor = lerp( finalColor*0.8,brightness3*water_rampcolor, saturate(surfaceDistance*20));
	}
	else
	{
		if(isunderwater)
		{ 
			float depth_light_decay = saturate( (-input.data.x)/0.000005);
			finalColor = lerp( finalColor*0.8,water_rampcolor*2, depth_light_decay);
		}
	}
	
	return finalColor; 
}
 
float4 Simplified(PS_IN input,float wposLen,float surfaceDistance)
{ 
	float2 tcrdSmall = input.tcrd.zw;
	
	bool isunderwater = hasHydrosphere && input.data.x<0.00;
	float coastline  = saturate(1/abs(input.data.x*1000000));
	float3 color = coastline+step(0,input.data.x)*0.1;
	float hot = step(0.1,input.data.z);
	float cold = step(input.data.z,0);
	color *= lerp(float3(1,1,1),float3(0.3,1,0.4),1-cold-hot);
	color *= lerp(float3(1,1,1),float3(1,0.5,0),hot);
	color *= lerp(float3(1,1,1),float3(0.2,0.5,1),cold);
	//float temp = data.z;
	//float height = data.x*1000000;
	//BlendB( BlendB(bl_hot,bl_temp,0.099,0.1,temp),bl_cold,-0.01,0,temp);
	return float4(color*float3(0.7,0.8,0.6)*0.15,1);
}


PS_OUT PS( PS_IN input ) : SV_Target
{ 
	PS_OUT output = (PS_OUT)0;
	////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////
	 
	////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////
	
	float wposLen = length(input.wpos);
	float surfaceDistance = wposLen * distanceMultiplier;
	float blend_medium = saturate(1 - surfaceDistance*2); 
	float blend_far = saturate(1-blend_medium);
	
	float blend_space = saturate(surfaceDistance/10); 
	
	output.mask = float4(1,0,0,0);
	float4 color_space = SpaceColor(input,wposLen,surfaceDistance,output); //SpaceColor//Simplified
	//float3 color_nearby = NearbyColor(input,wposLen,surfaceDistance); 
	
	//42
	float blend = saturate(surfaceDistance*10-10)*saturate(-input.data.x*100000000);//saturate(color_space.w*20); //lerp(0.2,color_space.w*2,saturate(surfaceDistance/100));
	output.normal = float4(lerp(input.normal,normalize(input.lpos),blend)*0.5+0.5,1);
	output.depth = //input.pos.w;//
	input.pos.z;///input.pos.w;
	//output.depth = 1000-wposLen;//input.pos.z;///input.pos.w; 
//	output.mask = float4(1,0,0,1);// float4(blend,blend,0,1);
	 
	if(isCameraUnderWater)
	{  
		float depth = max(1,-input.data.x*1000000.0); 
		output.diffuse =float4( NearbyColor(input,wposLen,surfaceDistance)/depth,1);; ;//float4(color_nearby*hdrMultiplier,1);
		output.mask = float4(1-saturate(surfaceDistance*20),0.2,1,0);
	}
	else
	{
		output.diffuse = color_space;//float4(lerp(color_nearby,color_space.rgb,blend_space)*hdrMultiplier,1);
	}
	//float4 sacolor = tGradient.Sample(MeshTextureSampler,float2(input.color.x,0)); 
	//output.diffuse=sacolor;//float4(input.color,1);
	//output.color +=output.diffuse/4;
	//output.mask = 0; 
	return output; 
}

PS_OUT PS2( PS_IN input ) : SV_Target
{ 
	PS_OUT output = (PS_OUT)0;
	
	float3 globalNormal = normalize(input.lpos);
	float globalLightIntencity = saturate(dot(lightDir,globalNormal));
	
	output.color = float4(globalLightIntencity,globalLightIntencity,globalLightIntencity,1);
	output.normal = float4(input.normal,1);
    output.depth =input.pos.z/input.pos.w;// float4(input.pos.z/100,input.pos.z/100,input.pos.z/100,1);
	output.mask = 0; 
	return output;
}


DCI_PS_IN SHADOW_VS( VS_IN input)//, IS_IN input2 ) 
{
	DCI_PS_IN output = (DCI_PS_IN)0;
 
	float4 pos = input.pos;
	 
	float4 wpos = mul( pos,transpose(World));
	output.pos =  mul(mul(wpos,transpose(View)),transpose(Projection));
	///////////////////////////////////
	#ifdef SHADOWWARP_ENABLED
	  output.pos.x=output.pos.x/(abs(output.pos.x)+depth_shadow_bendadd); 
	  output.pos.y=output.pos.y/(abs(output.pos.y)+depth_shadow_bendadd); 
	#endif
	///////////////////////////////////
	return output;
}
 
float SHADOW_PS_FLOAT( DCI_PS_IN input ) : SV_Target
{   
	return input.pos.z*input.pos.w;
}
float4 SHADOW_PS_COLOR( DCI_PS_IN input ) : SV_Target
{   
	return float4(DepthEncode(input.pos.z*input.pos.w),1);
}

/* copy
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
*/

bool _DrawGSGrass = true;

void Plane( inout TriangleStream<PS_IN> TriStream,float4x4 mx, float3 p1,float3 p2,float3 p3,float3 p4)
{ 
    PS_IN outputA=(PS_IN)0;
    PS_IN outputB=(PS_IN)0;
    PS_IN outputC=(PS_IN)0;
    PS_IN outputD=(PS_IN)0;
	float3 N =normalize( cross(p1-p2,p1-p3));
	
	outputA.pos =   mul(float4(p1,1),mx);
	outputA.normal = N;
	outputA.tcrd = float4(0,0,0,0);
	outputB.pos =  mul(float4(p2,1),mx);
	outputB.normal = N;
	outputB.tcrd = float4(0,0,0,0);
	outputC.pos =  mul(float4(p3,1),mx);
	outputC.normal = N;
	outputC.tcrd = float4(0,0,0,0);
	outputD.pos =  mul(float4(p4,1),mx);
	outputD.normal = N;
	outputD.tcrd = float4(0,0,0,0);
	
	TriStream.Append( outputA );
	TriStream.Append( outputB );
	TriStream.Append( outputC );
    TriStream.RestartStrip();
	
	TriStream.Append( outputC );
	TriStream.Append( outputB );
	TriStream.Append( outputD ); 
    TriStream.RestartStrip();
}
[maxvertexcount(3+12+12)]//+3
void GSScene( triangle PS_IN input[3], inout TriangleStream<PS_IN> OutputStream )
{   
    PS_IN output = (PS_IN)0;
	float4x4 mx =mul(transpose(View) ,	transpose(Projection));
	//float4x4(
	//1,0,0,0,
	//0,1,0,0,
	//0,0,1,0,
	//0,0,0,1);//
	//mul(mul(transpose(World) ,	transpose(View)),	transpose(Projection));
 
   //for( uint i=0; i<3; i+=1 )
   //{ 
   //    output.pos = input[i].pos;
   //    output.normal = input[i].normal;
   //    output.bnormal = input[i].bnormal;
   //    output.tnormal = input[i].tnormal;
   //    output.tcrd = input[i].tcrd;
   //    output.data = input[i].data;
   //    output.wpos = input[i].wpos;
   //    output.lpos = input[i].lpos;
   //    output.color = input[i].color;
   //    
   //    OutputStream.Append( output );
   //}
   //
   //OutputStream.RestartStrip();
	float3 fpp1 = input[0].pos;
	float3 fpp2 = input[1].pos;
	float3 fpp3 = input[2].pos;
	input[0].pos = mul(input[0].pos,mx);
	input[1].pos = mul(input[1].pos,mx);
	input[2].pos = mul(input[2].pos,mx);
	OutputStream.Append( input[0] );
	OutputStream.Append( input[1] );
	OutputStream.Append( input[2] ); 
	OutputStream.RestartStrip();

	bool gdc = false;
	// forest "fur"
	///*
	if(_DrawGSGrass && hasAtmoshphere && input[0].data.x*1000000>0.7)
	{
		float3 dn =input[1].normal ;
		if(dot(dn,float3(0,1,0))>0.95) 
		{ 
			float dist = length(fpp1)*distanceMultiplier;
			if(dist>0.6&&dist<15)//dist>0.4&&
			{
				gdc = true;
				if(dist<3)
				{
					float distmul =1.5/distanceMultiplier;//saturate((dist-0.4)*2);
					float3 dp = float3(0,distmul,0);
					[unroll]
					for (int x = 1; x < 8; x++)
					{
						float3 w = 0.001*dp*x*2;  
						input[0].data.w  = x*1000+10000;
						input[1].data.w  = x*1000+10000;
						input[2].data.w  = x*1000+10000;
						input[0].pos = mul(float4( fpp1 +w,1),mx);
						input[1].pos = mul(float4( fpp2 +w,1),mx);
						input[2].pos = mul(float4( fpp3 +w,1),mx);
						OutputStream.Append( input[0] );
						OutputStream.Append( input[1] );
						OutputStream.Append( input[2] ); 
						OutputStream.RestartStrip();
					}
				} 
				else
				{
					float3 w = 0.01*float3(0,1,0) ;  
					input[0].data.w  = 11000;
					input[1].data.w  = 11000;
					input[2].data.w  = 11000;
					input[0].pos = mul(float4( fpp1 +w,1),mx);
					input[1].pos = mul(float4( fpp2 +w,1),mx);
					input[2].pos = mul(float4( fpp3 +w,1),mx);
					OutputStream.Append( input[0] );
					OutputStream.Append( input[1] );
					OutputStream.Append( input[2] );  
					OutputStream.RestartStrip();
				}
			}
		}
	}
	//*/

 	//grass  height*1000000>1, topDot>098 
	if(  _DrawGSGrass && !gdc && hasAtmoshphere && nearMode && input[0].data.x*1000000>0.7 )
	{
		float height = 1;
		float dist = length(fpp1)*distanceMultiplier;
		if(dist>0.1)
		{
		//TEMP//	float lpr = saturate((dist-0.1)*10);
		//TEMP//	height = 100*lpr; 
			//input[0].color*=lerp(float3(1,1,1),float3(1,0,0),lpr);
			//input[1].color*=lerp(float3(1,1,1),float3(1,0,0),lpr);
		}  
		else
		{
			float3 dn =input[1].normal ;
			float3 n = dn/distanceMultiplier*4*height+float3(
				cos(time+fpp1.x*1000+fpp1.z*3000)*0.3,
				0, 
				cos(time*3+fpp1.x*500+fpp1.z*2000+0.3)*0.3
				)*2;
			
			if(dot(input[0].normal,float3(0,1,0))>0.9 && dot(dn,float3(0,1,0))>0.9) 
			{ 
				float nval = tNoise.SampleLevel(NoiseTextureSampler,input[0].tcrd*10000,0).x;
				if(nval>0.3)
				{
					input[0].data.w = 10000;
					input[1].data.w = 10000;
					PS_IN b2 = input[0];
					PS_IN b4 = input[1];
					b2.data.w = 1001;
					b4.data.w = 1001;
					
					input[0].tnormal = float3(1,0.2,0);
					input[1].tnormal = float3(1,0.8,0);
					b2.tnormal = float3(0,0.2,0);
					b4.tnormal = float3(0,0.8,0);
					b2.tcrd += float4(0,0,0,0.01);
					b4.tcrd += float4(0,0,0,0.01);
					
					b2.pos = mul(float4(fpp1.xyz+n*0.0001,1),mx); 
					b4.pos = mul(float4(fpp2.xyz+n*0.0001,1),mx); 
					
					OutputStream.Append( input[0] ); 
					OutputStream.Append( b2 );
					OutputStream.Append( input[1] );  
					OutputStream.RestartStrip();
					
					OutputStream.Append( input[1] ); 
					OutputStream.Append( b2 ); 
					OutputStream.Append( input[0] ); 
					OutputStream.RestartStrip();
					
					OutputStream.Append( input[1] ); 
					OutputStream.Append( b2 ); 
					OutputStream.Append( b4 ); 
					OutputStream.RestartStrip();
					
					OutputStream.Append( b4 ); 
					OutputStream.Append( b2 ); 
					OutputStream.Append( input[1] ); 
					OutputStream.RestartStrip();
				}
			}
		}
	}
   
   //if(input[0].data.x>0)
   //{
	//	float3 n = input[0].normal;//normalize( cross(input[0].pos-input[1].pos,input[0].pos-input[2].pos));
	//	if(dot(n,float3(0,1,0))>0.8)
	//	{
	//		float3 p1 = input[0].pos;
	//		float3 p2 = p1+n*0.0001; 
	//		float3 p3 = input[1].pos;
	//		float3 p4 = p3+n*0.0001; 
	//		
	//		Plane(OutputStream,mx ,p1,p2,p3,p4);
	//	}
   //}
}


technique10 Render
{
	pass P0
	{ 
		SetVertexShader( CompileShader( vs_4_0, VSPGS() ) );
		SetGeometryShader(  CompileShader( gs_4_0, GSScene() )  );
		SetPixelShader( CompileShader( ps_4_0, PS() ) );
	}
}
technique10 shadow
{
	pass P0
	{
		SetGeometryShader( 0 );
		SetVertexShader( CompileShader( vs_4_0, SHADOW_VS() ) );
		SetPixelShader( CompileShader( ps_4_0, SHADOW_PS_FLOAT() ) );
	}
}
technique10 shadow_color
{
	pass P0
	{
		SetGeometryShader( 0 );
		SetVertexShader( CompileShader( vs_4_0, SHADOW_VS() ) );
		SetPixelShader( CompileShader( ps_4_0, SHADOW_PS_COLOR() ) );
	}
}