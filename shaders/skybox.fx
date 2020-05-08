float4x4 Projection;
float4x4 View;
float4x4 World;

float4 Tint = float4(1,1,1,1);

//Texture2D gTexture0;//front  X+ back
//Texture2D gTexture1;//left   X- front
//Texture2D gTexture2;//back   Y+ top
//Texture2D gTexture3;//right  Y- bottom
//Texture2D gTexture4;//up     Z+ right
//Texture2D gTexture5;//down   Z- left

Texture2D noisetexture;
TextureCube g_EnvTexture;  

SamplerState MeshTextureSampler
{
    Filter = MIN_MAG_MIP_LINEAR;
    AddressU = Wrap;
    AddressV = Wrap;
};



struct VS_IN
{
	float4 pos : SV_POSITION;
	float2 tcrd : TEXCOORD;
};

struct PS_IN
{  
	float4 pos : SV_POSITION;
	float4 wpos : TEXCOORD;
	float2 tcrd : TEXCOORD1;
	float4 cpos : TEXCOORD2;
};
struct PS_OUT
{
    float4 color: SV_Target0;//light
    float4 normal: SV_Target1; 
    float depth: SV_Target2;
    float4 mask: SV_Target3;
    float4 diffuse: SV_Target4;
};

PS_IN VS( VS_IN input ) 
{
	PS_IN output = (PS_IN)0;
	
	output.cpos = input.pos;
	output.wpos = mul(input.pos,(World));
	output.pos =  mul(mul(output.wpos,(View)),(Projection));//mul(Proj, mul( input.pos,World));
	output.tcrd = input.tcrd;
	 
	return output;
}
 
PS_OUT PS( PS_IN input ) : SV_Target
{
	/*
	float4 result;
	if(input.tcrd.x>2)
	{
		if(input.tcrd.y>1)
		{
			 //float4(1,0,1,1);//
			result = gTexture3.Sample(MeshTextureSampler, input.tcrd);//down
		}
		else
		{
			  //float4(0,0,1,1);//
			result = gTexture0.Sample(MeshTextureSampler, input.tcrd);//back
		}
	}
	else if(input.tcrd.x>1)
	{
		if(input.tcrd.y>1)
		{
			  //float4(0,1,1,1);//
			result = gTexture2.Sample(MeshTextureSampler, input.tcrd);//up
		}
		else
		{
			  //float4(0,1,0,1);//
			result = gTexture5.Sample(MeshTextureSampler, input.tcrd);//left
		}
	}
	else
	{
		if(input.tcrd.y>1)
		{
			  //float4(1,1,0,1);//
			result = gTexture4.Sample(MeshTextureSampler, input.tcrd);//right
		}
		else
		{
			  //float4(1,0,0,1);//
			result = gTexture1.Sample(MeshTextureSampler, input.tcrd);//front
		}
	}
	*/
	PS_OUT output = (PS_OUT)0;
	float3 cameraDirection = normalize(input.cpos.xyz);
	float4 result = g_EnvTexture.Sample(MeshTextureSampler, -cameraDirection);
	//result = float4(1,1,1,1); 
	//float fd =  //0 - noisetexture.Sample(MeshTextureSampler, input.tcrd).r;;//
	//Tint.r - noisetexture.Sample(MeshTextureSampler, input.tcrd).r;
	//float flashcor = saturate(2 - abs(fd)*100);
	//float flash = saturate(2 - fd*100);
	//result.rgb = input.cpos/2+0.5;// result *Tint;//* (flash+flashcor) + flashcor*float4(0,0.3f,0.04f,1); 
	result = result *Tint;//* (flash+flashcor) + flashcor*float4(0,0.3f,0.04f,1); 
	//result = float4(1,1,1,1);
	//result.a = 1;
	if(isnan(result.x)) result=0;
	output.color = result;
	output.diffuse = result;
	output.normal = float4(0.5,0.5,1,1);
	output.depth =  1;
	
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