
#include "headers/hdr.fxh"

float4x4 Projection;
float4x4 View;
float4x4 World;
float fov= 3.1415926/2;
float time;
float global_scale=1;
float abs_scale=1;
float hide_power = 1;
float hide_multiplier = 2000;//20000
bool near_hide = true;
bool star_mode = true;
float3 global_upvector = float3(0,1,0);
float3 camera_velocity = float3(1,10,1);
Texture2D gTexture;      
float4 Tint = float4(1,1,1,1);

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
};


struct PS_OUT
{
    float4 color: SV_Target0;
    float4 normal: SV_Target1;
    //float4 position: SV_Target3;
    float depth: SV_Target2;
    float4 mask: SV_Target3;
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
PS_IN star_VSI( VS_IN input, I_IN inst ) 
{
	PS_IN output = (PS_IN)0;
	float4 camoffcetposition = mul(float4(inst.pos.xyz,1),(World));
	
	float camdist = length(camoffcetposition.xyz);
	
	float3 direction =  camoffcetposition.xyz/camdist;
	
	float3 up = normalize(camera_velocity);//global_upvector;
	
	float cvellen = 0;//length(camera_velocity);
	
	if(cvellen<0.001)
	{
		up = normalize( global_upvector );
	} 
	float3 right =  normalize( cross(direction,up));
	 
	up = normalize(cross(direction,right)); 
	if(cvellen>0.001)
	{
		up*=1+((length(camera_velocity))/length(camoffcetposition))*(1-abs(dot(direction,normalize(camera_velocity))));
		//up*=1+1-abs(dot(direction,normalize(camera_velocity)));
	}
	
	//float3 rtDir = cross(camera_velocity,direction);
	//rtDir = cross(rtDir,direction);
	//right+=right*rtDir;
	//up*=abs(camera_velocity);
	//right*=abs(camera_velocity);
	/*
	float scale =  0.0000001;//(inst.lum) * global_scale /(4*3.14159265*camdist*camdist)*10;// length(camoffcetposition.xyz);
	//float scale = 0.15f*(inst.lum) ;// length(camoffcetposition.xyz);//STARS!
	if(input.tex.x<0.5)	{	camoffcetposition.xyz+=right*scale;	}
	else	{				camoffcetposition.xyz-=right*scale;	}
	if(input.tex.y<0.5) { 	camoffcetposition.xyz+=up*scale;	}
	else	{				camoffcetposition.xyz-=up*scale;	} 
	*/
	float visible = 1;//saturate((inst.lum*250 - length(camoffcetposition.xyz)));
	
	output.tex = input.tex*inst.tcrd.zw+inst.tcrd.xy; 
	//output.tex =Rotate(output.tex,inst.rot,1.0f/32+inst.tcrd.xy ); 
	output.tex =Rotate(output.tex,inst.rot,inst.tcrd.zw/2+inst.tcrd.xy ); 
	output.tcrd = inst.tcrd;
	camdist = camdist/global_scale*abs_scale;//(1666666);
	
	float4 vvp = mul(camoffcetposition,	(View));
	float distmul = 1/(4*3.14159265*camdist*camdist) ; 
	float scale = min(0.001, inst.lum  )*vvp.z*2*saturate(0.5+inst.lum);
	;
	if(input.tex.x<0.5)	{	vvp.xy+=float2(scale,0);	}
	else	{				vvp.xy-=float2(scale,0);	}
	if(input.tex.y<0.5) { 	vvp.xy-=float2(0,scale);	}
	else	{				vvp.xy+=float2(0,scale);	} 
	
	output.pos =  mul(vvp,	(Projection));
	 
	
	//output.z_depth = sqlen(camoffcetposition.xyz);
	float br = saturate(1e35 * distmul);
	output.color =  float4( inst.color/100*br
		,1);
	//output.color =  float4( inst.color* inst.lum  *1e27 * distmul,1);///10e25* 1e-13
	if(near_hide)
	{
		/*
		output.color.a = saturate(
		length(camoffcetposition.xyz)*hide_multiplier/global_scale//(camoffcetposition.x*camoffcetposition.x+camoffcetposition.y*camoffcetposition.y+camoffcetposition.z*camoffcetposition.z)
		-hide_power);
		*/
	}
	//	output.color =float4(  inst.color,1); 
	return output;
}

PS_OUT star_PS( PS_IN input ) : SV_Target
{
	PS_OUT output = (PS_OUT)0;
	input.tex =Clamp(  input.tex,input.tcrd);
	float4 tex =gTexture.Sample(TextureSampler,input.tex);
	float4 result = tex*input.color + tex*tex* input.color*2;
	//result*=0.1f;
	result.a = (result.x+result.y+result.z)/3*16; 
	result *=input.color.a; 
	output.color = result*Tint;
	output.mask.a = length(result);
	output.mask=0;
	return output;//10
	//return float4(gTexture.Sample(TextureSampler,input.tex).xyz*input.color.xyz,1);
	;//*saturate(50/input.z_depth)+Color2*saturate(1-50/input.z_depth);
} 


PS_IN particle_VSI( VS_IN input, I_IN inst ) 
{
	PS_IN output = (PS_IN)0;
	float4 camoffcetposition = mul(float4(inst.pos.xyz,1),(World));
	
	
	float3 direction = normalize( camoffcetposition );
	
	float3 up = normalize(camera_velocity);//global_upvector;
	
	float cvellen = 0;//length(camera_velocity);
	
	if(cvellen<0.001)
	{
		up = normalize( global_upvector );
	} 
	float3 right =  normalize( cross(direction,up));
	 
	up = normalize(cross(direction,right)); 
	if(cvellen>0.001)
	{
		up*=1+((length(camera_velocity))/length(camoffcetposition))*(1-abs(dot(direction,normalize(camera_velocity))));
		//up*=1+1-abs(dot(direction,normalize(camera_velocity)));
	}
	//float3 rtDir = cross(camera_velocity,direction);
	//rtDir = cross(rtDir,direction);
	//right+=right*rtDir;
	//up*=abs(camera_velocity);
	//right*=abs(camera_velocity);
	
	float scale =  (inst.lum) * global_scale;// length(camoffcetposition.xyz);
	//float scale = 0.15f*(inst.lum) ;// length(camoffcetposition.xyz);//STARS!
	if(input.tex.x<0.5)	{	camoffcetposition.xyz+=right*scale;	}
	else	{				camoffcetposition.xyz-=right*scale;	}
	if(input.tex.y<0.5) { 	camoffcetposition.xyz+=up*scale;	}
	else	{				camoffcetposition.xyz-=up*scale;	} 
	float visible = 1;//saturate((inst.lum*250 - length(camoffcetposition.xyz)));
	
	output.tex = input.tex*inst.tcrd.zw+inst.tcrd.xy; 
	//output.tex =Rotate(output.tex,inst.rot,1.0f/32+inst.tcrd.xy ); 
	output.tex =Rotate(output.tex,inst.rot,inst.tcrd.zw/2+inst.tcrd.xy ); 
	output.tcrd = inst.tcrd;
	output.pos =  mul(mul(camoffcetposition,	(View)),	(Projection));
	//output.z_depth = sqlen(camoffcetposition.xyz);
	output.color =float4( inst.color*visible,1);
	if(near_hide)
	{
		output.color.a = saturate(
		length(camoffcetposition.xyz)*hide_multiplier/global_scale//(camoffcetposition.x*camoffcetposition.x+camoffcetposition.y*camoffcetposition.y+camoffcetposition.z*camoffcetposition.z)
		-hide_power);
	}
	//	output.color =float4(  inst.color,1);
	return output;
}

PS_OUT particle_PS( PS_IN input ) : SV_Target
{
	PS_OUT output = (PS_OUT)0;
	input.tex =Clamp(  input.tex,input.tcrd);
	float4 tex =gTexture.Sample(TextureSampler,input.tex);
	float4 result = tex*input.color + tex*tex* input.color*2;
	//result*=0.1f;
	//result.a = (result.x+result.y+result.z)/3*16; 
	//result *=input.color.a;
	output.color = result*Tint;
	output.mask.a = result.a;//length(result);
	return output;//10
	//return float4(gTexture.Sample(TextureSampler,input.tex).xyz*input.color.xyz,1);
	;//*saturate(50/input.z_depth)+Color2*saturate(1-50/input.z_depth);
}


PS_IN VSI( VS_IN input, I_IN inst ) 
{
	if(star_mode) return star_VSI(input,inst);
	else return particle_VSI(input,inst);
}
float4 PS( PS_IN input ) : SV_Target
{ 
	
	if(star_mode) return star_PS(input).color;
	else return particle_PS(input).color;
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