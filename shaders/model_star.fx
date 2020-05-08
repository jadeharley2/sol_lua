
 
float4x4 Projection;
float4x4 View;
float4x4 World;
   
float4x4 EnvInverse;

float3 Color = float3(1,1,1)*0.9;

float global_scale=1; 
float hdrMultiplier=1;
float brightness=1;

float time =0;
float2 textureshiftdelta = float2(0,0);
float2 texcoordmul = float2(1,1);

 
Texture2D g_MeshTexture;  
Texture2D g_NoiseTexture;  
Texture2D g_DetailTexture;   
Texture2D g_DetailTexture_n;   
 
bool TextureEnabled = true;
bool DetailEnabled = true; 
bool is_blackhole = false;
  
float2 detailscale = float2(0.01,0.01);
  

TextureCube g_EnvTexture; 

SamplerState MeshTextureSampler
{
    Filter = MIN_MAG_MIP_LINEAR;
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

struct VSS_IN
{
	float4 pos : POSITION; 
	float3 norm : NORMAL;  
	float3 bnorm : BINORMAL; 
	float3 tnorm : TANGENT; 
	float2 tcrd : TEXCOORD;  
	float3 color : COLOR0; 
	
	 
};

struct I_IN
{
	float4x4 transform : WORLD; 
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
	
	half layer :TEXCOORD7;
	//float z_depth : TEXCOORD2;
};

struct DCI_PS_IN
{ 
	float4 pos : SV_POSITION;  
	float2 tcrd : TEXCOORD0; 
};

struct PS_OUT
{
    float4 color: SV_Target0;
    //float4 normal: SV_Target1;
    //float4 position: SV_Target2;
    //float depth: SV_Target2;
};


PS_IN VSI( VSS_IN input, I_IN inst ) 
{
	PS_IN output = (PS_IN)0; 
	float4x4 InstWorld = mul(inst.transform,World);
	float4 wpos = mul(input.pos,InstWorld);
	float4x4 VP =mul(View,Projection);
	
	float3x3 nworld = (float3x3)(InstWorld);
	
	output.pos =  wpos;//mul(wpos,VP);
	output.wpos = wpos.xyz;
	output.norm = normalize(mul(input.norm,nworld)); 
	output.bnorm = normalize(mul(input.bnorm,nworld)); 
	output.tnorm = normalize(mul(input.tnorm,nworld)); 
	output.tcrd = input.tcrd;
	output.color = input.color;//((float3)input.inds.xyz);
	output.spos = mul(float4(0,0,0,1),InstWorld);
	return output;
}
 
[maxvertexcount(3+3*12)]//+3
void GSS( triangle PS_IN input[3], inout TriangleStream<PS_IN> OutputStream )
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

	[unroll]
	for (int x = 1; x < 20; x++)
	{
		float w = 0.0010*x;  
		input[0].pos = mul(float4(pos1+input[0].norm.xyz*w*input[0].spos.x,1),mx);
		input[1].pos = mul(float4(pos2+input[1].norm.xyz*w*input[1].spos.x,1),mx);
		input[2].pos = mul(float4(pos3+input[2].norm.xyz*w*input[2].spos.x,1),mx); 
		input[0].layer = (float)x/19;
		input[1].layer = (float)x/19;
		input[2].layer = (float)x/19;
		OutputStream.Append( input[0] );
		OutputStream.Append( input[1] );
		OutputStream.Append( input[2] ); 
		OutputStream.RestartStrip();
	} 
}


PS_OUT PS( PS_IN input ) : SV_Target
{ 
	PS_OUT output = (PS_OUT)0;
	if(is_blackhole) 
	{
		float4x4 VP =mul(View,Projection);
		//float3 localnorm = mul(float4(input.norm,1),VP);
		//if below surface => normal from world pos
		//input.norm = -normalize(World._m30_m31_m32); 

		//normalize(input.wpos)
		float dpb = dot(normalize(input.spos),normalize(input.wpos));
		float spbd = 
		1//saturate(-dot(normalize(input.spos),-input.norm)+1.5)
		*saturate(-dot(normalize(input.wpos),-input.norm));
		float dotP3 = pow(spbd ,10);
		float3 envdir = mul(lerp( normalize(input.wpos.xyz),-input.norm,
			dotP3 ),EnvInverse) ;
		float4 envmap = g_EnvTexture.Sample(MeshTextureSampler,envdir);
		float4 dilationColorShift = float4(1,0,-1,0)*2;
		float lightMul = saturate(1-dotP3-dotP3*dotP3*dotP3); 
		output.color =
		// float4(input.norm.xyz,1);// 
		(envmap*1+dilationColorShift*saturate(envmap)*dotP3*dotP3*2)*lightMul;
		//float4(1,1,1,1);
		//float4(dotP3,dotP3,dotP3,1);
		return output;
	}

	float TBrightness = brightness * hdrMultiplier;
	//float realDepth = length(input.wpos)/global_scale;  
	
	float detailblend =1;// saturate(1-detailFade);
	 
	
	float2 texCoord = input.tcrd*texcoordmul + textureshiftdelta*time;
	 
	 
	  
	if(TextureEnabled)
	{ 
		//spots
		float4 spots = 
		saturate(saturate(g_MeshTexture.Sample(MeshTextureSampler, texCoord/4)
		*g_MeshTexture.Sample(MeshTextureSampler, texCoord)
		*g_MeshTexture.Sample(MeshTextureSampler, texCoord*2)
		*g_MeshTexture.Sample(MeshTextureSampler, texCoord*3)*40000)+0.1);
		
		//
		float scale = 2;
		float timescale = 1.0/1000;
		float4 texInX = 
		g_MeshTexture.Sample(MeshTextureSampler, texCoord*10*scale+time*float2(-2,1)*timescale) 
		*g_MeshTexture.Sample(MeshTextureSampler, texCoord*5*scale+time*float2(-2,-2)*timescale)
		+g_MeshTexture.Sample(MeshTextureSampler, texCoord*3*scale+time*float2(-1,1)*timescale)
		*g_MeshTexture.Sample(MeshTextureSampler, texCoord*2*scale+time*float2(-4,-7)*timescale)
		//*g_MeshTexture.Sample(MeshTextureSampler, texCoord*1+time*float2(-3,9)/100)
		;
		float4 texInY = 
		g_MeshTexture.Sample(MeshTextureSampler, texCoord*10*scale+time*float2(9,5)*timescale) 
		*g_MeshTexture.Sample(MeshTextureSampler, texCoord*5*scale+time*float2(-6,7)*timescale)
		+g_MeshTexture.Sample(MeshTextureSampler, texCoord*3*scale+time*float2(2,-3)*timescale)
		*g_MeshTexture.Sample(MeshTextureSampler, texCoord*2*scale+time*float2(-8,7)*timescale)
		//*g_MeshTexture.Sample(MeshTextureSampler, texCoord*1+time*float2(-3,9)/100)
		;
		
		float4 texIn = g_MeshTexture.Sample(MeshTextureSampler, float2(texInX.x,texInY.y)/1) ;
		//float4 texIn_s =  g_MeshTexture.Sample(MeshTextureSampler, float2(texInX.x,texInY.y)/10) ;
		
		float3 camdir = normalize(input.wpos);
		float lnd = saturate(dot(input.norm,-camdir));
		//texIn = lerp(texIn,texIn_s,length(input.wpos));
		float3 low = Color*0.9;//float3(157,180,255)/255/2; 
		float3 high = Color*3.5;//float3(255,255,255)/255;
		float3 result = lerp(low,high, saturate(texIn.x-lnd*0.3))*1.3;//*2.5;
		result*=saturate(lnd*lnd*50);
		output.color = float4(result*TBrightness*spots,texIn.a*TBrightness);

		float height = saturate(texIn.x)*0.5 + saturate(spots.x);
		//output.color = height*10;
		float blend = saturate(height/3)-input.layer;
		clip(blend ); 
		output.color.a = blend; 
	}
	else
	{ 
		output.color = float4(Color*TBrightness,TBrightness);
	}
	   
	 
	//float3x3 VP =(float3x3) mul(transpose(View),transpose(Projection));
	//float3 vv = mul(input.norm,VP);
	//float3 rer = normalize(vv.xyz);
	//output.normal = float4(rer.x/2+0.5,rer.y/2+0.5,-rer.z/2+0.5,1); 
	//output.normal = float4(rer,1);
    //output.normal = float4(input.norm/2+float3(0.5,0.5,0.5),1);
	//output.position = input.pos;
    //output.depth = float4(input.wpos.xyz,1);
	return output;
}

 
technique10 Instanced
{
	pass P0
	{
		SetVertexShader( CompileShader( vs_4_0, VSI() ) );
		SetGeometryShader(  CompileShader( gs_4_0, GSS() ) ); 
		SetPixelShader( CompileShader( ps_4_0, PS() ) );
	}
} 