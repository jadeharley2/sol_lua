 
float3 hazeColor =float3(209,199,154)/255;// float3(210,216,225)/255;//0.7,0.6,0.5);

float3 dust_color=float3(209,199,154)/255;

float4x4 World;
float4x4 View;
float4x4 Projection;

bool postmode;

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
 
float3 campos = float3(0.4,0.8,1);

Texture2D tLightView;  
Texture2D tDepthView;   
Texture2D tDiffuseView;   
Texture2D tMaskView;   
Texture2D tSkyRamp;   
 
Texture3D tClouds;   
Texture2D tCloudsB;   
 

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
  
SamplerState sFCL
{
    Filter = MIN_MAG_MIP_LINEAR;//MIN_MAG_MIP_LINEAR;
    AddressU = Wrap;
    AddressV = Wrap;
    AddressW = Wrap;
}; 
  

 


#include "headers/scatter.fxh"



 





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
	 return tDepthView.Sample(sCC, position).r;//linearDepth(tDepthView.Sample(sCC, position).r);
}
//float3 SS_GetPosition(float2 UV, float depth)
//{
//	float4 position = 1.0f; 
// 
//	position.x = UV.x * 2.0f - 1.0f; 
//	position.y = -(UV.y * 2.0f - 1.0f); 
//
//	position.z = depth; 
// 
//	//Transform Position from Homogenous Space to World Space 
//	position = mul(position,  (invWVP));  
// 
//	//position *= position.w;
//	position /= position.w;
//
//	return position.xyz;
//}

 

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

    float4 worldPosition = mul(input.Position, (World));
    float4 viewPosition = mul(worldPosition, (View));
    output.Position = mul(viewPosition, (Projection));
	output.Normal = normalize( input.Position);//mul(-input.Position,(float3x3)(World)).xyz);
	output.Pos = worldPosition;
	output.LPOS =worldPosition;//-planetpos;
	output.tcrd = input.tcrd;
	output.data = input.color;

    return output;
}
   
bool IsNAN(float n)
{
    return (n < 0.0f || n > 0.0f || n == 0.0f) ? false : true;
}
float3 SS_GetPosition(float2 UV,float depth)
{ 
	float4 position = 1.0f; 

	position.x = UV.x * 2.0f - 1.0f; 
	position.y = -(UV.y * 2.0f - 1.0f); 

	
	position.z = depth; 
//position.w = 1;
	//Transform Position from Homogenous Space to World Space 
	position = mul(position, invWVP);  

	//position *= position.w;
	if(position.w==0) return position.xyz;
	position /= position.w;

	return position.xyz;
}

float tcdensity(float3 pos){
	return saturate(
			//tClouds.Sample(sFCL, pos*2).a
			tCloudsB.Sample(sFCL,pos.xz*0.2).r*2
			*saturate(1-abs(pos.y*10+2))-0.3 
			
			)
			
			*(k/128);
} 
float3 tctest(float2 screenPosition,PS_IN input, float3 light){
	  
	float depth =  min(0.99997,tDepthView.Sample(sCL, screenPosition).x);
    float3 pos =(SS_GetPosition(screenPosition,depth ))	;// SS_GetPosition(screenPosition,depth);
	float3 dir =  (pos -(campos*float3(1,-1,-1)));
	float len = length(dir);
	//float maxlen = 1;
	
	//if(len>maxlen) {
	//	dir = (dir/len) * maxlen;
	//}
	float3 ddt = dir/128;
	float testcloud = 0;
	float3 enclight =0;
	float3 samplepos = campos*float3(1,-1,-1);

	float3 lightenergy = 0;
	float transmittance = 0;//1;

	float Density = 0.01;
	for(float k=1;k<128;k++){
		float cursample = tcdensity(samplepos)*100;
		//if( cursample > 0.001)
		//{
	 	float inlight = 1;
	 
	 	float3 lpos = samplepos;
	 	for(float j=1;j<8;j++){
	 		lpos = lpos + ldir0;
	 		inlight  -=(tcdensity(lpos)+0.01);
	 	}
	 	//
     	//float curdensity = saturate(cursample * Density);
	 	//float shadowterm = exp(-shadowdist * 0.3);
	 	//float3 absorbedlight = shadowterm * curdensity;
	 	//lightenergy += absorbedlight * transmittance  ;
 
        	transmittance += cursample+inlight*cursample; 
		//}
		samplepos +=ddt; 
	}
	
	//transmittance +=	tcdensity(samplepos)*100;
	return   max(0,light
	 )
	 +transmittance
	//+lightenergy 
	  ;//+testcloud*enclight
}


PS_OUT PS(PS_IN input) : SV_Target
{   
	PS_OUT ou = (PS_OUT)0;
	
	//return float4(0.5,0,1,0.5);
	float2 screenPosition = ((float2)input.Position.xy)/screenSize;
	 

	float dpdepth = input.Position.z;
	float rpdepth = 0.000006/SS_GetDepth(screenPosition) * distanceMultiplier/1000
		//*sqrt(distanceMultiplier)/1000;
	//	/1000
	;//*sqrt(distanceMultiplier)/100;

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
	
	float3 ldir = -ldir0;
	float3 lcol = lcol0; 
	float llen = length(ldir);
	if(llen>0) 
	{
		ldir/=llen;//-normalize(ldir);
		lcol/=llen*llen;
		
		//lcol = lcol0//-=(1-saturate(dot(-normalAtHorison,ldir)*5))*atmosphereColor*lcol*1.9
		//	*saturate(horison)*saturate(horison)*2
		//	;
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
	
	float sunUpDot = normalize(ldir0).y/2+0.5;
	float3 acolor = tSkyRamp.Sample(sCC, float2(sunUpDot,0.1));//atmosphereColor
		
	float starLumAmount =  density = density * lightIntencity;
	
	//atmosphereColor
		//*sunTotal
	float3 topColor = acolor*saturate(topDot)/ atmdencityByDist;//*totalLightColor;
	float3 horisonColor =hazeColor*totalLightColor
	
	// lerp(
		//hazeColor*lerp(lcol0,totalLightColor,0.5)*0.5,
		//,
		//saturate(dot(input.Normal,ldir0)+0.1)+saturate(dot(-normalAtHorison,ldir0))
		//);/// atmdencityByDist
		;
	float3 bottomColor = acolor;
	
	
	
	if(isCameraUnderWater)
	{ 
		density = max(0.5,density); 
		
		horisonColor = totalLightColor*float3(0.1,0.25,0.3)/2/max(1,liquidDepth);
		bottomColor = totalLightColor*float3(0.1,0.25,0.3)/2/max(1,liquidDepth); 
		
	}
	
	float4 tBackColor = tLightView.Sample(sCC, screenPosition+float2(cos(time),sin(time))*0);
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
	 (topColor+atmosphereColor*totalLightColor+sunTotal*10)*density*2*2;//*angleDensity*1;//4

	float3 dust = (saturate(horison)+saturate(-topDot))*horisonColor*2;
	
	float light_dust_blend = saturate(horison)*saturate(density*angleDensity*3)/ max(1,atmdencityByDist/5) ;

rpdepth = min(0.1,rpdepth);

//ou.color = rpdepth ;
//return ou;
	float4 result =  float4( lerp(additive,dust,light_dust_blend),1);

	result.rgb =lerp( tBackColor.rgb,dust/2+ additive,saturate(rpdepth*10)) ;

	float surfacecorrector = 1-saturate(-topDot*1000.8);
	float surfacecorrectorb= saturate(-topDot*2);
	input.Normal.y=input.Normal.y*surfacecorrector+0.1*surfacecorrectorb;  

	ray_t rayx = {float3(0,earth_radius,0),-input.Normal*1.4*saturate(rpdepth*10)};
	doublecom mierayleigh = get_incident_light(rayx,rpdepth);

	float3 rem = max(float3(0,0,0),mierayleigh.rayleigh+mierayleigh.mie*2);
	result.rgb =rem*2;//lerp( tBackColor.rgb,rem*2,saturate(rpdepth)) ;
	result.a = saturate(rpdepth*10*1.1)*saturate(length(result.rgb));
	
	float3 inlight =  tLightView.Sample(sCC, screenPosition);
	float4 inmask =  tMaskView.Sample(sCC, screenPosition);
	
	inmask.r *= saturate(1-result.a);
	result.rgb = lerp(inlight,result.rgb,result.a);



 
	//if(postmode){ 
	//	result.rgb = tctest(screenPosition,input,result.rgb );
	//	//result.rgb  = tctest(screenPosition,input);
	//}









	
	//result = tLightView.Sample(sCC, screenPosition);
	//result.r = 1;
	result.a = 1;
	//result = rpdepth*10;//*float4(dust,1);
	//if(rpdepth<0.0001) result = 1;
	//result = tBackColor;
	//result = float4(dust,1);
	//ou.normal.r = 1; 
	//ou.mask.r =0;// density*angleDensity;


	//result.rgb = sunTotal;
	//result.a =0.9; 
	//result = surfacecorrector;

	ou.mask =inmask;
	ou.color = result;//*0.5; 
	ou.normal = float4(0.5,0.5,1,1);
	ou.depth =  0;
	ou.diffuse = tDiffuseView.Sample(sCC, screenPosition);



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