
#include "headers/skin.fxh"
//#include "headers/lightning.fxh"
#include "headers/enviroment.fxh"
//#include "headers/hdr.fxh"

float4x4 Projection;
float4x4 View;
float4x4 World;
float4x4 WorldInv;
 
float4x4 EnvInverse;

float3 Color = float3(1,1,1);
float3 tint = float3(1,1,1);//*0.9;
float3 emissionTint = float3(1,1,1);//*0.9;

float3 drawableColorIndex = float3(1,0,0);
float3 freshnelRanges = float3(1,1,1);


float3 ambient = float3(1,1.1,1.2)/20*2;
float hdrMultiplier=1;
float brightness=1;
float ssao_mul=1;

float global_scale=1;
float distanceMultiplier=1;
float mindist = 0;
float maxdist = 999999999;
float fadewidth = 0.1;

float stencil = 0;

float time =0;
float2 textureshiftdelta = float2(0,0);
float2 texcoordmul = float2(1,1);

float outline = 0;
float3 outlineTint = float3(1,1,1)*0.1;

float2 rimfadeEmission = float2(1,2);

float furLen =0;
float2 furShift =float2(0,0);
 
Texture2D g_MeshTexture;   // albedo (r,g,b,a - alpha|cutoff)
Texture2D g_MeshTexture_n; // normal map (r,g,b)
Texture2D g_MeshTexture_s; // TODO: MERGE WITH g_MeshTexture_f (old material mask map)
Texture2D g_MeshTexture_m; // mask map (r - smootheness, g - deprecated, b - metallness, a - deprecated)
Texture2D g_MeshTexture_e; // emissive (r,g,b) colored
Texture2D g_MeshTexture_f; // materials mask (r,g,b,a) layers
Texture2D g_MeshTexture_g; // fur len  (x)
Texture2D g_MeshTexture_x; // fur mask (x-fur length)--TEST--
Texture2D g_MeshTexture_a; // ambient occlusion

Texture2D g_NoiseTexture;  

bool ao_enabled = false;

bool _DrawGSFur = true;
bool sMasksEnabled = false;
bool matMasksEnabled = false;
float4 matColors0 = float4(1,0,0,1);
float4 matColors1 = float4(0,1,0,1);
float4 matColors2 = float4(0,0,1,1);
float4 matColors3 = float4(0,0,0,1);

Texture2D g_DetailTexture;   
Texture2D g_DetailTexture_n;   
Texture2D g_DetailTexture_m;    

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
float base_subsurface_intencity = 0;
float mul_specular_power =1;
float mul_specular_intencity = 1; 
float mul_specular_tint = 1;
float mul_specular_rim_intencity =0.03f;
float mul_subsurface_intencity = 1;
float mul_emissive_intencity = 1;

float base_tdencity_val = 1;
float alphatestreference = 0.5;


float pow_skybox_mul =2;

float2 screenSize = float2(1024,1024);
float2 detailscale = float2(0.01,0.01);

bool noiseclip = false;
float noiseclipedge = 0;
float noiseclipmul = 1;
int detailblendmode = 0;
float detailblendfactor = 1;
bool detail_nonormal = false;
 
bool clipenabled = false;
float4 clipplane;


SamplerState MeshTextureSampler
{
    Filter = MIN_MAG_MIP_LINEAR;
    AddressU = Wrap;
    AddressV = Wrap;
};

SamplerState ClampSampler
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
	half layer : TEXCOORD7;
	float3 ambmap : TEXCOORD8;
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
    float4 light: SV_Target0;
    float4 normal: SV_Target1; 
    float depth: SV_Target2;
    float4 mask: SV_Target3;// r - deferred_intensity, g - smootheness, b - metallness, a - subsurface_scattering_transparency
    float4 diffuse: SV_Target4;
    //float4 light: SV_Target4;
	float stencil : SV_StencilRef; 
};

float3x3 MInv(float3x3 A) 
{
	float determinant =    +A._m00*(A._m11*A._m22-A._m21*A._m12)
                        -A._m01*(A._m10*A._m22-A._m12*A._m20)
                        +A._m02*(A._m10*A._m21-A._m11*A._m20);
	float invdet = 1/determinant;
	float3x3 r = 0;
	r._m00 =  (A._m11*A._m22-A._m21*A._m12)*invdet;
	r._m10 = -(A._m01*A._m22-A._m02*A._m21)*invdet;
	r._m20 =  (A._m01*A._m12-A._m02*A._m11)*invdet;
	r._m01 = -(A._m10*A._m22-A._m12*A._m20)*invdet;
	r._m11 =  (A._m00*A._m22-A._m02*A._m20)*invdet;
	r._m21 = -(A._m00*A._m12-A._m10*A._m02)*invdet;
	r._m02 =  (A._m10*A._m21-A._m20*A._m11)*invdet;
	r._m12 = -(A._m00*A._m21-A._m20*A._m01)*invdet;
	r._m22 =  (A._m00*A._m11-A._m10*A._m01)*invdet;
	return r;
}

PS_IN VSI( VSS_IN input, I_IN inst ) 
{
	PS_IN output = (PS_IN)0;
	if(SkinningEnabled)
	{
		Skin(input.pos,input.norm,input.wts,input.inds);
	}
	float4x4 InstWorld = mul(inst.transform,World);
	float4 wpos = mul(input.pos,InstWorld);
	float4x4 VP =mul(View,Projection);
	
	float3x3 nworld = (float3x3)(InstWorld);
	nworld = MInv(nworld);
	
	output.pos =  mul(wpos,VP);
	output.wpos = wpos.xyz;
	output.norm = normalize(mul(input.norm,nworld)); 
	output.bnorm = normalize(mul(input.bnorm,nworld)); 
	output.tnorm = normalize(mul(input.tnorm,nworld)); 
	output.tcrd = input.tcrd;
	output.color = input.color*Color;//((float3)input.inds.xyz);
	output.spos =  
		g_MeshTexture_g.SampleLevel(MeshTextureSampler,input.tcrd,0) 
		* g_MeshTexture_x.SampleLevel(MeshTextureSampler,input.tcrd,0)
		;//mul(wpos,transpose(View)); 

    float3 ambmapEnv = mul(float4(output.norm,1),EnvInverse).xyz;
    output.ambmap =saturate(EnvSampleLevel(ambmapEnv,0));

	return output;
}
PS_IN VS( VSS_IN input) 
{
	PS_IN output = (PS_IN)0;
	if(SkinningEnabled)
	{
		Skin(input.pos,input.norm,input.wts,input.inds);
	} 
	float4 wpos = mul(input.pos,World);
	float4x4 VP =mul(View,Projection);
	
	float3x3 nworld = (float3x3)(World);
	nworld = MInv(nworld);
	
	output.pos = wpos;// mul(wpos,VP);
	output.wpos = wpos.xyz;
	output.norm = normalize(mul(input.norm,nworld)); 
	output.bnorm = normalize(mul(input.bnorm,nworld)); 
	output.tnorm = normalize(mul(input.tnorm,nworld)); 
	output.tcrd = input.tcrd; 
	output.color = input.color*tint*Color;//((float3)input.inds.xyz);
	output.spos = mul(wpos,View);
	
    float3 ambmapEnv = mul(float4(output.norm,1),EnvInverse).xyz;
    output.ambmap =saturate(EnvSampleLevel(ambmapEnv,0));

	return output;
}
PS_IN VSIC( VSS_IN input, IC_IN inst ) 
{
	PS_IN output = (PS_IN)0;
	if(SkinningEnabled)
	{
		Skin(input.pos,input.norm,input.wts,input.inds);
	}
	float4x4 InstWorld = mul(inst.transform,World);
	float4 wpos = mul(input.pos,InstWorld);
	float4x4 VP =mul(View,Projection);
	
	float3x3 nworld = (float3x3)(InstWorld);
	nworld = MInv(nworld);
	
	output.pos = wpos;// mul(wpos,VP);
	output.wpos = wpos.xyz;
	output.norm = normalize(mul(input.norm,nworld)); 
	output.bnorm = normalize(mul(input.bnorm,nworld)); 
	output.tnorm = normalize(mul(input.tnorm,nworld)); 
	output.tcrd = input.tcrd; 
	output.color = input.color*inst.color.xyz*tint*Color;//((float3)input.inds.xyz);
	//output.spos = mul(wpos,transpose(View)); 
	output.spos =  
		g_MeshTexture_g.SampleLevel(MeshTextureSampler,input.tcrd,0)
		* g_MeshTexture_x.SampleLevel(MeshTextureSampler,input.tcrd,0)
		;//mul(wpos,transpose(View)); 
		
    float3 ambmapEnv = mul(float4(output.norm,1),EnvInverse).xyz;
    output.ambmap =saturate(EnvSampleLevel(ambmapEnv,0));

	return output;
}
PS_IN VSIM( VSS_IN input, MORPH_IN morph ) 
{ 
	PS_IN output = (PS_IN)0;
	input.pos = float4(input.pos.xyz+ morph.pos.xyz,input.pos.w);
	input.norm = normalize(input.norm+morph.norm);
	//input.bnorm = morph.bnorm;
	//input.tnorm = morph.tnorm;
	
	if(SkinningEnabled)
	{ 
		Skin(input.pos,input.norm,input.wts,input.inds);
	} 
	float4 wpos = mul(input.pos,World);
	float4x4 VP =mul(View,Projection); 
	float3x3 nworld = (float3x3)(World);
	nworld = MInv(nworld);
	
	output.pos = wpos; mul(wpos,VP);
	output.wpos = wpos.xyz;
	output.norm = normalize(mul(input.norm,nworld)); 
	output.bnorm = normalize(mul(input.bnorm,nworld)); 
	output.tnorm = normalize(mul(input.tnorm,nworld)); 
	output.tcrd = input.tcrd; 
	output.color = input.color*tint*Color;//((float3)input.inds.xyz);
	//output.spos = mul(wpos,transpose(View));
	output.spos =  
		g_MeshTexture_g.SampleLevel(MeshTextureSampler,input.tcrd,0)
		* g_MeshTexture_x.SampleLevel(MeshTextureSampler,input.tcrd,0)
		;//mul(wpos,transpose(View)); 
		
    float3 ambmapEnv = mul(float4(output.norm,1),EnvInverse).xyz;
    output.ambmap =saturate(EnvSampleLevel(ambmapEnv,0));

	return output;
}




/*
void Plane( inout TriangleStream<PS_IN> TriStream,float4x4 mx, float3 p1,float3 p2,float3 p3,float3 p4)
{ 
    PS_IN outputA=(PS_IN)0;
    PS_IN outputB=(PS_IN)0;
    PS_IN outputC=(PS_IN)0;
    PS_IN outputD=(PS_IN)0;
	float3 N =normalize( cross(p1-p2,p1-p3));
	
	outputA.pos =   mul(float4(p1,1),mx);
	outputA.norm = N;
	outputA.tcrd = float4(0,0,0,0);
	outputB.pos =  mul(float4(p2,1),mx);
	outputB.norm = N;
	outputB.tcrd = float4(0,0,0,0);
	outputC.pos =  mul(float4(p3,1),mx);
	outputC.norm = N;
	outputC.tcrd = float4(0,0,0,0);
	outputD.pos =  mul(float4(p4,1),mx);
	outputD.norm = N;
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
[maxvertexcount(3+3)]//+3
void GSScene( triangle PS_IN input[3], inout TriangleStream<PS_IN> OutputStream )
{   
    PS_IN output = (PS_IN)0;
	float4x4 mx =mul(transpose(View) ,	transpose(Projection));
	
	float3 pos1 = input[0].pos;
	float3 pos2 = input[1].pos;
	float3 pos3 = input[2].pos;

	input[0].pos = mul( input[0].pos  ,mx);
	input[1].pos = mul( input[1].pos  ,mx);
	input[2].pos = mul( input[2].pos  ,mx);
	OutputStream.Append( input[0] );
	OutputStream.Append( input[1] );
	OutputStream.Append( input[2] ); 
	OutputStream.RestartStrip();
    if(outline>0)
	{
		float w =outline* 0.000002*0.2; 
		float3 c = float3(1,1,1)*0;
		input[0].pos = mul(float4(pos1+input[0].norm.xyz*w,1),mx);
		input[1].pos = mul(float4(pos2+input[1].norm.xyz*w,1),mx);
		input[2].pos = mul(float4(pos3+input[2].norm.xyz*w,1),mx);
		input[0].color = c;
		input[1].color = c;
		input[2].color = c;
		OutputStream.Append( input[2] ); 
		OutputStream.Append( input[1] );
		OutputStream.Append( input[0] );
		OutputStream.RestartStrip();
	}
}
*/


[maxvertexcount(3+3*10)]//+3
void GSSceneFUR( triangle PS_IN input[3], inout TriangleStream<PS_IN> OutputStream )
{   
    PS_IN output = (PS_IN)0;
	float4x4 mx =mul(View,	Projection);
	
	float3 pos1 = input[0].pos;
	float3 pos2 = input[1].pos;
	float3 pos3 = input[2].pos;

	input[0].pos = mul( input[0].pos  ,mx);
	input[1].pos = mul( input[1].pos  ,mx);
	input[2].pos = mul( input[2].pos  ,mx);
	OutputStream.Append( input[0] );
	OutputStream.Append( input[1] );
	OutputStream.Append( input[2] ); 
	OutputStream.RestartStrip();

	if(_DrawGSFur && furLen>0)
	{//0.000001*
		float wl =  0.001*furLen/distanceMultiplier;
		[unroll]
		for (int x = 1; x < 10; x++)
		{
			float w =x*wl;  
			input[0].pos = mul(float4(pos1+input[0].norm.xyz*w*input[0].spos.x,1),mx);
			input[1].pos = mul(float4(pos2+input[1].norm.xyz*w*input[1].spos.x,1),mx);
			input[2].pos = mul(float4(pos3+input[2].norm.xyz*w*input[2].spos.x,1),mx); 
			input[0].layer = x;
			input[1].layer = x;
			input[2].layer = x; 
			OutputStream.Append( input[0] );
			OutputStream.Append( input[1] );
			OutputStream.Append( input[2] ); 
			OutputStream.RestartStrip();
		} 
	}
	else if(outline>0)
	{
		float w =outline* 0.000002*0.2; 
		float3 c = float3(1,1,1)*0;
		input[0].pos = mul(float4(pos1+input[0].norm.xyz*w,1),mx);
		input[1].pos = mul(float4(pos2+input[1].norm.xyz*w,1),mx);
		input[2].pos = mul(float4(pos3+input[2].norm.xyz*w,1),mx);
		input[0].color = c;
		input[1].color = c;
		input[2].color = c;
		OutputStream.Append( input[2] ); 
		OutputStream.Append( input[1] );
		OutputStream.Append( input[0] );
		OutputStream.RestartStrip();
	}
}









float4 SampleDetailIntensity(float2 tcoord)
{ 
	float4 result = float4( 
		g_MeshTexture_m.Sample(MeshTextureSampler, tcoord/4).a,
		g_MeshTexture_m.Sample(MeshTextureSampler, tcoord/4+float2(0.5,0)).a,
		g_MeshTexture_m.Sample(MeshTextureSampler, tcoord/4+float2(0,0.5)).a,
		g_MeshTexture_m.Sample(MeshTextureSampler, tcoord/4+float2(0.5,0.5)).a);
}





const float near = 0.001; // projection matrix's near plane
const float far = 1.0; // projection matrix's far plane
float LinearizeDepth(float depth)
{
    float z = depth * 2.0 - 1.0; // back to NDC 
    return (2.0 * near * far) / (far + near - z * (far - near));    
}

PS_OUT PS_CHEAP( PS_IN input ) : SV_Target
{ 
	PS_OUT output = (PS_OUT)0;
	
	output.depth = 0;
	output.normal = float4(1,1,1,1);
	output.diffuse =0;
	output.light =0;
	
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
		output.light = envmap;
		output.diffuse =output.light;
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
			output.diffuse = g_MeshTexture.Sample(MeshTextureSampler, texCoord) ;
		}
		else
		{
		}
	}
	
	return output;
}

float isDithered(float2 pos, float alpha) { 
 
    float DITHER_THRESHOLDS[16] =
    {
        1.0 / 17.0,  9.0 / 17.0,  3.0 / 17.0, 11.0 / 17.0,
        13.0 / 17.0,  5.0 / 17.0, 15.0 / 17.0,  7.0 / 17.0,
        4.0 / 17.0, 12.0 / 17.0,  2.0 / 17.0, 10.0 / 17.0,
        16.0 / 17.0,  8.0 / 17.0, 14.0 / 17.0,  6.0 / 17.0
    };

    int index = (int(pos.x) % 4) * 4 + int(pos.y) % 4;
    return alpha - DITHER_THRESHOLDS[index];
}

float rand_1_05(in float2 uv)
{
    float2 noise = (frac(sin(dot(uv ,float2(12.9898,78.233)*2.0)) * 43758.5453));
    return abs(noise.x + noise.y) * 0.5;
}

void MaskAdd(inout float4 mask, float4 map,float4 mix)
{ 
	if(map.a!=0 || map.r!=0|| map.g!=0|| map.b!=0)
	{
		mask += map*mix; 
	} 
}

float Fresnel2(float cangle)
{
	if (cangle <0.5)
	{
		return freshnelRanges.z*(1-cangle*2) + freshnelRanges.y*(cangle*2);
	}
	else
	{	
		return freshnelRanges.y*(1-(cangle*2-1)) + freshnelRanges.x*(cangle*2-1);
	}
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
    output.depth = input.pos.z;///input.pos.w;
	output.diffuse =0;
	output.light =0;
	output.stencil = stencil;
	//output.diffuse = float4(input.spos,1);
	//return output;
	//output.diffuse=float4(1,1,1,1);
	//output.normal = float4(input.norm/2+float3(0.5,0.5,0.5),1);
	//return output;
	//input.pos.w;///input.pos.w;//float4(input.pos.z/input.pos.w,0,0,1);//*input.pos.w
	//return output;
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
		float3 envdir = mul(float4(input.wpos,1),  transpose(WorldInv)).xyz;
		float3 envmap =// EnvSampleLevel(envdir,1);// 
			g_SkyTexture.SampleLevel(MeshTextureSampler,envdir,0);
		output.light = float4(pow(envmap,pow_skybox_mul)*TBrightness,1);
		output.diffuse =output.light;
		output.mask = 0;
	}
	else if(!FullbrightMode)
	{
		float4 bumpMap = g_MeshTexture_n.Sample(MeshTextureSampler, texCoord);
		
		
		float4 detailmap = g_MeshTexture_s.Sample(MeshTextureSampler, texCoord);//) ;	
		float blendd =1-detailmap.x; 

		if (DetailEnabled&&!detail_nonormal) 
		{	
			if (detailblend>0)
			{
				float4 detbumpMap = g_DetailTexture_n.Sample(MeshTextureSampler, texCoord*detailscale);
				bumpMap = lerp(bumpMap, detbumpMap,detailblendfactor*blendd);
				//bumpMap = bumpMap+detbumpMap*detailblendfactor;
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
		
		float4 _mask = float4(base_specular_intencity,base_specular_rim_intencity,base_specular_tint,base_subsurface_intencity);
		float4 _mask_mix = float4(mul_specular_intencity,mul_specular_rim_intencity,mul_specular_tint,mul_subsurface_intencity);
		MaskAdd(_mask,g_MeshTexture_m.Sample(MeshTextureSampler, texCoord),_mask_mix); 


		if (DetailEnabled) 
		{	
			if (detailblend>0)
			{ 
				MaskAdd(_mask,g_DetailTexture_m.Sample(MeshTextureSampler, texCoord*detailscale),_mask_mix); 
			}
		}
 
		 
		float3 camdir = normalize(input.wpos);
		
		float4 emissiveMap = g_MeshTexture_e.Sample(MeshTextureSampler, texCoord);
		
		float emissionMul = 1;
		if(rimfadeEmission.x<0) 
		{
			emissionMul = 1-lerp(1,pow(saturate(dot(input.norm,-camdir)),rimfadeEmission.y),-rimfadeEmission.x);
		}
		else
		{
			emissionMul = lerp(1,pow(saturate(dot(input.norm,-camdir)),rimfadeEmission.y),rimfadeEmission.x);
		}
		float3 emissive = emissiveMap.rgb*emissionTint*mul_emissive_intencity*emissionMul;
			;//*input.color;
		
		float3 diffuse = float3(1,1,1);
		  
		float3 reflectcam = reflect(camdir,input.norm);

		float ViewDot = saturate(dot(-normalize(camdir),input.norm));
		float fren = Fresnel2(ViewDot);
		
		output.mask.x = fren;//saturate(1-pow(ViewDot,4));//lpower
		output.mask.y = _mask.x;//smoothness
		output.mask.z = _mask.z;//metalness
		output.mask.w = _mask.w;//subsurface
		    
		float alpha = 1;
		if(TextureEnabled)
		{
			float4 texIn = g_MeshTexture.Sample(MeshTextureSampler, texCoord) ;//* saturate(1-fTotalSum*10);//(0.5 < fTotalSum?0:1);
			float4 tMatMasks = 1;
			if (matMasksEnabled) 
			{
				tMatMasks = g_MeshTexture_f.Sample(MeshTextureSampler,texCoord);
			} 
			diffuse *= texIn.rgb * input.color * (
					  tMatMasks.r * (matColors0.rgb/matColors0.a)
					+ tMatMasks.g * (matColors1.rgb/matColors1.a) 
					+ tMatMasks.b * (matColors2.rgb/matColors2.a) 
					+ tMatMasks.a * (matColors3.rgb/matColors3.a));//

			




			alpha =  texIn.a;
			
			if (DetailEnabled) 
			{	
				if (detailblend>0)
				{
					float4 dtexIn = g_DetailTexture.Sample(MeshTextureSampler, 
						texCoord*detailscale+furShift*input.layer);//) ;	
					//0-mul
					//1-add
					//2-replace
					if(detailblendmode ==0)
					{
						dtexIn = (dtexIn-0.5)*detailblendfactor*blendd+1;
						diffuse = diffuse * dtexIn.rgb;
						emissive *= dtexIn.rgb; 
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
					else if(detailblendmode ==3)
					{
						emissive *= dtexIn.rgb; 
					}

					if(furLen>0)
					{ 
						//clip(detailmap.x-0.5);
						if(sMasksEnabled)
						{
							if(detailmap.x>0.001)
							{
								clip(0.1-input.layer);
							}
							else
							{
								clip(dtexIn-input.layer/11 );//13
							}
						}
						else
						{
							clip(dtexIn-input.layer/11 );//13
						}
					}
				}
			}
			if(alphatest)
			{ 
				clip(alpha-alphatestreference); 
			}
		}
		else 
		{
			diffuse.xyz *= input.color;
		}
		
		
		float3 reflectcolor = lerp(float3(1,1,1),normalize(diffuse.xyz),_mask.x);
		
		
		float rimlight = pow(saturate(1-dot(input.norm,-camdir)),10);
		 
		 
		//float3 ambmapEnv =  mul(float4(input.norm,1),EnvInverse).xyz;
		float3 ambmap =input.ambmap;//saturate(EnvSampleLevel(ambmapEnv,0));

		float3 reflectEnv =  mul(float4(reflectcam,1),EnvInverse).xyz;
		float3 envmap = saturate(EnvSampleLevel(reflectEnv,_mask.x));

		float ao_mul = 1;
		if(ao_enabled){
			ao_mul = g_MeshTexture_a.Sample(MeshTextureSampler, texCoord).r ; 
		}

		emissive+=
		lerp(
			diffuse*ambmap,
			lerp(envmap,diffuse*envmap, _mask.z),
			_mask.y)*fren*ao_mul;
		//emissive = ao_mul*float3(1,1,1);
		//emissive+=diffuse*ambmap*1+ lerp(envmap,diffuse*envmap, _mask.z)*0.5*_mask.x;
		float3 result = diffuse;
		output.light = float4(emissive,1);
		 
		if (rimfade )  
		{
			float3 camdir = normalize(input.wpos);
			float frontalblend = pow(saturate(dot(input.norm*5,-camdir)),1);
			TBrightness*=saturate(frontalblend);
		}
		if (!isfinite(result.x)) result = float3(0,0,0);//float3(1,0,1)*10;
		output.diffuse = float4(result,alpha);
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
			output.light = float4(input.color*texIn.rgb*TBrightness,texIn.a*TBrightness);
			output.diffuse = float4(input.color*texIn.rgb,texIn.a);
		}
		else
		{ 
			output.light = float4(input.color*TBrightness,TBrightness);
			output.diffuse = float4(input.color,1);
		}
		output.mask = float4(0,0,0,1);
	}
	float3x3 VP =(float3x3) mul(View,Projection);
	float3 vv = mul(input.norm,VP);
	float3 rer = normalize(input.norm);//vv.xyz);
	output.normal = float4(rer.x/2+0.5,rer.y/2+0.5,rer.z/2+0.5,1); 
	
	if(noiseclip)
	{
		float noised = g_NoiseTexture.Sample(MeshTextureSampler, texCoord).x;
		clip(noised*noiseclipmul-noiseclipedge);
	}
	
	return output;
}


DCI_PS_IN CI_VSI( VSS_IN input, IC_IN inst ) 
{
	DCI_PS_IN output = (DCI_PS_IN)0;
	if(SkinningEnabled)
	{
		Skin(input.pos,input.norm,input.wts,input.inds);
	}
	float4x4 InstWorld = mul(inst.transform,World);
	float4 wpos = mul(input.pos,InstWorld);
	float4x4 VP =mul(View,Projection);
	
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







float4x4 Cascade0VP;
float4x4 Cascade1VP;
float4x4 Cascade2VP;

struct DCI_C3
{ 
	float4 pos : SV_POSITION;  
	float2 tcrd : TEXCOORD0;   
	int layer : TEXCOORD1;
};

DCI_C3 SHADOW_C3_VSI( VSS_IN input, IC_IN inst ) 
{
	DCI_C3 output = (DCI_C3)0;
	if(SkinningEnabled)
	{
		Skin(input.pos,input.norm,input.wts,input.inds);
	}
	float4x4 InstWorld = mul(inst.transform,World);
	float4 wpos = mul(input.pos,InstWorld);
	 
	 
	output.pos =  wpos; 
	output.tcrd = input.tcrd;
	return output;
}

[maxvertexcount(3)]
void SHADOW_C3_GS( triangle DCI_C3 input[3], inout TriangleStream<DCI_C3> OutputStream )
{   
    DCI_C3 output = (DCI_C3)0;
	float4x4 c0mx =mul(View,Projection);// transpose(Cascade0VP);
	float4x4 c1mx = transpose(Cascade1VP);
	float4x4 c2mx = transpose(Cascade2VP);
	
	float3 pos1 = input[0].pos;
	float3 pos2 = input[1].pos;
	float3 pos3 = input[2].pos;

	input[0].pos = mul( pos1,c0mx);
	input[1].pos = mul( pos2,c0mx);
	input[2].pos = mul( pos3,c0mx);
	input[0].layer = 0;
	input[1].layer = 0;
	input[2].layer = 0;
	OutputStream.Append( input[0] );
	OutputStream.Append( input[1] );
	OutputStream.Append( input[2] ); 
	OutputStream.RestartStrip();

//input[0].pos = mul( pos1,c1mx);
//input[1].pos = mul( pos2,c1mx);
//input[2].pos = mul( pos3,c1mx);
//input[0].layer = 1;
//input[1].layer = 1;
//input[2].layer = 1;
//OutputStream.Append( input[0] );
//OutputStream.Append( input[1] );
//OutputStream.Append( input[2] ); 
//OutputStream.RestartStrip();
//
//input[0].pos = mul( pos1,c2mx);
//input[1].pos = mul( pos2,c2mx);
//input[2].pos = mul( pos3,c2mx); 
//input[0].layer = 2;
//input[1].layer = 2;
//input[2].layer = 2;
//OutputStream.Append( input[0] );
//OutputStream.Append( input[1] );
//OutputStream.Append( input[2] ); 
//OutputStream.RestartStrip();
 
}
struct SHADOWC3_PS_OUT
{
    float cascade0: SV_Target0; 
    float cascade1: SV_Target1; 
    float cascade2: SV_Target2; 
};
 
SHADOWC3_PS_OUT SHADOW_C3_PS( DCI_C3 input )  
{  
    SHADOWC3_PS_OUT output = (SHADOWC3_PS_OUT)0;
	float dp = input.pos.z*input.pos.w;
	if(SkyboxMode) 
	{
	 	clip(-1); 
	}
	else if(TextureEnabled && alphatest)
	{
		float4 texIn = g_MeshTexture.Sample(MeshTextureSampler, input.tcrd) ;   
		clip(texIn.a-alphatestreference); 
	}
		output.cascade0 = dp;
//if(input.layer==0)
//{
//	output.cascade0 = dp;
//}
//else if(input.layer==1)
//{
//	output.cascade1 = dp;
//}
//else // if(input.layer==2)
//{
//	output.cascade2 = dp;
//}
	
	return output;//-0.001f; 
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
		clip(texIn.a-alphatestreference); 
	}
	return dp;//-0.001f; 
}











float depth_mul = 1;
float depth_divider = 256;

float depth_shadow_bendadd = 1;



float3 DepthEncode(float depth)
{
	depth = depth * depth_mul;
	float3 result = float3((depth*depth_divider*depth_divider)%1,depth,depth);
	result.y = ((depth*depth_divider*depth_divider - result.x)/depth_divider)%1;
	result.z = (((depth*depth_divider*depth_divider - result.x)/depth_divider-result.y)/depth_divider)%1;
	
	return result;
}
float DepthDecode(float3 depth)
{
	return (depth.x/depth_divider/depth_divider+depth.y/depth_divider+depth.z)/depth_mul;
}

float4 SHADOW_PS_COLOR( DCI_PS_IN input ) : SV_Target
{  
	float dp = input.pos.z*input.pos.w; 
	if(TextureEnabled && alphatest)
	{
		float4 texIn = g_MeshTexture.Sample(MeshTextureSampler, input.tcrd) ;   
		clip(texIn.a-alphatestreference); 
	}
	return float4(DepthEncode(dp),1); //
}
technique10 Instanced
{
	pass P0
	{
		SetVertexShader( CompileShader( vs_4_0, VSIC() ) );
		SetGeometryShader(  CompileShader( gs_4_0, GSSceneFUR() )  );
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
		SetVertexShader( CompileShader( vs_4_0, VSIM() ) );
		SetGeometryShader(  CompileShader( gs_4_0, GSSceneFUR() )  );
		SetPixelShader( CompileShader( ps_4_0, PS() ) );
	}
}
technique10 Normal
{
	pass P0
	{
		SetVertexShader( CompileShader( vs_4_0, VS() ) );
		SetGeometryShader(  CompileShader( gs_4_0, GSSceneFUR() )  );
		SetPixelShader( CompileShader( ps_4_0, PS() ) );
	}
} 
technique10 shadow_cascade3
{
	pass P0
	{
		SetVertexShader( CompileShader( vs_4_0, SHADOW_C3_VSI() ) );
		SetGeometryShader( CompileShader( gs_4_0, SHADOW_C3_GS() )  );
		SetPixelShader( CompileShader( ps_4_0, SHADOW_C3_PS() ) );
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