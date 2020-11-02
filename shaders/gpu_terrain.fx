float4x4 View;
float4x4 Projection;
float4x4 World;
 
SamplerState ts_Point { Filter = MIN_MAG_MIP_POINT; AddressU = Clamp; AddressV = Clamp; };
SamplerState ts_Aniso { Filter = ANISOTROPIC; AddressU = Wrap; AddressV = Wrap; };
 
Texture2DArray g_TextureData;
Texture2DArray g_ColorData;
Texture2DArray g_SurfaceTextures_d;
Texture2DArray g_SurfaceTextures_n;

struct VS_IN
{
	float4 Pos : POSITION; 
    float3 Norm : NORMAL0;
    float2 Tex : TEXCOORD0;
}; 
struct IS_IN
{
    float3 nw : POSITION1;
    float3 dx : POSITION2;
    float3 dy : POSITION3; 
	uint index : CINDEX; 
}; 


 
struct GSPS_INPUT
{
    float4 Pos : SV_POSITION;
    float2 Tex : TEXCOORD0;
	uint index : TEXCOORD1; 
    float3 Norm : TEXCOORD2;
    float3 Tnorm : TEXCOORD3;
    float3 Bnorm : TEXCOORD4;
    
    int3 tindex: INDC;
    float3 tweight: WGHT; 
    float updot : TEXCOORD5;
};

struct PS_OUT
{
    float4 emission: SV_Target0;
    float4 normal: SV_Target1; 
    float depth: SV_Target2;
    float4 mask: SV_Target3;
    float4 color : SV_Target4;
};


const float texdelta = 1.0/128;

GSPS_INPUT VS( VS_IN input, IS_IN inst) 
{
	GSPS_INPUT output = (GSPS_INPUT)0; 
	//output.Pos = input.Pos + float4(inst.nw/129,0)+float4(0,1,0,1);
    

        
    float s0 =  g_TextureData.SampleLevel(ts_Point,float3(input.Tex,inst.index),0);

    float sx =  g_TextureData.SampleLevel(ts_Point,float3(input.Tex+float2(texdelta,0),inst.index),0);
    float sy =  g_TextureData.SampleLevel(ts_Point,float3(input.Tex+float2(0,texdelta),inst.index),0);
 
    //output.Pos = normalize(output.Pos) *(1+s0*0.1);
    //normalize
    output.Pos = float4(   normalize (inst.nw + inst.dx * (1-input.Pos.z) + inst.dy * (input.Pos.x))*-(1+s0*0.1) ,1);//+float3(0,5,0)
   // output.Pos.y +=s0*0.1;
//	float3 px = input.Pos + float4(inst.nw/129,0)+float4(0,1,0,1);
//	float3 py = input.Pos + float4(inst.nw/129,0)+float4(0,1,0,1);
//

//  float3 dx1 = normalize(inst.nw + inst.dx*texdelta)*-(1+sx*0.1);
//  float3 dy1 = normalize(inst.nw + inst.dx*texdelta)*-(1+sy*0.1);
//  float3 va = normalize(output.Pos-dx1);
//  float3 vb = normalize(output.Pos-dy1);
//  float3 vc = cross(va,vb);

   //float2 _step = float2(texdelta*2.5, 0.0);
   //
   //float3 va = normalize( float3(_step.xy, sx-s0) );
   //float3 vb = normalize( float3(_step.yx, sy-s0) );


    output.tindex = s0*10; 
    output.tweight= 0; 

    //+sin(output.Pos.x*10)/10;
    //output.Pos.xyz = normalize(output.Pos.xyz)*0.2f;
    output.Pos.w =1;
	output.Tex = input.Tex;
    output.Norm =0;
//	output.Norm =  vc;//cross(va,vb).rbg;//input.Norm;
 //  output.Bnorm = -va;
 //  output.Tnorm = vb;
    output.updot =  saturate(pow(dot(normalize(output.Norm),float3(0,1,0)),20));
    output.index = inst.index;
	return output;
} 

[maxvertexcount(3)]
void GS( triangle GSPS_INPUT input[3], inout TriangleStream<GSPS_INPUT> TriStream )
{ 
    float4x4 ViewProjection = mul(View,Projection);
    GSPS_INPUT outputA=input[0];
    GSPS_INPUT outputB=input[1];
    GSPS_INPUT outputC=input[2];
	 
	float3 p1 = mul(outputA.Pos,World).xyz;
	float3 p2 = mul(outputB.Pos,World).xyz;
	float3 p3 = mul(outputC.Pos,World).xyz;
	

	outputA.Pos =  mul(float4(p1,1),ViewProjection);
	outputB.Pos =  mul(float4(p2,1),ViewProjection);
	outputC.Pos =  mul(float4(p3,1),ViewProjection); 

    float3 pn = cross(normalize(p1-p2),normalize(p1-p3));
	outputA.Norm += pn;
	outputB.Norm += pn;
	outputC.Norm += pn;
    
    //calc tiles
    int3 ids = float3(outputA.tindex.x,outputB.tindex.x,outputC.tindex.x);
    outputA.tweight = float3(1,0,0);
    outputB.tweight = float3(0,1,0);
    outputC.tweight = float3(0,0,1);
    
    outputA.tindex = ids; 
    outputB.tindex = ids; 
    outputC.tindex = ids;

	
	TriStream.Append(outputA);
	TriStream.Append(outputB);
	TriStream.Append(outputC);
    TriStream.RestartStrip();
}

PS_OUT PS( GSPS_INPUT input ) 
{ 
	PS_OUT output = (PS_OUT)0; 
    ///output.color =  g_TextureData.Sample(ts_Point,float3(input.Tex,input.index))*0.3+0.1f+0.1*float4(input.tindex,0);
   
    output.depth = input.Pos.z; 
    output.mask = float4(1,0,0,0); 
//return output;

    float dtTop = input.updot;
    float dtSide = 1-dtTop;

    int3 id = input.tindex;
    float3 weight = input.tweight;

    float2 tile_tex = input.Tex * 32;

    float4 color = 
        (lerp(
            g_SurfaceTextures_d.Sample(ts_Aniso,float3(tile_tex,id.x*2)),
            g_SurfaceTextures_d.Sample(ts_Aniso,float3(tile_tex,id.x*2+1)),dtSide) *weight.x
             
        +lerp(
            g_SurfaceTextures_d.Sample(ts_Aniso,float3(tile_tex,id.y*2)),
            g_SurfaceTextures_d.Sample(ts_Aniso,float3(tile_tex,id.y*2+1)),dtSide) *weight.y
            
        +lerp(
            g_SurfaceTextures_d.Sample(ts_Aniso,float3(tile_tex,id.z*2)),
            g_SurfaceTextures_d.Sample(ts_Aniso,float3(tile_tex,id.z*2+1)),dtSide) *weight.z 
        )/2
    ;
    
    float4  bump = 
        lerp(
            g_SurfaceTextures_n.Sample(ts_Aniso,float3(tile_tex,id.x*2)),
            g_SurfaceTextures_n.Sample(ts_Aniso,float3(tile_tex,id.x*2+1)),dtSide) *weight.x
             
        +lerp(
            g_SurfaceTextures_n.Sample(ts_Aniso,float3(tile_tex,id.y*2)),
            g_SurfaceTextures_n.Sample(ts_Aniso,float3(tile_tex,id.y*2+1)),dtSide) *weight.y
            
        +lerp(
            g_SurfaceTextures_n.Sample(ts_Aniso,float3(tile_tex,id.z*2)),
            g_SurfaceTextures_n.Sample(ts_Aniso,float3(tile_tex,id.z*2+1)),dtSide) *weight.z 
    ;
   // color = 0.2;
    output.color = color;
    output.emission = color*0.9;


    bump = bump*2-1;
    float3 bumpNormal = 
        - (bump.y * input.Tnorm) 
        - (bump.x * input.Bnorm) 
        + (bump.z * input.Norm);

    if(!isnan(bumpNormal.x))
    {
        input.Norm = normalize(bumpNormal); 
    }
    output.normal =float4(input.Norm/2+0.5,1);//



	return output; 
}

technique10 Render
{
	pass P0
	{
		SetGeometryShader( CompileShader( gs_4_0, GS() ) );
		SetVertexShader( CompileShader( vs_4_0, VS() ) );
		SetPixelShader( CompileShader( ps_4_0, PS() ) );
	}
}




float4 shadowVS( VS_IN input, IS_IN inst) : SV_POSITION
{ 
    float4x4 ViewProjection = mul(View,Projection);  
        
    float s0 =  g_TextureData.SampleLevel(ts_Point,float3(input.Tex,inst.index),0);  
	return mul(mul(float4(   normalize (inst.nw + inst.dx * (1-input.Pos.z) + inst.dy * (input.Pos.x))*-(1+s0*0.1) ,1),World),ViewProjection); 
} 
 
float shadowPS( float4 pos : SV_POSITION ) : SV_Target
{   
	return pos.z;  
}

technique10 Shadow
{
	pass P0
	{
		SetGeometryShader( 0 );
		SetVertexShader( CompileShader( vs_4_0, shadowVS() ) );
		SetPixelShader( CompileShader( ps_4_0, shadowPS() ) );
	}
}