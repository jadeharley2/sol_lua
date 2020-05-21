float4x4 Projection;
float4x4 View;
float4x4 World;
float fov= 3.1415926/2;
float time;
float global_scale=1;
float hide_power = 1;
bool near_hide = true;
float3 global_upvector = float3(0,1,0);
float4 Tint = float4(1,1,1,1);
 
Texture2D gTexture;      

SamplerState TextureSampler
{
    Filter = MIN_MAG_MIP_LINEAR;
    AddressU = Wrap;
    AddressV = Wrap;
};


struct VS_IN
{
	float4 pos : SV_POSITION; 
	float2 tex : TEXCOORD0;
};
struct I_IN
{
	float3 pos : POSITION1; 
	float3 color : COLOR; 
	float lum: COLOR1;
	float4 tcrd : TEXCOORD1; 
	float rot: TEXCOORD2;
};
 
struct PS_IN
{ 
	float4 pos : SV_POSITION;
	float2 tex : TEXCOORD0;
	float4 color : TEXCOORD1;  
	float4 tcrd : TEXCOORD2; 
	float3 vpos : TEXCOORD3; 
};

 

float2 Rotate(float2 coords,float rotation,float2 center)
{
	float rsin = sin(rotation);
	float rcos = cos(rotation); 
	float2 newcoords;
	coords = coords - center;  
	newcoords.x = (coords.x * rcos) + (coords.y * (-rsin));
	newcoords.y = (coords.x * rsin) + (coords.y * rcos); 
	return newcoords + center;
}
float2 Clamp(float2 inp,float4 rect)
{
	inp.x =clamp(inp.x,rect.x,rect.x+rect.z);
	inp.y =clamp(inp.y,rect.y,rect.y+rect.w);
	return inp;
}
PS_IN VSI( VS_IN input, I_IN inst ) 
{
	PS_IN output = (PS_IN)0;
	float4 camoffcetposition = mul(float4(inst.pos.xyz,1),(World));
	
	
	float3 direction = normalize( camoffcetposition );
	float3 up = global_upvector;
	float3 right =  normalize( cross(direction,up));
	up = normalize(cross(direction,right)); 
	//up*=0.5f;
	float scale =  (inst.lum) * global_scale;// length(camoffcetposition.xyz);
	//float scale = 0.15f*(inst.lum) ;// length(camoffcetposition.xyz);//STARS!
	if(input.tex.x<0.5)
	{
		camoffcetposition.xyz+=right*scale;
	}
	else
	{
		camoffcetposition.xyz-=right*scale;
	}
	if(input.tex.y<0.5)
	{
		camoffcetposition.xyz+=up*scale;
	}
	else
	{
		camoffcetposition.xyz-=up*scale;
	} 
	float visible = 1;//saturate((inst.lum*250 - length(camoffcetposition.xyz)));
	
	output.tex = input.tex;//*inst.tcrd.zw+inst.tcrd.xy; 
	//output.tex =Rotate(output.tex,inst.rot,1.0f/32+inst.tcrd.xy ); 
	//output.tex =Rotate(output.tex,inst.rot,inst.tcrd.zw/2+inst.tcrd.xy ); 
	output.tcrd = inst.tcrd;
	output.pos =  mul(mul(camoffcetposition,	(View)),	(Projection));
	//output.z_depth = sqlen(camoffcetposition.xyz);
	output.color =float4( inst.color*visible,1);
	if(near_hide)
	{
		output.color.a = saturate(
		length(camoffcetposition.xyz)*2000/global_scale//(camoffcetposition.x*camoffcetposition.x+camoffcetposition.y*camoffcetposition.y+camoffcetposition.z*camoffcetposition.z)
		-hide_power);
	}
	//	output.color =float4(  inst.color,1);
	output.vpos =  mul(float4( -camoffcetposition.xyz,1),(World)).xyz;
	return output;
}

float4 PS( PS_IN input ) : SV_Target
{
	//input.tex =Clamp(  input.tex,input.tcrd);
	float4 tex =gTexture.Sample(TextureSampler,input.tex);
	float4 result =tex*input.color;
	//result*=0.1f;
	//result.a = length(result.xyz); 
	//result *=input.color.a;
	//return float4(input.vpos/10,0,1);
	float3 round = float3(1.03,1.015,1.0) * saturate(1-length(input.tex-0.5)*2)*saturate(1/length(input.vpos.xz));
	float3 color = gTexture.Sample(TextureSampler,input.vpos.xz/2-0.5f).xyz; 
	return float4( result.xyz,1)*Tint;//round*0.1f*result,round.x);
	return float4( color*round*0.2f,round.x*0.0002f)*Tint;//result*1;//10
	//return float4(gTexture.Sample(TextureSampler,input.tex).xyz*input.color.xyz,1);
	;//*saturate(50/input.z_depth)+Color2*saturate(1-50/input.z_depth);
}


technique10 Instanced
{
	pass P0
	{
		SetGeometryShader( 0 );
		SetVertexShader( CompileShader( vs_4_0, VSI() ) );
		SetPixelShader( CompileShader( ps_4_0, PS() ) );
	}
} 