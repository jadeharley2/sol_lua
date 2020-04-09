 
float3 hazeColor =float3(209,199,154)/255;// float3(210,216,225)/255;//0.7,0.6,0.5);

float3 dust_color=float3(209,199,154)/255;

float4x4 World;
float4x4 View;
float4x4 Projection;


float4x4 invWVP;
 
float distanceMultiplier=1;

float hdrMultiplier=1;
float time =0;
  
float3 planetpos;
float planetradius=1;
float horisonDistance=1;
float horisonDistanceLocal=1;
float absheight =0;
float rheight = 1;
 
int mode = 1;

float3 pcam;
float atm_width=1;
float atm_floor=1;

float3 ldir0=normalize(float3(1,0,1));
float3 lcol0=float3(1,1,1);

bool isCameraUnderWater;

float2 screenSize = float2(1024,1024);
 
float3 atmosphereColor = float3(0.4,0.8,1);
 

Texture2D tDepthView;   
Texture2D tDiffuseView;   
 

SamplerState sCC
{
    Filter = MIN_MAG_MIP_POINT;//MIN_MAG_MIP_LINEAR;
    AddressU = Clamp;
    AddressV = Clamp;
}; 

SamplerState sCL
{
    Filter = MIN_MAG_MIP_LINEAR;//MIN_MAG_MIP_LINEAR;
    AddressU = Wrap;
    AddressV = Wrap;
}; 
  



float camera_near=0.1;
float camera_far=100;


float linearDepth(float depth)
{
    return 2.0 * camera_near * camera_far /
             (camera_far + camera_near -
             (depth * 2.0 - 1.0) * (camera_far - camera_near));
}

float SS_GetDepth(float2 position)
{ 
	 return linearDepth(tDepthView.Sample(sCC, position).r);
}
float3 SS_GetPosition(float2 UV, float depth)
{
	float4 position = 1.0f; 
 
	position.x = UV.x * 2.0f - 1.0f; 
	position.y = -(UV.y * 2.0f - 1.0f); 

	position.z = depth; 
 
	//Transform Position from Homogenous Space to World Space 
	position = mul(position, transpose(invWVP));  
 
	//position *= position.w;
	position /= position.w;

	return position.xyz;
}

 

///////////////////////////////////

struct VertexShaderInput
{
    float4 Position : SV_POSITION; 

};
struct VSS_IN
{
	float4 Position : POSITION; 
	float3 norm : NORMAL;  
	float3 bnorm : BINORMAL; 
	float3 tnorm : TANGENT; 
	float2 tcrd : TEXCOORD; 
    float4 wts  : BLENDWEIGHT;
    float4 inds  : BLENDINDICES;
	float3 color : COLOR0; 
	
	 
};

struct PS_IN
{
    float4 Position : SV_POSITION;
	float3 Normal :TEXCOORD0;
	float3 Pos :TEXCOORD1;
    float3 LPOS : TEXCOORD2;
	float2 tcrd : TEXCOORD3;  // local position
	float3 data : TEXCOORD4;
};
struct PS_OUT
{
    float4 color: SV_Target0;
    float4 normal: SV_Target1;
    //float4 position: SV_Target2;
    float depth: SV_Target2;
    float4 mask: SV_Target3;
    float4 diffuse: SV_Target4;
};

PS_IN VS(VSS_IN input)
{
    PS_IN output = (PS_IN)0;

    float4 worldPosition = mul(input.Position, transpose(World));
    float4 viewPosition = mul(worldPosition, transpose(View));
    output.Position = mul(viewPosition, transpose(Projection));
	output.Normal = normalize( mul(-input.Position,(float3x3)transpose(World)).xyz);
	output.Pos = worldPosition;
	output.LPOS =worldPosition-planetpos;
	output.tcrd = input.tcrd;
	output.data = input.color;

    return output;
}
   
bool IsNAN(float n)
{
    return (n < 0.0f || n > 0.0f || n == 0.0f) ? false : true;
}

PS_OUT PS(PS_IN input) : SV_Target
{   
	PS_OUT ou = (PS_OUT)0;
	
	//return float4(0.5,0,1,0.5);
	float2 screenPosition = ((float2)input.Position.xy)/screenSize;
	 

	float dpdepth = input.Position.z/input.Position.w;
	float rpdepth =SS_GetDepth(screenPosition) 
		*sqrt(distanceMultiplier)/1000;
		
	float density =saturate(rpdepth*10);///horisonDistance*300000*1);///distanceMultiplier/100);
	
	
	float horisonangle = horisonDistanceLocal/length(planetpos);
	
	//different halo radiuses 
	float sunPowerh1 = 0.5;
	float sunPowerh2 = 0.4;
	float sunPowerh3 = 0.3;
	float sunPowerh4 = 0.2;
	float topDot =1;
	
	float liquidDepth = -absheight/100;
	float terrainLightDivider = max(1,(10-rpdepth));
	if(isCameraUnderWater) 
	{
		horisonangle = (absheight/300);
		
		topDot = dot(input.Normal,float3(0,-1,0))+horisonangle;
		
		sunPowerh1 = sunPowerh1 / max(1,liquidDepth*1);
		sunPowerh2 = sunPowerh2 / max(1,liquidDepth*5);
		sunPowerh3 = sunPowerh3 / max(1,liquidDepth*10);
		sunPowerh4 = sunPowerh4 / max(1,liquidDepth*100); 
		terrainLightDivider = 1;
	}
	else
	{
		topDot = dot(input.Normal,float3(0,-1,0));//+horisonangle;
	}


	float3 normalAtHorison =-normalize(planetpos);// normalize(input.Pos*6/rpdepth-planetpos);
	float lightIntencity = 0;//saturate(dot(-normalAtHorison,ldir0)*20+0.2	);

	float atmdencityByDist = max(1,absheight/30000);
	
	topDot = topDot*atmdencityByDist;
	float horison = 1-abs(topDot);
	
	float3 sunTotal = float3(0,0,0);
	float3 totalLightColor = float3(0,0,0);
	
		float3 ldir =-ldir0;
		float3 lcol = lcol0; 
		float llen = length(ldir);
		if(llen>0) 
		{
			ldir/=llen;//-normalize(ldir);
			lcol/=llen*llen;
			
			lcol -=(1-saturate(dot(-normalAtHorison,ldir)*5))*atmosphereColor*lcol*1.9
			//	*saturate(horison)*saturate(horison)*2
				;
				totalLightColor +=max(0,lcol);
			//float ldsq = ldir.x*ldir.x+ldir.y*ldir.y+ldir.z*ldir.z;
			//ldir/=sqrt(ldsq);
			//lcol/=

			float sunDot1 = max(0,dot(input.Normal,ldir));
			float sunDotC = 
				(pow(sunDot1,1)/10*sunPowerh1
				+
				pow(sunDot1,10)*sunPowerh2
				+
				pow(sunDot1,100)*sunPowerh3
				+
				pow(sunDot1,1000)*sunPowerh4
				)/terrainLightDivider
				;
			sunTotal += sunDotC * lcol*2;
			lightIntencity +=saturate(dot(-normalAtHorison,ldir)*5+0.5);
			
		}
totalLightColor = float3(1,1,1);
	lightIntencity = saturate(lightIntencity+0.2);
	
	
		
	float starLumAmount =  density = density * lightIntencity;
	
		//*sunTotal
	float3 topColor = atmosphereColor*saturate(topDot)/ atmdencityByDist;//*totalLightColor;
	float3 horisonColor =// lerp(
		//hazeColor*lerp(lcol0,totalLightColor,0.5)*0.5,
		hazeColor*totalLightColor//,
		//saturate(dot(input.Normal,ldir0)+0.1)+saturate(dot(-normalAtHorison,ldir0))
		//);/// atmdencityByDist
		;
	float3 bottomColor = atmosphereColor;
	
	
	
	if(isCameraUnderWater)
	{ 
		density = max(0.5,density); 
		
		horisonColor = totalLightColor*float3(0.1,0.25,0.3)/2/max(1,liquidDepth);
		bottomColor = totalLightColor*float3(0.1,0.25,0.3)/2/max(1,liquidDepth); 
		
	}
	
	float4 tBackColor = tDiffuseView.Sample(sCC, screenPosition+float2(cos(time),sin(time))*0);
	tBackColor.a = 1;
	float angleDensity  =
		saturate(-topDot)/ atmdencityByDist
		+saturate(horison)/  max(1,atmdencityByDist/100) 
				
		+saturate(topDot)/ atmdencityByDist;// saturate(horison) +saturate(topDot)
		;
		
	//return float4(density,density,density,1);
	float notTop =  1-saturate(topDot);

	if (IsNAN(tBackColor.r)) tBackColor.rgb  = 0;

	float3 additive =  
	 (topColor+atmosphereColor*totalLightColor+sunTotal)*density*2;//*angleDensity*1;//4

	float3 dust = (saturate(horison)+saturate(-topDot))*horisonColor;
	
	float light_dust_blend = saturate(horison)*saturate(density*angleDensity*3)/ max(1,atmdencityByDist/5) ;

	float4 result =  float4( lerp(additive,dust,light_dust_blend),1);



	result.rgb =lerp( tBackColor.rgb,dust/2+ additive,saturate(rpdepth*10)) ;

	//result = tDiffuseView.Sample(sCC, screenPosition);
	result.a = 1;
	//result = rpdepth*10;//*float4(dust,1);
	//if(rpdepth<0.0001) result = 1;
	//result = tBackColor;
	//result = float4(dust,1);
	//ou.normal.r = 1;
	//ou.mask.r =0;// density*angleDensity;
	ou.mask.a =1;
	ou.color = result;//*0.5; 
	//ou.diffuse = result;
	return ou;//return result; 
}
technique10 DefaultTech
{
	pass P0
	{
		SetGeometryShader( 0 );
		SetVertexShader( CompileShader( vs_4_0, VS() ) );
		SetPixelShader( CompileShader( ps_4_0, PS() ) );
	} 
}