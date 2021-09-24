float pad=1;

float4x4 Projection;
float4x4 View;
float4x4 World; 

float4x4 InvWVP;
float2 viewSize;
float3 camera_pos;

TextureCube tCubemap;   
Texture2D tDiffuseView;     
Texture2D tNormalView;     
Texture2D tDepthView;      
Texture2D tMaskView;   
    
float4 xmode=0;

float4 pad2=1;
float pad3=1;
float pad32233=1;
SamplerState sView
{
    Filter = MIN_MAG_MIP_LINEAR;//MIN_MAG_MIP_LINEAR;
    AddressU = Wrap;
    AddressV = Wrap;
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
struct PS_IN
{ 
	float4 pos : SV_POSITION; 
	float norm : TEXCOORD; 
	float3 wdp : TEXCOORD1; 
	float3 wdp2 : TEXCOORD2; 
    float view_direction:TEXCOORD3;
    
}; 
struct PS_OUT
{
    float4 light : SV_TARGET0;
    //float stencill : SV_STENCILREF;
};

float2 getUV(float4 pos)
{
    return pos.xy/viewSize;
}
float3 getNormal(float2 uv)
{
    return tNormalView.Sample(sView, uv) * 2.0 - 1.0;
}
float3 SS_GetPosition(float2 UV)
{
    float depth =  tDepthView.Sample(sView, UV).x;
    float4 position = 1.0f; 

    position.x = UV.x * 2.0f - 1.0f; 
    position.y = -(UV.y * 2.0f - 1.0f); 

    position.z = depth; 

    position = mul(position, InvWVP);  
 
    position /= position.w;

    return position.xyz;
}


PS_IN VS( VS_IN input ) 
{ 
	float4x4 VP =mul(View,Projection); 
	float4 wpos = mul(input.pos,World);

	PS_IN output = (PS_IN)0; 
	output.pos =  mul(wpos,VP); 
    float3 xnrm = mul(input.norm,(float3x3)World);
    output.wdp = input.pos;
    output.wdp2 = wpos.xyz;
    output.norm = dot(normalize(xnrm),(wpos.xyz)/output.wdp);
    output.view_direction = xnrm.x;
	return output;
} 

float3 bpcem (in float3 v, float3 Emax, float3 Emin, float3 Epos, float3 Pos)
{  
 
    // All calculations in worldspace
 
    float3 nrdir = normalize(v);
    float3 rbmax = (Emax - Pos)/nrdir;
    float3 rbmin = (Emin - Pos)/nrdir;
 
    float3 rbminmax;
    rbminmax.x = (nrdir.x>0.0)?rbmax.x:rbmin.x;
    rbminmax.y = (nrdir.y>0.0)?rbmax.y:rbmin.y;
    rbminmax.z = (nrdir.z>0.0)?rbmax.z:rbmin.z;    
    float fa = min(min(rbminmax.x, rbminmax.y), rbminmax.z);
 
 
    float3 posonbox = Pos + nrdir* fa; 
    return posonbox - Epos; 
}
PS_OUT PS_PBR( PS_IN input ) : SV_Target
{    
    PS_OUT result = (PS_OUT)0;
    float2 uv = getUV(input.pos); 
    float3 normal = getNormal(uv);
	float3 albedo = tDiffuseView.Sample(sView, uv);
    float4 mask  =  tMaskView.Sample(sView, uv);

    float lmod = mask.x; 
    float specular = mask.y; 
    float metalness = mask.z;
 
	float miplevel = (1-saturate(specular))*20;

    float3 ctex2 = tCubemap.SampleLevel(sView,normal,miplevel)*specular;
    ctex2 = lerp(ctex2,ctex2*albedo,metalness);
    //tCubemap.SampleLevel(sView,-input.wdp2,0);
    // tCubemap.SampleLevel(sView,input.wdp+float3(0,0,-0.5),0)*1; //float4(input.wdp.xyz,0);

    float cubedistance = saturate(1-abs(input.wdp.y));

    float Acdepth = input.pos.z;
    float Adepth =  tDepthView.Sample(sView, uv).x;  
    //float Adiff = saturate((Adepth-Acdepth)*1000)*1;
    float Adiff = saturate((Acdepth-Adepth)*1000)*1;

    result.light = float4(ctex2*saturate(Adiff),1);
    //result.light = float4(Adiff,0,1,1); 
    return result;

 
    
    float3 pos = SS_GetPosition(uv);
	float3 V = normalize(camera_pos-pos);
     

    float cdepth = input.pos.z;
    float depth =  tDepthView.Sample(sView, uv).x; 
    float3 reflRay = (reflect(V,normal)); 
    float3 corrected = bpcem(reflRay,float3(1,1,1),float3(-1,-1,-1),float3(0,0,0),camera_pos*200*float3(-1,1,-1));
    float3 ctex = tCubemap.SampleLevel(sView,corrected,miplevel)*specular;
    //float3 pos = SS_GetPosition(uv);
    float diff = saturate((depth-cdepth)*10000)*lmod;


    ctex = lerp(ctex,ctex*albedo,metalness);
    if(xmode.x>0.5){

        result.light =float4(ctex*diff,diff);
    }
    else
    {
        result.light = float4(0,0,0,1);
    }
    //result.light =float4(float3(1,1,1)*diff,diff);
   // result.light =1; 
    //result.stencill = 1; 
    return result;
}

technique10 Render
{
	pass P0
	{
		SetGeometryShader( 0 );
		SetVertexShader( CompileShader( vs_4_0, VS() ) );
		SetPixelShader( CompileShader( ps_4_0, PS_PBR() ) );
	}
}