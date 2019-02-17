
#include "headers/skin.fxh"
#include "headers/lightning.fxh"
#include "headers/enviroment.fxh"
#include "headers/hdr.fxh"

float4x4 Projection;
float4x4 View;
float4x4 World;
 
float4x4 EnvInverse;

float3 lightdir = normalize(float3(1,1,1));
float3 lightdir2 = normalize(float3(-1,1,-1));
float3 Color = float3(1,1,1)*0.9;
float3 Color2 = float3(0.02,0.1,0.2);

float3 tint = float3(1,1,1);//*0.9;

float3 drawableColorIndex = float3(1,0,0);


float3 ambient = float3(1,1.1,1.2)/20*2;
float hdrMultiplier=1;
float brightness=1;
float ssao_mul=1;

float global_scale=1;
float mindist = 0;
float maxdist = 999999999;
float fadewidth = 0.1;

float time =0;
float2 textureshiftdelta = float2(0,0);
float2 texcoordmul = float2(1,1);

 
Texture2D g_MeshTexture;   
Texture2D g_MeshTexture_n;  
Texture2D g_MeshTexture_s;  
Texture2D g_MeshTexture_m; 
Texture2D g_MeshTexture_e; 
Texture2D g_NoiseTexture; 
Texture2D g_LightwarpTexture; 
Texture2D g_DetailTexture;   
Texture2D g_DetailTexture_n;   

Texture2D g_tDiffuseView;     
Texture2D g_tNormalView;    
Texture2D g_tDepthView;    

TextureCube g_SkyTexture; 

bool TextureEnabled = false;
bool DetailEnabled = false;
bool FullbrightMode = false;
bool SkyboxMode = false;
bool LightwarpEnabled = false;
bool alphatest = false;
bool rimfade = false;
bool screenTexture = false;
bool receiveShadows = true;

float base_specular_power = 10;
float base_specular_intencity = 0.3f; 
float base_specular_tint = 0.3f;
float base_specular_rim_intencity = 0;//.1f; 
float base_emissive_intencity = 0;
float mul_specular_power =1;
float mul_specular_intencity = 1; 
float mul_specular_tint = 1;
float mul_specular_rim_intencity =0.03f;
float mul_emissive_intencity = 1;

float base_tdencity_val = 1;


float pow_skybox_mul =2;

float2 screenSize = float2(1024,1024);
float2 detailscale = float2(0.01,0.01);

bool noiseclip = false;
float noiseclipedge = 0;
float noiseclipmul = 1;
int detailblendmode = 0;
float detailblendfactor = 1;
 
bool clipenabled = false;
float4 clipplane;


SamplerState MeshTextureSampler
{
    Filter = MIN_MAG_MIP_LINEAR;
    AddressU = Wrap;
    AddressV = Wrap;
};

SamplerState LightwarpSampler
{
    Filter = MIN_MAG_MIP_LINEAR;
    AddressU = Clamp;
    AddressV = Clamp;
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

struct VSS_IN
{
	float4 pos : POSITION; 
	float3 norm : NORMAL;  
	float3 bnorm : BINORMAL; 
	float3 tnorm : TANGENT; 
	float2 tcrd : TEXCOORD; 
    float4 wts  : BLENDWEIGHT;
    float4 inds  : BLENDINDICES;
	float3 color : COLOR0; 
	
	 
};

struct MORPH_IN
{
	float4 pos : POSITION1; 
	float3 norm : NORMAL1; 
	float3 bnorm : BINORMAL1; 
	float3 tnorm : TANGENT1; 
};

struct I_IN
{
	float4x4 transform : WORLD; 
};
struct IC_IN
{
	float4x4 transform : WORLD; 
	float4 color : COLOR1;
};
 
struct PS_IN
{ 
	float4 pos : SV_POSITION;
	float2 tcrd : TEXCOORD0; 
	float3 wpos : TEXCOORD1; 
	float3 norm : TEXCOORD2;  
	float3 bnorm : TEXCOORD3; 
	float3 tnorm : TEXCOORD4;
	
	float3 color : TEXCOORD5;
	float3 spos : TEXCOORD6;
	
	//float z_depth : TEXCOORD2;
};

struct DCI_PS_IN
{ 
	float4 pos : SV_POSITION;  
	float2 tcrd : TEXCOORD0;  
	float3 wpos : TEXCOORD1; 
};

struct PS_OUT
{
    float4 color: SV_Target0;
    float4 normal: SV_Target1;
    //float4 position: SV_Target2;
    float depth: SV_Target2;
    float4 mask: SV_Target3;
    //float4 light: SV_Target4;
};

PS_IN VSI( VSS_IN input, I_IN inst ) 
{
	PS_IN output = (PS_IN)0;
	if(SkinningEnabled)
	{
		Skin(input.pos,input.norm,input.wts,input.inds);
	}
	float4x4 InstWorld = mul(transpose(inst.transform),transpose(World));
	float4 wpos = mul(input.pos,InstWorld);
	float4x4 VP =mul(transpose(View),transpose(Projection));
	
	float3x3 nworld = (float3x3)(InstWorld);
	
	output.pos =  mul(wpos,VP);
	output.wpos = wpos.xyz;
	output.norm = normalize(mul(input.norm,nworld)); 
	output.bnorm = normalize(mul(input.bnorm,nworld)); 
	output.tnorm = normalize(mul(input.tnorm,nworld)); 
	output.tcrd = input.tcrd;
	output.color = input.color;//((float3)input.inds.xyz);
	output.spos = mul(wpos,transpose(View));
	return output;
}
PS_IN VSIC( VSS_IN input, IC_IN inst ) 
{
	PS_IN output = (PS_IN)0;
	if(SkinningEnabled)
	{
		Skin(input.pos,input.norm,input.wts,input.inds);
	}
	float4x4 InstWorld = mul(transpose(inst.transform),transpose(World));
	float4 wpos = mul(input.pos,InstWorld);
	float4x4 VP =mul(transpose(View),transpose(Projection));
	
	float3x3 nworld = (float3x3)(InstWorld);
	
	output.pos =  mul(wpos,VP);
	output.wpos = wpos.xyz;
	output.norm = normalize(mul(input.norm,nworld)); 
	output.bnorm = normalize(mul(input.bnorm,nworld)); 
	output.tnorm = normalize(mul(input.tnorm,nworld)); 
	output.tcrd = input.tcrd; 
	output.color = input.color*inst.color.xyz*tint;//((float3)input.inds.xyz);
	output.spos = mul(wpos,transpose(View));
	return output;
}
PS_IN VSIM( VSS_IN input, MORPH_IN morph ) 
{ 
	PS_IN output = (PS_IN)0;
	input.pos = morph.pos;
	input.norm = morph.norm;
	input.bnorm = morph.bnorm;
	input.tnorm = morph.tnorm;
	
	if(SkinningEnabled)
	{
		Skin(input.pos,input.norm,input.wts,input.inds);
	} 
	float4 wpos = mul(input.pos,transpose(World));
	float4x4 VP =mul(transpose(View),transpose(Projection)); 
	float3x3 nworld = (float3x3)(transpose(World));
	
	output.pos =  mul(wpos,VP);
	output.wpos = wpos.xyz;
	output.norm = normalize(mul(input.norm,nworld)); 
	output.bnorm = normalize(mul(input.bnorm,nworld)); 
	output.tnorm = normalize(mul(input.tnorm,nworld)); 
	output.tcrd = input.tcrd; 
	output.color = input.color*tint;//((float3)input.inds.xyz);
	output.spos = mul(wpos,transpose(View));
	return output;
}
const float near = 0.001; // projection matrix's near plane
const float far = 1.0; // projection matrix's far plane
float LinearizeDepth(float depth)
{
    float z = depth * 2.0 - 1.0; // back to NDC 
    return (2.0 * near * far) / (far + near - z * (far - near));    
}
float3 Lightwarp(float3 light)
{
	if (LightwarpEnabled) 
	{
		float brightness = length(light);///8;
		float3 color = g_LightwarpTexture.Sample(LightwarpSampler, float2(brightness,0.5)).rgb;
		return   color;//*8;//*saturate(light/brightness);
	}
	else
	{
		return light;
	} 
}
PS_OUT PS_CHEAP( PS_IN input ) : SV_Target
{ 
	PS_OUT output = (PS_OUT)0;
	
	output.depth = 0;
	output.normal = float4(1,1,1,1);
	
	if(clipenabled)
	{
		float val = dot(clipplane.xyz,input.wpos)+clipplane.w;
		clip(val);
	}
	
	if(SkyboxMode)
	{
		float3 envdir = mul(input.wpos,EnvInverse);
		float4 envmap = //EnvSample(envdir);//
		g_SkyTexture.Sample(MeshTextureSampler,envdir);
		output.color = envmap;
	}
	else
	{
		
		if(TextureEnabled)
		{
			float2 texCoord = input.tcrd*texcoordmul + textureshiftdelta*time;
			if(screenTexture)
			{
				texCoord = input.pos.xy/screenSize;
			}
			output.color = g_MeshTexture.Sample(MeshTextureSampler, texCoord) ;
		}
		else
		{
		}
	}
	
	return output;
}
PS_OUT PS( PS_IN input ) : SV_Target
{ 
	PS_OUT output = (PS_OUT)0;

    //output.depth = 0;
	//output.color = g_MeshTexture.Sample(MeshTextureSampler, input.tcrd) ;
	//output.normal = float4(1,1,1,1);
	//return output;
	output.mask = 1;
	output.mask.x = ssao_mul;
	output.mask.y = 0;
    output.depth = input.pos.z/input.pos.w;
	//input.pos.w;///input.pos.w;//float4(input.pos.z/input.pos.w,0,0,1);//*input.pos.w
	
	if(clipenabled)
	{
		float val = dot(clipplane.xyz,input.wpos)+clipplane.w;
		clip(val);
	}
	
	float TBrightness = brightness * hdrMultiplier;
	float realDepth = length(input.wpos)/global_scale;
	float frontFade = saturate((realDepth - mindist)/fadewidth);
	float backFade = saturate(1-(realDepth - maxdist-fadewidth)/fadewidth);
	TBrightness =min(1,frontFade*backFade)*TBrightness;
	//TBrightness =min(TBrightness,backFade);
//	min(TBrightness,length(input.wpos)/global_scale*10-0.1);
	float detailFade = saturate((realDepth - 0.1)/0.1);
	
	float detailblend =1;// saturate(1-detailFade);
	
	float dpt = LinearizeDepth(input.pos.z);///input.pos.w;
	
	float2 texCoord = input.tcrd*texcoordmul + textureshiftdelta*time;
	if(screenTexture)
	{
		texCoord = input.pos.xy/screenSize;
	}
	if(SkyboxMode)
	{
		float3 envdir = mul(input.wpos,EnvInverse);
		float3 envmap =// EnvSampleLevel(envdir,1);// 
		g_SkyTexture.SampleLevel(MeshTextureSampler,envdir,0);
		output.color = float4(pow(envmap,pow_skybox_mul)*TBrightness,1);
		output.mask = 0;
	}
	else if(!FullbrightMode)
	{
		float4 bumpMap = g_MeshTexture_n.Sample(MeshTextureSampler, texCoord);
		
		
		if (DetailEnabled) 
		{	
			if (detailblend>0)
			{
				float4 detbumpMap = g_DetailTexture_n.Sample(MeshTextureSampler, texCoord*detailscale);
				//bumpMap = lerp(bumpMap, detbumpMap,detailblend);
				bumpMap = bumpMap+detbumpMap*detailblendfactor;
			}
		}
		if(bumpMap.x!=0 && bumpMap.y!=0 && bumpMap.z!=0)
		{
			bumpMap = bumpMap*2-1;
			if(base_tdencity_val<1)
			{
				bumpMap += (g_MeshTexture_n.Sample(MeshTextureSampler, texCoord+ float2(0.1,0.2)*time)*2-1)*0.6;
				bumpMap += (g_MeshTexture_n.Sample(MeshTextureSampler, texCoord+ float2(-0.1,0)*time)*2-1)*0.6;
				bumpMap += (g_MeshTexture_n.Sample(MeshTextureSampler, texCoord+ float2(0,0.02)*time)*2-1)*0.4;
			
				bumpMap = float4(normalize(bumpMap.xyz),1);
			}
			
			
			float3 bumpNormal = 
				(bumpMap.x * input.tnorm) 
				+ (bumpMap.y * input.bnorm) 
				+ (bumpMap.z * input.norm);
			if(!isnan(bumpNormal.x))
			{
				input.norm = normalize(bumpNormal);//normalize(input.norm+ bumpMap.z * input.norm);
			}
		}
		float specular_power = base_specular_power;
		float specular_intencity = base_specular_intencity;//1;
		float specular_tint = base_specular_tint;
		float specular_rim_intencity = base_specular_rim_intencity;
		float4 maskMap = g_MeshTexture_m.Sample(MeshTextureSampler, texCoord);
		if(maskMap.a!=0 || maskMap.r!=0|| maskMap.g!=0|| maskMap.b!=0)
		{
			specular_intencity += maskMap.r*mul_specular_intencity;
			specular_rim_intencity += maskMap.g*mul_specular_rim_intencity;
			specular_tint += maskMap.b*mul_specular_tint ;
			specular_power +=  pow(10,maskMap.a)*mul_specular_power;
		}
		float metalness = specular_tint;
		//float brightness = 0.95f*saturate(dot(input.norm,lightdir));
		//float brightness2 = 0.5f*saturate(dot(input.norm,lightdir2));
		//float3 reflection = reflect(lightdir,input.norm);
		//float3 reflection2 = reflect(lightdir2,input.norm);
		
		float4 emissiveMap = g_MeshTexture_e.Sample(MeshTextureSampler, texCoord);
		
		float3 emissive = emissiveMap.rgb*mul_emissive_intencity*input.color;
		
		float3 camdir = normalize(input.wpos);
		float3 diffuse = float3(1,1,1);
		
		float3 reflectcam = reflect(camdir,input.norm);
		float3 reflectEnv =  mul(float4(reflectcam,1),EnvInverse).xyz;
		float3 envmap = EnvSampleLevel(reflectEnv,specular_intencity);// g_EnvTexture.SampleLevel(MeshTextureSampler, reflectEnv,saturate(1-specular_intencity)*100);
		//float3 envmap = g_EnvTexture.SampleLevel(MeshTextureSampler, reflectcam,specular_power);
		
		output.mask.y = specular_intencity;
		output.mask.z = specular_tint;//specular_power;
		    
		float alpha = 1;
		if(TextureEnabled)
		{
			//float fTotalSum = effect_pen_Process(g_MeshTexture,MeshTextureSampler,1800/1,1000/1,input.tcrd);
			float4 texIn = g_MeshTexture.Sample(MeshTextureSampler, texCoord) ;//* saturate(1-fTotalSum*10);//(0.5 < fTotalSum?0:1);
			diffuse *= texIn.rgb * input.color;//
			alpha =  texIn.a;
			if (DetailEnabled) 
			{	
				if (detailblend>0)
				{
					float4 dtexIn = g_DetailTexture.Sample(MeshTextureSampler, texCoord*detailscale);//) ;	
					//0-mul
					//1-add
					//2-replace
					if(detailblendmode ==0)
					{
						dtexIn = (dtexIn-0.5)*2*detailblendfactor+1;
						diffuse = diffuse * dtexIn.rgb;
						//alpha = alpha*dtexIn.a;
					}
					else if(detailblendmode ==1)
					{
						//diffuse = lerp(diffuse, dtexIn.rgb,blend);
						alpha = lerp(alpha, alpha*dtexIn.x,detailblend);
					}
					else if(detailblendmode ==2)
					{
						diffuse = dtexIn.rgb;//lerp(diffuse, dtexIn.rgb,blend); 
					}
				}
			}
			if(alphatest)
			{
				//clip(alpha-0.91);
				clip(alpha-0.5);
				//alpha = 1;
			}
		}
		else
		{
			//diffuse.xy *=  float2(0.9,0.9)+input.tcrd*0.2;
			diffuse.xyz * input.color;
		}
		diffuse+=float3(0.2,0.2,0.2)*metalness;
		
		float3 reflectcolor = lerp(float3(1,1,1),normalize(diffuse.xyz),metalness);
		
		diffuse.xyz+= Lightwarp(envmap*specular_intencity*reflectcolor*Fresnel(dot(input.norm,-camdir)));
		 
		//diffuse.xyz = float3(specular_power,specular_power,specular_power)/10;
		//diffuse.xyz = float3(specular_intencity,specular_intencity,specular_intencity);
		//float3 specularcolor = saturate(((1-specular_tint)*float3(1,1,1)) + ((specular_tint)* diffuse));
		//float3 specular =   specular_intencity*pow(saturate(dot(reflection,camdir)),specular_power);
		//float3 specular2 =   specular_intencity*pow(saturate(dot(reflection2,camdir)),specular_power);
		float rimlight = pow(saturate(1-dot(input.norm,-camdir)),10);
		 
		//specular =  saturate(specularcolor*specular);
		//specular2 = saturate(specularcolor*specular2);
		float3 brightness3 = ApplyPointLights2(input.wpos,input.norm,camdir,diffuse.rgb,saturate(specular_rim_intencity),metalness,specular_intencity,specular_power,receiveShadows);
			//ApplyPointLights(input.wpos,input.norm,camdir,specular_intencity,specular_power,receiveShadows);
		
		float3 ambmapEnv =  mul(float4(input.norm,1),EnvInverse).xyz;
		float3 ambmap = EnvSampleLevel(ambmapEnv,0.9);//g_EnvTexture.SampleLevel(MeshTextureSampler,ambmapEnv,10);
		brightness3+=ambmap*0.5;//Lightwarp(ambmap*0.5);// Lightwarp(ambmap*0.25);
		

		//brightness3 = float3(1,1,1);
		float3 result =  (diffuse * Lightwarp(ambient+brightness3*reflectcolor)) //+ saturate(specular_rim_intencity*0.5 * rimlight* float3(1,1,1))
		+emissive
		;
		if (LightwarpEnabled) 
		{
		float3 lambient = float3(1,1,1)*0.5f;
			result =  (diffuse * (lambient+Lightwarp(ambient+brightness3)/2)) //+ saturate(specular_rim_intencity*0.5 * rimlight* float3(1,1,1))
		;
		}
		//saturate(diffuse * (ambient + brightness*Color+brightness2*Color2+brightness3
		//+saturate(specular_rim_intencity *0.8* rimlight* float3(1,1,1)*diffuse)))
		//+ specular*brightness*Color
		//+ specular2*brightness2*Color2
		//+ saturate(specular_rim_intencity*0.5 * rimlight* float3(1,1,1))
		
		//float3 reflectdir = dot(input.norm,-camdir);
		//float3 lerpdir = lerp(input.norm,reflectdir,saturate(specular_intencity));
		 
		//result.xyz+= Lightwarp(envmap*specular_intencity*reflectcolor*Fresnel(reflectdir));
		
		
		//result = brightness3; // lightmap as texture 
		if (rimfade )
		{
			float3 camdir = normalize(input.wpos);
			float frontalblend = pow(saturate(dot(input.norm*5,-camdir)),1);
			TBrightness*=saturate(frontalblend);
		}
		if (!isfinite(result.x)) result = float3(0,0,0);//float3(1,0,1)*10;
		output.color = float4(result*TBrightness,alpha);
		
		
		
		//output.color = float4(ambmap,1);
		//output.color = float4(input.norm/2+float3(0.5,0.5,0.5),1);
		
		//float fff = Fresnel(dot(input.norm,-camdir));
		//output.color = float4(fff,fff,fff,1);
		//{
		//	float c =g_NoiseTexture.Sample(MeshTextureSampler, input.wpos.xy*100+float2(time,0)).r;
		//	output.color +=float4(0.1,0.2,1,0)*c*rimlight;
		//	 
		//	
		//}
	}
	else
	{
		if (rimfade )
		{
			float3 camdir = normalize(input.wpos);
			float frontalblend = pow(saturate(dot(input.norm,-camdir)),1);
			TBrightness*=saturate(frontalblend);
		}
		if(TextureEnabled)
		{ 
			float4 texIn = g_MeshTexture.Sample(MeshTextureSampler, texCoord) ; 
			output.color = float4(Color*input.color*texIn.rgb*TBrightness,texIn.a*TBrightness);
		}
		else
		{ 
			output.color = float4(Color*input.color*TBrightness,TBrightness);
		}
		output.mask = float4(0,0,0,1);
	}
	float3x3 VP =(float3x3) mul(transpose(View),transpose(Projection));
	float3 vv = mul(input.norm,VP);
	float3 rer = normalize(input.norm);//vv.xyz);
	output.normal = float4(rer.x/2+0.5,rer.y/2+0.5,rer.z/2+0.5,1); 
	if(base_tdencity_val<1)
	{
		float3 camdir = normalize(input.wpos);
		float3 fn = refract(input.norm,-camdir,0.3);
		float3 ssfn = mul(fn,VP);
		
		float2 tc = input.pos.xy/screenSize;
		float4 pDepth = g_tDepthView.Sample(LightwarpSampler, tc);
		
		
		float rimlight = pow(saturate(dot(input.norm,-camdir)),1);
		
		
		//float2 tc = input.pos.xy/screenSize+float2(rer.x,rer.y)*saturate(1-(pDepth.x-output.depth.x)*100);
		float4 pDiffuseR = g_tDiffuseView.Sample(LightwarpSampler, tc+float2(ssfn.x,ssfn.y)*pDepth.x*10000/screenSize/10); 
		float4 pDiffuseG = g_tDiffuseView.Sample(LightwarpSampler, tc+float2(ssfn.x,ssfn.y)*pDepth.x*12000/screenSize/10); 
		float4 pDiffuseB = g_tDiffuseView.Sample(LightwarpSampler, tc+float2(ssfn.x,ssfn.y)*pDepth.x*15000/screenSize/10); 
		//float4 pDiffuse = g_tNormalView.Sample(LightwarpSampler, tc); 
		float dpsat = saturate((1-(pDepth.x-output.depth.x)*1000*base_tdencity_val)*rimlight);
		//output.color = dpsat%1;
		output.color = lerp(output.color,float4(pDiffuseR.x,pDiffuseG.y,pDiffuseB.z,1),dpsat); 
		//output.color.r =rimlight;
		
	}
	
	//result = float3(1,1,1) *(saturate( ambient + brightness*Color) * saturate(  1 * rimlight <0.04?1:0));
	if(noiseclip)
	{
		float noised = g_NoiseTexture.Sample(MeshTextureSampler, texCoord).x;
		//float nnn = sin(time);
		clip(noised*noiseclipmul-noiseclipedge);
	}
	  
	//output.color += GetIsInViewMatrix(float4(input.wpos,1),ShadowMapVPMatrix)/2;
	 
	//result+=;
	//float3(1,1,1);
	//lerp(Color2.rgb,Color.rgb,saturate(brightness+brightness2)) * (diffuse + specular + specular2);
	// 
	//output.color = float4(texCoord,0,1);
///	float dpdepth = pow(input.pos.z,10);
	 
	//output.normal = float4(rer,1);
    //output.normal = float4(input.norm/2+float3(0.5,0.5,0.5),1);
	//output.position = input.pos;
	return output;
}


DCI_PS_IN CI_VSI( VSS_IN input, IC_IN inst ) 
{
	DCI_PS_IN output = (DCI_PS_IN)0;
	if(SkinningEnabled)
	{
		Skin(input.pos,input.norm,input.wts,input.inds);
	}
	float4x4 InstWorld = mul(transpose(inst.transform),transpose(World));
	float4 wpos = mul(input.pos,InstWorld);
	float4x4 VP =mul(transpose(View),transpose(Projection));
	
	float3x3 nworld = (float3x3)(InstWorld);
	
	output.wpos = wpos.xyz;
	output.pos =  mul(wpos,VP);
	///////////////////////////////////
	#ifdef SHADOWWARP_ENABLED
	  output.pos.x=output.pos.x/(abs(output.pos.x)+depth_shadow_bendadd); 
	  output.pos.y=output.pos.y/(abs(output.pos.y)+depth_shadow_bendadd);
	#endif
	///////////////////////////////////

	output.tcrd = input.tcrd;
	return output;
}

float4 CI_PS( DCI_PS_IN input ) : SV_Target
{  
	if(clipenabled)
	{
		float val = dot(clipplane.xyz,input.wpos)+clipplane.w;
		clip(val);
	}
	return float4(drawableColorIndex/255,1);
}

//float4 SHADOW_PS( DCI_PS_IN input ) : SV_Target
//{  
//	float dp = input.pos.z*input.pos.w;
//	//float dpx = (dp*1)%1;
//	//float dpy = (dp*100)%1;
//	//float dpz = (dp*10000)%1;
//	//float rentest = DepthDecode(DepthEncode(dp));
//	return float4(DepthEncode(dp),1);//+input.pos.x/1000,dp+input.pos.y/1000,dp,1);
//}

float SHADOW_PS_FLOAT( DCI_PS_IN input ) : SV_Target
{  
	float dp = input.pos.z*input.pos.w;
	if(SkyboxMode) 
	{
	 	clip(-1); 
	}
	else if(TextureEnabled && alphatest)
	{
		float4 texIn = g_MeshTexture.Sample(MeshTextureSampler, input.tcrd) ;   
		clip(texIn.a-0.5); 
	}
	return dp;//-0.001f; 
}

float4 SHADOW_PS_COLOR( DCI_PS_IN input ) : SV_Target
{  
	float dp = input.pos.z*input.pos.w; 
	if(TextureEnabled && alphatest)
	{
		float4 texIn = g_MeshTexture.Sample(MeshTextureSampler, input.tcrd) ;   
		clip(texIn.a-0.5); 
	}
	return float4(DepthEncode(dp),1); 
}
technique10 Instanced
{
	pass P0
	{
		SetGeometryShader( 0 );
		SetVertexShader( CompileShader( vs_4_0, VSIC() ) );
		SetPixelShader( CompileShader( ps_4_0, PS() ) );
	}
}
technique10 dci
{
	pass P0
	{
		SetGeometryShader( 0 );
		SetVertexShader( CompileShader( vs_4_0, CI_VSI() ) );
		SetPixelShader( CompileShader( ps_4_0, CI_PS() ) );
	}
}
technique10 shadow
{
	pass P0
	{
		SetGeometryShader( 0 );
		SetVertexShader( CompileShader( vs_4_0, CI_VSI() ) );
		SetPixelShader( CompileShader( ps_4_0, SHADOW_PS_FLOAT() ) );
	}
}
technique10 shadow_color
{
	pass P0
	{
		SetGeometryShader( 0 );
		SetVertexShader( CompileShader( vs_4_0, CI_VSI() ) );
		SetPixelShader( CompileShader( ps_4_0, SHADOW_PS_COLOR() ) );
	}
}
technique10 Morphed
{
	pass P0
	{
		SetGeometryShader( 0 );
		SetVertexShader( CompileShader( vs_4_0, VSIM() ) );
		SetPixelShader( CompileShader( ps_4_0, PS() ) );
	}
}
//technique10 InstancedColor
//{
//	pass P0
//	{
//		SetGeometryShader( 0 );
//		SetVertexShader( CompileShader( vs_4_0, VSIC() ) );
//		SetPixelShader( CompileShader( ps_4_0, PS() ) );
//	}
//}