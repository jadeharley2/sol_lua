float4x4 Projection;
float4x4 View;
float4x4 World;
float4x4 EnvInverse;

#include "headers/enviroment.fxh"
 

Texture2D NoiseTexture;
 

Texture2D MeshTexture_d;
Texture2D MeshTexture_n; 
Texture2D MeshTexture_m;



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

    int3 index: INDC;
    float3 weight: WGHT;  
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
    float updot : TEXCOORD6;
    
    int3 index: INDC;
    float3 weight: WGHT; 
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
	//float4x4 VP =mul(transpose(View),transpose(Projection));

	float4x4 InstWorld = mul(transpose(inst.transform),transpose(World));
	float3x3 nworld = (float3x3)(InstWorld);
	float4 wpos = mul(input.pos,InstWorld);

	output.pos =  wpos;// mul(wpos,VP);

	output.norm = normalize(mul(input.norm,nworld)); 
	output.bnorm = -normalize(mul(input.bnorm,nworld)); 
	output.tnorm = cross(output.norm,output.bnorm ); 

    output.index = input.index; 
    output.weight= input.weight;

	output.tcrd = input.tcrd;
    output.color = input.colr; 
    output.wpos = wpos;
    output.updot =  saturate(pow(dot(normalize(input.norm),float3(0,1,0)),20));
	return output; 
} 


PS_OUT PS( PS_IN input ) : SV_Target
{
    PS_OUT output = (PS_OUT)0;
    float4 noise = NoiseTexture.Sample(MeshTextureSampler,input.tcrd/4); 
    //(noise.xyz-float3(0.5,0.5,0.5))*0.1
    float dtTop = input.updot;
    float dtSide = 1-dtTop;
    


  

    int3 id = input.index;
    float3 weight = input.weight;
    
    float4 surfpar =saturate(  
          lerp(SurfaceParameters[id.x*2],SurfaceParameters[id.x*2+1], dtSide )* weight.x 
         +lerp(SurfaceParameters[id.y*2],SurfaceParameters[id.y*2+1], dtSide )* weight.y 
         +lerp(SurfaceParameters[id.z*2],SurfaceParameters[id.z*2+1], dtSide )* weight.z
    )
    ; 

    float4 color = 
       ( (lerp(
            SurfaceTextures_d.Sample(MeshTextureSampler,float3(input.tcrd,id.x*2)),
            SurfaceTextures_d.Sample(MeshTextureSampler,float3(input.tcrd,id.x*2+1)),dtSide) *weight.x
             
        +lerp(
            SurfaceTextures_d.Sample(MeshTextureSampler,float3(input.tcrd,id.y*2)),
            SurfaceTextures_d.Sample(MeshTextureSampler,float3(input.tcrd,id.y*2+1)),dtSide) *weight.y
            
        +lerp(
            SurfaceTextures_d.Sample(MeshTextureSampler,float3(input.tcrd,id.z*2)),
            SurfaceTextures_d.Sample(MeshTextureSampler,float3(input.tcrd,id.z*2+1)),dtSide) *weight.z 
        )
         +(lerp(
            SurfaceTextures_d.Sample(MeshTextureSampler,float3(input.tcrd/8,id.x*2)),
            SurfaceTextures_d.Sample(MeshTextureSampler,float3(input.tcrd/8,id.x*2+1)),dtSide) *weight.x
             
        +lerp(
            SurfaceTextures_d.Sample(MeshTextureSampler,float3(input.tcrd/8,id.y*2)),
            SurfaceTextures_d.Sample(MeshTextureSampler,float3(input.tcrd/8,id.y*2+1)),dtSide) *weight.y
            
        +lerp(
            SurfaceTextures_d.Sample(MeshTextureSampler,float3(input.tcrd/8,id.z*2)),
            SurfaceTextures_d.Sample(MeshTextureSampler,float3(input.tcrd/8,id.z*2+1)),dtSide) *weight.z 
        ))/2
    ;
    float4  bump = 
        lerp(
            SurfaceTextures_n.Sample(MeshTextureSampler,float3(input.tcrd,id.x*2)),
            SurfaceTextures_n.Sample(MeshTextureSampler,float3(input.tcrd,id.x*2+1)),dtSide) *weight.x
             
        +lerp(
            SurfaceTextures_n.Sample(MeshTextureSampler,float3(input.tcrd,id.y*2)),
            SurfaceTextures_n.Sample(MeshTextureSampler,float3(input.tcrd,id.y*2+1)),dtSide) *weight.y
            
        +lerp(
            SurfaceTextures_n.Sample(MeshTextureSampler,float3(input.tcrd,id.z*2)),
            SurfaceTextures_n.Sample(MeshTextureSampler,float3(input.tcrd,id.z*2+1)),dtSide) *weight.z 
    ;

    float4 mask = float4(1,1,1,1)
        //lerp(
        //    SurfaceTextures_m.Sample(MeshTextureSampler,float3(input.tcrd,id.x*2)),
        //    SurfaceTextures_m.Sample(MeshTextureSampler,float3(input.tcrd,id.x*2+1)),dtSide) *weight.x
        //     
        //+lerp(
        //    SurfaceTextures_m.Sample(MeshTextureSampler,float3(input.tcrd,id.y*2)),
        //    SurfaceTextures_m.Sample(MeshTextureSampler,float3(input.tcrd,id.y*2+1)),dtSide) *weight.y
        //    
        //+lerp(
        //    SurfaceTextures_m.Sample(MeshTextureSampler,float3(input.tcrd,id.z*2)),
        //    SurfaceTextures_m.Sample(MeshTextureSampler,float3(input.tcrd,id.z*2+1)),dtSide) *weight.z 
    ;
    //color = float4(id,1);
   // color = float4(weight,1);
    //color = float4(input.id0.a,input.id0.a,input.id0.a,1);
    //color = surfpar;
    bump = bump*2-1;
    float3 bumpNormal = 
        - (bump.y * input.tnorm) 
        - (bump.x * input.bnorm) 
        + (bump.z * input.norm);

    if(!isnan(bumpNormal.x))
    {
        input.norm = normalize(bumpNormal); 
    }
   // if(input.color.x>=0.99 && input.color.z>=0.99 && input.color.y<=0.01) clip(-1);

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
    output.diffuse = float4(input.color*color.xyz,1); //
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
		SetVertexShader( CompileShader( vs_4_0, VS() ) );
		SetGeometryShader(  CompileShader( gs_4_0, GS() )  );
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
	float dp = input.pos.z;//*input.pos.w; 
	return dp;//-0.001f; 
}



technique10 shadow
{
	pass P0
	{
		SetVertexShader( CompileShader( vs_4_0, CI_VSI() ) );
		SetGeometryShader( 0 );
		SetPixelShader( CompileShader( ps_4_0, SHADOW_PS_FLOAT() ) );
	}
}