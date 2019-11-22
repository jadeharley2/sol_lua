float4x4 Projection;
float4x4 View;
float4x4 World;
float4x4 EnvInverse;

#include "headers/enviroment.fxh"

//arrays
//Texture2DArray SurfaceTextures_d;    
//Texture2DArray SurfaceTextures_n;    
//Texture2DArray SurfaceTextures_m;  

Texture2D NoiseTexture;

Texture2D SurfaceTexture_01_d;

Texture2D SurfaceTextures2_d[16];
Texture2D SurfaceTextures2_n[16]; 
Texture2D SurfaceTextures2_m[16];

float4 SurfaceParameters[16];

SamplerState MeshTextureSampler
{
    Filter = MIN_MAG_MIP_LINEAR;
    AddressU = Wrap;
    AddressV = Wrap;
};


struct VS_IN
{
	float4 pos : POSITION;
	float2 tcrd : TEXCOORD;
    float3 norm : NORMAL;
    float3 bnorm : BINORMAL;
    float3 colr : COLOR0;
    half4 id0: INDC0;
    half4 id1: INDC1;
    half4 id2: INDC2;
    half4 id3: INDC3;
};
struct I_IN
{
	float4x4 transform : WORLD; 
	float4 color : COLOR1;
};
 
struct PS_IN
{ 
	float4 pos : SV_POSITION;
	float2 tcrd : TEXCOORD0;
    float3 norm : TEXCOORD1;
    float3 bnorm : TEXCOORD2; 
    float3 tnorm : TANGENT; 
    float3 color : TEXCOORD4; 
    float3 wpos : TEXCOORD5; 
    half4 id0: INDC0;
    half4 id1: INDC1;
    half4 id2: INDC2;
    half4 id3: INDC3;
};

struct PS_OUT
{
    float4 light: SV_Target0;
    float4 normal: SV_Target1; 
    float depth: SV_Target2;
    float4 mask: SV_Target3;// r - deferred_intensity, g - smootheness, b - metallness, a - subsurface_scattering_transparency
    float4 diffuse: SV_Target4; 
	//float stencil : SV_StencilRef; 
};


PS_IN VS( VS_IN input, I_IN inst ) 
{
	PS_IN output = (PS_IN)0;
	float4x4 VP =mul(transpose(View),transpose(Projection));

	float4x4 InstWorld = mul(transpose(inst.transform),transpose(World));
	float3x3 nworld = (float3x3)(InstWorld);
	float4 wpos = mul(input.pos,InstWorld);

	output.pos =  mul(wpos,VP);

	output.norm = normalize(mul(input.norm,nworld)); 
	output.bnorm = normalize(mul(input.bnorm,nworld)); 
	output.tnorm = cross(output.norm,output.bnorm ); 

    output.id0 = input.id0;
    output.id1 = input.id1;
    output.id2 = input.id2;
    output.id3 = input.id3;

	output.tcrd = input.tcrd;
    output.color = input.colr; 
    output.wpos = wpos;
	return output; 
} 

PS_OUT PS( PS_IN input ) : SV_Target
{
    PS_OUT output = (PS_OUT)0;
    float4 noise = NoiseTexture.Sample(MeshTextureSampler,input.tcrd/4);
    float4 id0 = input.id0;
    //(noise.xyz-float3(0.5,0.5,0.5))*0.1
    float dtTop = saturate(pow(dot(input.norm,float3(0,1,0)),20));
    float dtSide = 1-dtTop;
    float4 color = 
          SurfaceTextures2_d[0].Sample(MeshTextureSampler,input.tcrd)*id0.x*dtTop 
        + SurfaceTextures2_d[1].Sample(MeshTextureSampler,input.tcrd)*id0.x*dtSide 
        + SurfaceTextures2_d[2].Sample(MeshTextureSampler,input.tcrd)*id0.y*dtTop 
        + SurfaceTextures2_d[3].Sample(MeshTextureSampler,input.tcrd)*id0.y*dtSide 
        
        + SurfaceTextures2_d[4].Sample(MeshTextureSampler,input.tcrd)*input.id0.z*dtTop 
        + SurfaceTextures2_d[5].Sample(MeshTextureSampler,input.tcrd)*input.id0.z*dtSide 
        + SurfaceTextures2_d[6].Sample(MeshTextureSampler,input.tcrd)*input.id0.a*dtTop 
        + SurfaceTextures2_d[7].Sample(MeshTextureSampler,input.tcrd)*input.id0.a*dtSide 
        
        + SurfaceTextures2_d[8].Sample(MeshTextureSampler,input.tcrd) *input.id1.x*dtTop  
        + SurfaceTextures2_d[9].Sample(MeshTextureSampler,input.tcrd) *input.id1.x*dtSide  
        + SurfaceTextures2_d[10].Sample(MeshTextureSampler,input.tcrd)*input.id1.y*dtTop  
        + SurfaceTextures2_d[11].Sample(MeshTextureSampler,input.tcrd)*input.id1.y*dtSide  
        
        + SurfaceTextures2_d[12].Sample(MeshTextureSampler,input.tcrd)*input.id1.z*dtTop  
        + SurfaceTextures2_d[13].Sample(MeshTextureSampler,input.tcrd)*input.id1.z*dtSide  
        + SurfaceTextures2_d[14].Sample(MeshTextureSampler,input.tcrd)*input.id1.a*dtTop  
        + SurfaceTextures2_d[15].Sample(MeshTextureSampler,input.tcrd)*input.id1.a*dtSide  
        ;

    float4 bump = 
          SurfaceTextures2_n[0].Sample(MeshTextureSampler,input.tcrd)*input.id0.x*dtTop 
        + SurfaceTextures2_n[1].Sample(MeshTextureSampler,input.tcrd)*input.id0.x*dtSide
        + SurfaceTextures2_n[2].Sample(MeshTextureSampler,input.tcrd)*input.id0.y*dtTop 
        + SurfaceTextures2_n[3].Sample(MeshTextureSampler,input.tcrd)*input.id0.y*dtSide 
        
        + SurfaceTextures2_n[4].Sample(MeshTextureSampler,input.tcrd)*input.id0.z*dtTop 
        + SurfaceTextures2_n[5].Sample(MeshTextureSampler,input.tcrd)*input.id0.z*dtSide 
        + SurfaceTextures2_n[6].Sample(MeshTextureSampler,input.tcrd)*input.id0.a*dtTop 
        + SurfaceTextures2_n[7].Sample(MeshTextureSampler,input.tcrd)*input.id0.a*dtSide 
        
        + SurfaceTextures2_n[12].Sample(MeshTextureSampler,input.tcrd)*input.id1.z*dtTop  
        + SurfaceTextures2_n[13].Sample(MeshTextureSampler,input.tcrd)*input.id1.z*dtSide  
        + SurfaceTextures2_n[14].Sample(MeshTextureSampler,input.tcrd)*input.id1.a*dtTop  
        + SurfaceTextures2_n[15].Sample(MeshTextureSampler,input.tcrd)*input.id1.a*dtSide    
        ;

    float4 mask = 
          SurfaceTextures2_m[0].Sample(MeshTextureSampler,input.tcrd)*input.id0.x*dtTop 
        + SurfaceTextures2_m[1].Sample(MeshTextureSampler,input.tcrd)*input.id0.x*dtSide
        + SurfaceTextures2_m[2].Sample(MeshTextureSampler,input.tcrd)*input.id0.y*dtTop 
        + SurfaceTextures2_m[3].Sample(MeshTextureSampler,input.tcrd)*input.id0.y*dtSide 
        
        + SurfaceTextures2_m[4].Sample(MeshTextureSampler,input.tcrd)*input.id0.z*dtTop 
        + SurfaceTextures2_m[5].Sample(MeshTextureSampler,input.tcrd)*input.id0.z*dtSide 
        + SurfaceTextures2_m[6].Sample(MeshTextureSampler,input.tcrd)*input.id0.a*dtTop 
        + SurfaceTextures2_m[7].Sample(MeshTextureSampler,input.tcrd)*input.id0.a*dtSide 
        
        + SurfaceTextures2_m[12].Sample(MeshTextureSampler,input.tcrd)*input.id1.z*dtTop  
        + SurfaceTextures2_m[13].Sample(MeshTextureSampler,input.tcrd)*input.id1.z*dtSide  
        + SurfaceTextures2_m[14].Sample(MeshTextureSampler,input.tcrd)*input.id1.a*dtTop  
        + SurfaceTextures2_m[15].Sample(MeshTextureSampler,input.tcrd)*input.id1.a*dtSide    
        ;

    float4 surfpar = 
        SurfaceParameters[0]*input.id0.x*dtTop 
       +SurfaceParameters[1]*input.id0.x*dtSide 
       +SurfaceParameters[2]*input.id0.y*dtTop 
       +SurfaceParameters[3]*input.id0.y*dtSide 

       +SurfaceParameters[4]*input.id0.z*dtTop 
       +SurfaceParameters[5]*input.id0.z*dtSide 
       +SurfaceParameters[6]*input.id0.a*dtTop 
       +SurfaceParameters[7]*input.id0.a*dtSide 

       +SurfaceParameters[8] *input.id1.z*dtTop   
       +SurfaceParameters[9] *input.id1.z*dtSide  
       +SurfaceParameters[10]*input.id1.a*dtTop   
       +SurfaceParameters[11]*input.id1.a*dtSide 
        ;  
        
 
    bump = bump*2-1;
    float3 bumpNormal = 
        (bump.x * input.tnorm) 
        - (bump.y * input.bnorm) 
        + (bump.z * input.norm);

    if(!isnan(bumpNormal.x))
    {
        input.norm = normalize(bumpNormal); 
    }

	float3 normal = (input.norm); 
    output.depth = input.pos.z; 
	output.mask = float4(1,surfpar.x*mask.x,surfpar.y*mask.y,surfpar.z*mask.z);

    float3 ambmapEnv = mul(float4(normal,1),EnvInverse).xyz;
    float3 ambmap =saturate(EnvSampleLevel(ambmapEnv,0));

    float3 camdir = input.wpos;
    float3 reflectcam = reflect(camdir,input.norm);
    float3 reflectEnv = mul(float4(reflectcam,1),EnvInverse).xyz;
    float3 envmap = saturate(EnvSampleLevel(reflectEnv,output.mask.x));

    output.normal = float4(normal.x/2+0.5,normal.y/2+0.5,normal.z/2+0.5,1); 
    output.diffuse = float4(input.color*color.xyz,1); 
    float3 emissive =  surfpar.a*output.diffuse*(1-mask.a);
    output.light = 
			float4(
                lerp(output.diffuse*ambmap,lerp(envmap,output.diffuse*envmap, output.mask.z),output.mask.y)
                 +emissive
            ,1)
           
            //float4(ambmap,1)*output.diffuse+float4(envmap,1)*output.diffuse
            ;
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


struct DCI_PS_IN
{ 
	float4 pos : SV_POSITION;   
	float3 wpos : TEXCOORD1; 
};


DCI_PS_IN CI_VSI( VS_IN input, I_IN inst ) 
{
	DCI_PS_IN output = (DCI_PS_IN)0; 
	float4x4 InstWorld = mul(transpose(inst.transform),transpose(World));
	float4 wpos = mul(input.pos,InstWorld);
	float4x4 VP =mul(transpose(View),transpose(Projection));
	
	float3x3 nworld = (float3x3)(InstWorld);
	
	output.wpos = wpos.xyz;
	output.pos =  mul(wpos,VP); 
 
	return output;
}

float SHADOW_PS_FLOAT( DCI_PS_IN input ) : SV_Target
{  
	float dp = input.pos.z*input.pos.w; 
	return dp;//-0.001f; 
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