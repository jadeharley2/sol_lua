float4x4 Projection;
float4x4 View;
float4x4 World;
 

SamplerState TextureSampler { Filter = ANISOTROPIC; AddressU = Wrap; AddressV = Wrap; };
 
Texture2D g_MeshTexture;

float time;

float2 timeShift;

float4 tint = float4(1,1,1,1);
  
 
struct VS_IN
{
	float4 Pos : POSITION; 
    float3 Norm : NORMAL0;
    float2 Tex : TEXCOORD0;
}; 


struct GSPS_INPUT
{
    float4 Pos : SV_POSITION;
    float3 Norm : TEXCOORD0;
    float2 Tex : TEXCOORD1;
};

struct PS_OUT
{
    float4 diffuse: SV_Target0; //rgba 
};
 


void Plane( inout TriangleStream<GSPS_INPUT> TriStream,float4x4 mx, float3 p1,float3 p2,float3 p3,float3 p4)
{ 
    GSPS_INPUT outputA;
    GSPS_INPUT outputB;
    GSPS_INPUT outputC;
    GSPS_INPUT outputD;
	float3 N =normalize( cross(p1-p2,p1-p3));
	
	outputA.Pos =  mul(float4(p1,1),mx);
	outputA.Norm = N;
	outputA.Tex = float2(1,1)+timeShift*time;
	outputB.Pos =  mul(float4(p2,1),mx);
	outputB.Norm = N;
	outputB.Tex = float2(1,0)+timeShift*time;
	outputC.Pos =  mul(float4(p3,1),mx);
	outputC.Norm = N;
	outputC.Tex = float2(0,1)+timeShift*time; 
	outputD.Pos =  mul(float4(p4,1),mx);
	outputD.Norm = N;
	outputD.Tex = float2(0,0)+timeShift*time; 
	
	TriStream.Append( outputA );
	TriStream.Append( outputB );
	TriStream.Append( outputC );
    TriStream.RestartStrip();
	
	TriStream.Append( outputC );
	TriStream.Append( outputB );
	TriStream.Append( outputD ); 
    TriStream.RestartStrip();
}

GSPS_INPUT VS( VS_IN input) 
{
	GSPS_INPUT output = (GSPS_INPUT)0;
	//float4x4 mx = mul(mul(transpose(World) ,	transpose(View)),	transpose(Projection));
	
	output.Pos = input.Pos;// mul(	input.Pos,		 mx); 
	output.Tex = input.Tex;
	output.Norm = input.Norm;
	return output;
} 

[maxvertexcount(64)]
void GS( triangle GSPS_INPUT input[3], inout TriangleStream<GSPS_INPUT> TriStream )
{
    GSPS_INPUT output;
	
	float4x4 tWorld = transpose(World);
	float4x4 tView = transpose(View);
	float4x4 mx = mul(tView,	transpose(Projection));
   
	
	float3 p1 = mul(input[0].Pos,tWorld).xyz;
	float3 p2 = mul(input[1].Pos,tWorld).xyz;
	float3 p3 = mul(input[2].Pos,tWorld).xyz;
	
	float3 w1 = input[0].Norm.xyz;
	float3 w2 = input[1].Norm.xyz;
	float3 w3 = input[2].Norm.xyz;
	
	float3 mid12 = (p2+p1)/2;
	float3 mid23 = (p3+p2)/2;
	if(w1.y!=0) mid12 = p1; 
	if(w3.y!=0) mid23 = p3; 
	
	float3 up = float3(1,0,0);  
	float3 camD = normalize(p1);
	float3 camD2 = normalize(p3);//tView._m00_m01_m02*float3(0.1,0.1,0.1);
	
	float w =0.01/4;
	
	float3 r2 = normalize(cross(p2-p1,camD))*(w1.x+w2.x)/2;
	float3 r3 = normalize(cross(p3-p2,camD2))*(w2.x+w3.x)/2;
	
	float3 r23 = normalize(r2+r3)*w2.x;
	                             
	
	float3 pc = (p1+p2+p3)/3  ; 
    
	  
	Plane(TriStream,mx, 
		mid12-r2, mid12+r2,
		p2-r23,p2+r23);
	Plane(TriStream,mx,
		p2-r23,p2+r23,
		mid23-r3,mid23+r3);
	//Plane(TriStream,mx, p2,p2+r2,p3,p3+r3);
	
	//output.Pos =mul(	  float4(pc+(p1-pc)*0.5,1),mx);
	//output.Norm = float4(1,0,0,1);
	//output.Tex = float2(0,0);
    //TriStream.Append( output );
	//
	//output.Pos =mul(	  float4(pc+(p2-pc)*0.5,1),mx);
    //TriStream.Append( output );
	//
	//output.Pos =mul(	 float4(pc+(p3-pc)*0.5,1),mx);
    //TriStream.Append( output );
	//
    // 
    //TriStream.RestartStrip();
	
	 
}

PS_OUT PS( GSPS_INPUT input ) 
{ 
	PS_OUT output = (PS_OUT)0;
	
	float4 texIn = g_MeshTexture.Sample(TextureSampler,input.Tex) ;
	
	output.diffuse =texIn*tint;// float4(0.5,0,0,1);
	clip(output.diffuse.a-0.5);
	output.diffuse.a=1; 
	return output;//float4(abs(input.Norm)*l,1);
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
