  
TextureCube g_input; 
SamplerState TSampler
{
    Filter = MIN_MAG_MIP_LINEAR;
    AddressU = Wrap;
    AddressV = Wrap;
};
 
struct VS_IN
{
	float4 pos : SV_POSITION; 
}; 

struct VS_OUT
{ 
	float4 pos : SV_POSITION; 
	uint index : SLICEINDEX;
};

struct PS_IN
{ 
	float4 pos : SV_POSITION; 
	uint index : SV_RenderTargetArrayIndex;
};


VS_OUT VS( VS_IN input) 
{
	VS_OUT output = (VS_OUT)0; 
	output.pos = float4(input.pos.xy*128-64,0,1); 
	output.index = input.pos.z;
	return output;
}

[maxvertexcount(3)]
void GS( triangle VS_OUT input[3] , inout TriangleStream<PS_IN> OutputStream) 
{  
	OutputStream.Append( input[0] );
	OutputStream.Append( input[1] );
	OutputStream.Append( input[2] ); 
	OutputStream.RestartStrip();  
}

float3 GetDir(float2 tcrd, float index)
{ 
	tcrd = tcrd*2-float2(1,1);
	if 			(index==0) return float3( 1,-tcrd.y,-tcrd.x);
	else if 	(index==1) return float3(-1,-tcrd.y, tcrd.x);
	else if 	(index==2) return float3(tcrd.x,  1,  tcrd.y);
	else if 	(index==3) return float3(tcrd.x, -1, -tcrd.y);
	else if 	(index==4) return float3( tcrd.x, -tcrd.y,  1);
	else  				   return float3(-tcrd.x, -tcrd.y, -1);
} 

float3x3 AngleAxis3x3(float angle, float3 axis)
{
    float c, s;
    sincos(angle, s, c);

    float t = 1 - c;
    float x = axis.x;
    float y = axis.y;
    float z = axis.z;

    return float3x3(
        t * x * x + c,      t * x * y - s * z,  t * x * z + s * y,
        t * x * y + s * z,  t * y * y + c,      t * y * z - s * x,
        t * x * z - s * y,  t * y * z + s * x,  t * z * z + c
    );
}
float3 Rotate(float3 dir, float ang, float3 axis)
{
	return mul(dir,AngleAxis3x3(ang,axis));
}

//stupid 'fluid'
//#define C(x) texture(iChannel0,(f+x)/iResolution.xy).xy
//#define L(b) for(vec2 a=S;a.x<-6.;b=sin(a++))
//void mainImage(out vec4 c, vec2 f)
//{ 
//    float2 p,q,S=vec2(-24,31),v;//=p=q=S-S;
//    L(p) L(q) v+=p*dot(C((p+q).yx*S),q);
//    c.xy=C(v)+.02/(f-1.);
//}

float4 PS( PS_IN input ) : SV_Target
{ 
	float3 d = GetDir(input.pos.xy/128,input.index);
	float4 rez = g_input.Sample(TSampler,d)
					+g_input.Sample(TSampler,Rotate(d,0.025,float3(0,1,0)))
					+g_input.Sample(TSampler,Rotate(d,0.05,float3(0,1,0)))
					+g_input.Sample(TSampler,Rotate(d,0.075,float3(0,1,0)))
					+g_input.Sample(TSampler,Rotate(d,0.1,float3(0,1,0)))
					
					+g_input.Sample(TSampler,Rotate(d,-0.025,float3(0,1,0)))
					+g_input.Sample(TSampler,Rotate(d,-0.05,float3(0,1,0)))
					+g_input.Sample(TSampler,Rotate(d,-0.075,float3(0,1,0)))
					+g_input.Sample(TSampler,Rotate(d,-0.1,float3(0,1,0)))
					;
	return rez/9;//float4(coord-float3(0.5,0.5,0.5),1);
}


technique10 Normal
{
	pass P0
	{
		SetGeometryShader( CompileShader( gs_4_0, GS() ) );
		SetVertexShader( CompileShader( vs_4_0, VS() ) );
		SetPixelShader( CompileShader( ps_4_0, PS() ) );
	}
} 