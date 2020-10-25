float4x4 View;
float4x4 Projection;
float4x4 World;
 
SamplerState ts_Point { Filter = MIN_MAG_MIP_POINT; AddressU = Wrap; AddressV = Wrap; };
SamplerState ts_Aniso { Filter = ANISOTROPIC; AddressU = Wrap; AddressV = Wrap; };
 
Texture2DArray g_TextureData;
Texture2DArray g_ColorData;


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
    float3 Norm : TEXCOORD0;
    float2 Tex : TEXCOORD1;
	uint index : TEXCOORD2; 
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
	output.Pos = input.Pos + float4(inst.nw/129,0)+float4(0,1,0,1);
    

        
    float s0 =  g_TextureData.SampleLevel(ts_Point,float3(input.Tex,inst.index),0);

    float sx =  g_TextureData.SampleLevel(ts_Point,float3(input.Tex+float2(texdelta,0),inst.index),0);
    float sy =  g_TextureData.SampleLevel(ts_Point,float3(input.Tex+float2(0,texdelta),inst.index),0);
 
    //output.Pos = normalize(output.Pos) *(1+s0*0.1);
    output.Pos.y +=s0*0.1;
//	float3 px = input.Pos + float4(inst.nw/129,0)+float4(0,1,0,1);
//	float3 py = input.Pos + float4(inst.nw/129,0)+float4(0,1,0,1);
//
    float2 _step = float2(texdelta*2.5, 0.0);
    
    float3 va = normalize( float3(_step.xy, sx-s0) );
    float3 vb = normalize( float3(_step.yx, sy-s0) );



    //+sin(output.Pos.x*10)/10;
    //output.Pos.xyz = normalize(output.Pos.xyz)*0.2f;
    output.Pos.w =1;
	output.Tex = input.Tex;
	output.Norm =   cross(va,vb).rbg;//input.Norm;
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

   //float3 pn = cross(normalize(p1-p2),normalize(p1-p3));
	//outputA.Norm += pn;
	//outputB.Norm += pn;
	//outputC.Norm += pn;
	
	TriStream.Append(outputA);
	TriStream.Append(outputB);
	TriStream.Append(outputC);
    TriStream.RestartStrip();
}

PS_OUT PS( GSPS_INPUT input ) 
{ 
	PS_OUT output = (PS_OUT)0; 
    output.color =  g_TextureData.Sample(ts_Point,float3(input.Tex,input.index))*0.3+0.1f;
    output.normal =float4(input.Norm/2+0.5,1);//
    output.depth = input.Pos.z; 
    output.mask = float4(1,0,0,0); 
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