#include "headers/lightning.fxh"
#include "headers/atmosphere.fxh" 

float3 hazeColor = float3(210,216,225)/255;//0.7,0.6,0.5);

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
float3 ldir1;
float3 lcol1;
bool isCameraUnderWater;

float2 screenSize = float2(1024,1024);

float3 cloudColor = float3(1,1,1);
float3 atmosphereColor = float3(0.4,0.8,1);

float cloudmul = 1;

Texture2D tDepthView;   
Texture2D tDiffuseView;   

Texture2D tClouds; 
Texture2D tCloudNoise; 

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

float3 Delight(float3 SUNLIGHT,float to)
{
	 
    float from = 1 - to;
    float to2 = clamp((to) * 2  , 0, 1);
    float3 cc = SUNLIGHT * base - SUNLIGHT * base * to2
                + clamp(SUNLIGHT - base * to * 3, float3(0,0,0), float3(1,1,1)) * to2 * from * 2 ;
	return cc;
}

///////////////////////////////////
static const float R0 = 6360e3; // ������ ����������� �����
static const float Ra = 6380e3; // ������ ������� ������� ���������
static const float3 bR = float3(58e-7, 135e-7, 331e-7); // ���������� ����������� ���������
static const float3 bMs = float3(2e-5,2e-5,2e-5); // ����������� ����������� ���������
static const float3 bMe = float3(2e-5,2e-5,2e-5) * 1.1;
static const float I = 10.; // ������� ������
//static const float3 C = float3(0., -6360e3, 0.); // ���������� ������ �����, ����� (0, 0, 0) ��������� �� �����������

// ������� ����������
// ���������� vec2(rho_rayleigh, rho_mie)
float2 densitiesRM(float3 p,float3 C) {
    float h = max(0., length(p - C) - R0); // ������ �� �����������
    return float2(exp(-h/8e3), exp(-h/12e2));
}


// Basically a ray-sphere intersection. Find distance to where rays escapes a sphere with given radius.
// Used to calculate length at which ray escapes atmosphere
float escape(float3 p, float3 d, float R,float3 C) { 
	float3 v = p - C;
    float b = dot(v, d);
    float det = b * b - dot(v, v) + R*R;
    if (det < 0.) return -1.;
    det = sqrt(det);
    float t1 = -b - det, t2 = -b + det;
    return (t1 >= 0.) ? t1 : t2;
}
// ���������� ��������� ��������� ���������� ������� ��� ������� ����� `L` �� ����� `p` � ����������� `d`
// ����������� �� `steps` �����
// ���������� vec2(depth_int_rayleigh, depth_int_mie)
float2 scatterDepthInt(float3 o, float3 d, float L, float steps,float3 C) {
    float2 depthRMs = float2(0.,0.);
    L /= steps; d *= L;
    for (float i = 0.; i < steps; ++i)
        depthRMs += densitiesRM(o + d * i,C);

    return depthRMs * L;
}
 

// ����������� �� ������
float3 sundir;

// Calculate in-scattering for ray starting at point `o` in direction `d` for length `L`
// Perform `steps` steps of integration
void scatterIn(float3 o, float3 d, float L, float steps, float3  C,
	inout float2 totalDepthRM, inout float3 I_R, inout float3 I_M) {
    L /= steps; d *= L;

    // �� ����� O � B
    for (float i = 0.; i < steps; ++i) {

        // P_i
        float3 p = o + d * i;

        float2 dRM = densitiesRM(p,C) * L;

        // ���������� T(P_i -> O)
        totalDepthRM += dRM;

        // ���������� ����� ���������� ������� T(P_i ->O) + T(A -> P_i)
        // scatterDepthInt() ��������� ��������� ����� T(A -> P_i)
        float2 depthRMsum = totalDepthRM + scatterDepthInt(p, ldir0, escape(p, ldir0, Ra,C), 4.,C);

        float3 A = exp(-bR * depthRMsum.x - bMe * depthRMsum.y);

        I_R += A * dRM.x;
        I_M += A * dRM.y;
    }
}
 
// Final scattering function
// O = o -- starting point
// B = o + d * L -- end point
// Lo -- end point color to calculate extinction for
float3 scatter(float3 o, float3 d, float L, float3 Lo,float3 C) {
    float2 totalDepthRM = float2(0.,0.);
    float3 I_R = float3(0.,0.,0.);
	float3 I_M = float3(0.,0.,0.);

    // ���������� T(P -> O) and I_M and I_R
    scatterIn(o, d, L, 16.,C, totalDepthRM,I_R,I_M);

    // mu = cos(alpha)
    float mu = dot(d, ldir0);

    // ��������� ����� ��������� �����
    return Lo * exp(-bR * totalDepthRM.x - bMe * totalDepthRM.y)

    // ��������� ����
        + I * (1. + mu * mu) * (
            I_R * bR * .0597 +
            I_M * bMs * .0196 / pow(1.58 - 1.52 * mu, 1.5));
}





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
	position = mul(position, (invWVP));  
 
	//position *= position.w;
	position /= position.w;

	return position.xyz;
}



float2 escape2(float3 v, float3 d, float R) {  
    float b = dot(v, d);
    float det = b * b - dot(v, v) + R*R;
	//return det; 
    if (det < 0.) return -1;
    det = sqrt(det);
    float t1 = -b - det, t2 = -b + det;
    return  float2(-t1,t2);
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

    float4 worldPosition = mul(input.Position, (World));
    float4 viewPosition = mul(worldPosition, (View));
    output.Position = mul(viewPosition, (Projection));
	output.Normal = normalize( mul(-input.Position,(float3x3)(World)).xyz);
	output.Pos = worldPosition;
	output.LPOS =worldPosition-planetpos;
	output.tcrd = input.tcrd;
	output.data = input.color;

    return output;
}
  
float2 CloudNoiseLow(float2 tcrd)
{ 
	float2 NA = float2(
			tCloudNoise.Sample(sCL, tcrd*float2(2,1)*150
			+float2(1,1)*time*0.01).r-0.5, 
			tCloudNoise.Sample(sCL, tcrd*float2(2,-1)*150+float2(0.3,-0.6)
			+float2(1,-1)*time*0.01).r-0.5
			);
	float NB = float2(
			tCloudNoise.Sample(sCL, tcrd*float2(2,1)*450
			+float2(1,1)*time*0.005).r-0.5, 
			tCloudNoise.Sample(sCL, tcrd*float2(2,-1)*450+float2(0.3,-0.6)
			+float2(1,-1)*time*0.005).r-0.5
			);
	return NA+NB*0.5;
}
float2 CloudNoise(float2 tcrd)
{ 
	float NC = float2(
			tCloudNoise.Sample(sCL, tcrd*float2(2,1)*850
			+float2(1,1)*time*0.005).r-0.5, 
			tCloudNoise.Sample(sCL, tcrd*float2(2,-1)*850+float2(0.8,0.6)
			+float2(1,-1)*time*0.005).r-0.5
			);
	float ND = float2(
			tCloudNoise.Sample(sCL, tcrd*float2(2,1)*950+NC
			+float2(1,1)*time*0.005).r-0.5, 
			tCloudNoise.Sample(sCL, tcrd*float2(2,-1)*950+float2(0.3,-0.6)
			+float2(1,1)*time*0.005).r-0.5
			);  
	float2 noise = CloudNoiseLow(tcrd)+NC*0.5+ND*0.15;
	return noise;
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
	
	if (mode==1)//clouds from top
	{
		//float rpdepth =SS_GetDepth(screenPosition) 
		//	*sqrt(distanceMultiplier)/1000;

		float density =1;//saturate(rpdepth/horisonDistance*300000*1);
		//float density =1;// saturate((rheight-1.001)*100);
		//float density = saturate((rheight-1.01)*100);
		
		float dotpd = saturate(pow(saturate(dot(input.Normal,normalize(input.Pos))),1.0/4));//6
		//return dotpd; 
		float dpdepth =input.Position.z/ input.Position.w;
		//return tDepthView.Sample(sCC, screenPosition).r/10000-dpdepth/10000;
		float atmodepth =0.4;// float4(0.4,0.8,1,1)*tDepthView.Sample(sCC, screenPosition).r/
		//sqrt(max(0,tDepthView.Sample(sCC, screenPosition).r-dpdepth)/1000000.0*distanceMultiplier);
		//1-10.0/( tDepthView.Sample(sCC, screenPosition).r - dpdepth);
		//return atmodepth; 
		//1000 
		//float nearhide = 

 
		float3 lposn = normalize(-input.LPOS);
		float lplen = length(-input.LPOS);

		float3 sunTotal = float3(0,0,0);
		[unroll]
		for(int i=0;i<3;i++)
		{
			float3 ldir =-pointlightPosition[i];
			float3 lcol = pointlightColor[i]; 
			float llen = length(ldir);
			if(llen>0) 
			{
				ldir/=llen;//-normalize(ldir);
				lcol/=llen*llen;
				float lum =   saturate(dot(ldir,lposn)) ;  

				sunTotal+= lum*lcol;
			}
		}


		float rm = 0.002;
		float rm2 = rm*0.76*4;
		float3 bc1 = tDiffuseView.Sample(sCC, screenPosition);
		float3 bc2 = ( bc1
		 +tDiffuseView.Sample(sCC, screenPosition+float2(rm,rm))
		 +tDiffuseView.Sample(sCC, screenPosition+float2(-rm,rm))
		 +tDiffuseView.Sample(sCC, screenPosition+float2(-rm,-rm))
		 +tDiffuseView.Sample(sCC, screenPosition+float2(rm,-rm))

		 +tDiffuseView.Sample(sCC, screenPosition+float2(0,rm2))
		 +tDiffuseView.Sample(sCC, screenPosition+float2(0,-rm2))
		 +tDiffuseView.Sample(sCC, screenPosition+float2(-rm2,0))
		 +tDiffuseView.Sample(sCC, screenPosition+float2(rm2,0))

		)/9;
  		//bc2 = float3(1,0,0);
		//bc1 = float3(0,1,0);  

		float2 noise = CloudNoiseLow(input.tcrd);
		float4 clouds = tClouds.Sample(sCL, 
			input.tcrd
			+noise*0.001
			+float2(1,0)*time*0.00001
			)*float4(1,1,1,1); 
		
		float blenddata = input.data.x+noise*0.1;
		////////clouds = lerp(0,lerp(clouds,1,saturate(blenddata*2-1)),saturate(blenddata*2));
		//clouds =float4(noise.x,noise.y,1,1);
		//float4 cloudNoise = 
		//	(
		//		tCloudNoise.Sample(sCL, input.tcrd*float2(60,30))
		//		+tCloudNoise.Sample(sCL, input.tcrd*float2(60,30)*5)
		//		//+tCloudNoise.Sample(sCL, input.tcrd*float2(60,30)*13)
		//	)/3;
		////clouds =  lerp(clouds,cloudNoise,clouds.a/4);
		//clouds.a = clouds.a + clouds.a*(cloudNoise-0.5);
		//clouds.a = saturate(clouds.a +0.9); 
		 
		float3 tBackColor =lerp(bc1,bc2*0.4,saturate(clouds.a*4+0.2)*density); 
		 
		tBackColor = lerp(tBackColor,clouds*sunTotal*1.6*cloudColor,clouds.a*density);

		//return float4(clouds.a*sunTotal,1);

		float3 atmglow = saturate(dotpd*2)
			*(saturate(1-dotpd*dotpd)+0.15)
			*sunTotal
			*atmosphereColor
			*density;


		float3 result = atmglow*4 +tBackColor ;
		ou.color = float4(result,1);  
 
		if(cloudmul<1)
		{ 
			float3 atmmix = lerp(float3(1,1,1),atmosphereColor,0.1);
			
			ou.color = float4(
				clouds*sunTotal*cloudColor*1.6*2*1000
				*atmmix*saturate(sqrt(clouds.a))
				*saturate(1-cloudmul/2)  
				+atmglow*5
				,
				clouds.a*density*0.5*cloudmul
				);
			//ou.color =0;
		}
		return ou;//float4(result,1); 
	}
	else if(mode==10) // atm from below
	{
		//float spTopDot =  saturate(pow(-dot(input.Normal,float3(0,1,0) ),1000)); 
		float sdt = dot(input.Normal,normalize(planetpos) );
		float spTopDot =  saturate(pow(sdt+0.0001,1000)); 
		if(spTopDot>0.001&&sdt>0) 
		{
			//float density = saturate((rheight-1.01)*100);
			
			float dotpd = saturate(pow(saturate(dot(input.Normal,normalize(input.Pos))),1.0/4));//6
			//return dotpd; 
			float dpdepth =input.Position.z/ input.Position.w; 
			float atmodepth =0.4; 

			float density = 1;// saturate(0.0001/(dpdepth/distanceMultiplier));
	
			float3 lposn = normalize(-input.LPOS);

			float3 sunTotal = float3(0,0,0);
			[unroll]
			for(int i=0;i<3;i++)
			{
				float3 ldir =-pointlightPosition[i];
				float3 lcol = pointlightColor[i]; 
				float llen = length(ldir);
				if(llen>0) 
				{
					ldir/=llen;//-normalize(ldir);
					lcol/=llen*llen;
					float lum =   saturate(dot(ldir,lposn)) ;  

					sunTotal+= lum*lcol;
				}
			}


			///float rm = 0.002;
			///float rm2 = rm*0.76*4;
			///float3 bc1 = tDiffuseView.Sample(sCC, screenPosition);
			///float3 bc2 = ( bc1
			/// +tDiffuseView.Sample(sCC, screenPosition+float2(rm,rm))
			/// +tDiffuseView.Sample(sCC, screenPosition+float2(-rm,rm))
			/// +tDiffuseView.Sample(sCC, screenPosition+float2(-rm,-rm))
			/// +tDiffuseView.Sample(sCC, screenPosition+float2(rm,-rm))

			/// +tDiffuseView.Sample(sCC, screenPosition+float2(0,rm2))
			/// +tDiffuseView.Sample(sCC, screenPosition+float2(0,-rm2))
			/// +tDiffuseView.Sample(sCC, screenPosition+float2(-rm2,0))
			/// +tDiffuseView.Sample(sCC, screenPosition+float2(rm2,0))

			///)/9;
			
			//bc2 = float3(1,0,0);
			//bc1 = float3(0,1,0);   
			float2 noise = CloudNoise(input.tcrd);
			float4 clouds = tClouds.Sample(sCL, 
				input.tcrd
				+noise*0.001
				+float2(1,0)*time*0.00001
				)*float4(1,1,1,1); 
			
			
			float horisonangle = horisonDistanceLocal/length(planetpos);
			float topDot =saturate(dot(normalize(input.Pos),-normalize(planetpos))+horisonangle+0.05);
			float3 tBackColor =0;//lerp(bc1,bc2*0.4,saturate(clouds.a*4+0.2)*density*topDot)*0;  
			tBackColor = lerp(tBackColor,clouds*0.6*cloudColor,saturate(clouds.a*density));
	

			//float3 result = 
			//	saturate(dotpd*2)
			//	*(saturate(1-dotpd)+0.15)
			//	*sunTotal
			//	*atmosphereColor
			//	*density
			//	*topDot
			//;	

			if(cloudmul>=0)
			{
				float3 cloudcolor = saturate(cloudmul*2)*sunTotal*1.5;

	
			//	float horison = 1-topDot;

				ou.color = float4(cloudcolor,clouds.a*0.2*spTopDot);
				//ou.color = topDot;
			
			}
			else
			{ 
				ou.color = float4(saturate(tBackColor.xyz*0.5*sunTotal),saturate(tBackColor.x*5*topDot)*0.7*spTopDot);  
			}
		}
		else
		{
			//ou.color = float4(1,0,0,1);
			clip(-1);
		}
		return ou;//float4(result,1);  

	}
	else 
	{// 

		float dpdepth = input.Position.z/input.Position.w;
		float rpdepth =SS_GetDepth(screenPosition) 
			*sqrt(distanceMultiplier)/1000;// tDepthView.Sample(sCC, screenPosition).r;
		//if(rpdepth<0.0001) rpdepth = 1;
		//rpdepth = tDepthView.Sample(sCC, screenPosition).r/10;
	//	ou.color = float4(rpdepth*100,0,0,1);
	//	return ou;
		float density =saturate(rpdepth/horisonDistance*300000*1);///distanceMultiplier/100);
		// + (absheight/80000)
		float planetDist = length(planetpos)*distanceMultiplier;
		//density = density / max(1,absheight/80000);
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
			
			topDot = dot(input.Normal,normalize(planetpos))+horisonangle;
			
			sunPowerh1 = sunPowerh1 / max(1,liquidDepth*1);
			sunPowerh2 = sunPowerh2 / max(1,liquidDepth*5);
			sunPowerh3 = sunPowerh3 / max(1,liquidDepth*10);
			sunPowerh4 = sunPowerh4 / max(1,liquidDepth*100); 
			terrainLightDivider = 1;
		}
		else
		{
			 topDot = dot(input.Normal,normalize(planetpos))+horisonangle;
		}


		float3 normalAtHorison =-normalize(planetpos);// normalize(input.Pos*6/rpdepth-planetpos);
		float lightIntencity = 0;//saturate(dot(-normalAtHorison,ldir0)*20+0.2	);

		float atmdencityByDist = max(1,absheight/30000);
		
		topDot = topDot*atmdencityByDist;
		float horison = 1-abs(topDot);
		
		float3 sunTotal = float3(0,0,0);
		float3 totalLightColor = float3(0,0,0);
		[unroll]
		for(int i=0;i<6;i++)
		{
			float3 ldir =-pointlightPosition[i];
			float3 lcol = pointlightColor[i]; 
			float llen = length(ldir);
			if(llen>0) 
			{
				ldir/=llen;//-normalize(ldir);
				lcol/=llen*llen;
				if(i==0)
				{
				lcol -=(1-saturate(dot(-normalAtHorison,ldir)*5))*atmosphereColor*lcol*1.9
				//	*saturate(horison)*saturate(horison)*2
					;
					totalLightColor +=max(0,lcol);
				}//float ldsq = ldir.x*ldir.x+ldir.y*ldir.y+ldir.z*ldir.z;
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
		}
		lightIntencity = saturate(lightIntencity+0.2);
		
		//float ff = (1-saturate(dot(-normalAtHorison,ldir0)*5));
		//return float4(totalLightColor,1);
		 
		float starLumAmount =  density = density * lightIntencity;
		//return float4(totalLightColor,1);
		 
		float3 topColor = atmosphereColor*sunTotal/ atmdencityByDist;//*totalLightColor;
		float3 horisonColor = lerp(
			hazeColor*lerp(lcol0,totalLightColor,0.5)*0.5,
			hazeColor*totalLightColor,
			saturate(dot(input.Normal,ldir0)+0.1)+saturate(dot(-normalAtHorison,ldir0))
			);/// atmdencityByDist;
		float3 bottomColor = atmosphereColor;
		 // float3(0.93,0.62,0.5);
		//horisonColor=topColor+max(0,horisonColor);
		//return float4(sunTotal - atmosphereColor*saturate(horison)*saturate(horison),0.5);
		
		//return float4(horisonColor,1);
		if(isCameraUnderWater)
		{ 
			//float depth = max(1,-absheight/300);
			density = max(0.5,density); 
			//topColor=topColor*density;
			horisonColor = totalLightColor*float3(0.1,0.25,0.3)/2/max(1,liquidDepth);
			bottomColor = totalLightColor*float3(0.1,0.25,0.3)/2/max(1,liquidDepth); 
			//return density*float4((saturate(horison)+saturate(topDot))*horisonColor+saturate(-topDot)*bottomColor,1); 
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

		float3 additive = tBackColor.rgb 
		+ (topColor+atmosphereColor*totalLightColor+sunTotal)*density*angleDensity*1;//4

		float3 dust = (saturate(horison)+saturate(-topDot))*horisonColor;
					//+ saturate(topDot)*(tBackColor.rgb+topColor)
					//+saturate(topDot)*(topColor)
					//+sunTotal
		float light_dust_blend = saturate(horison)*saturate(density*angleDensity*3)/ max(1,atmdencityByDist/5) ;

		//	saturate(saturate(horison)+saturate(-topDot)+saturate(topDot)*0.9)*saturate(density*angleDensity*3);
//ou.color.rgb = additive;
//ou.color.a =1;
//return ou; 

		float4 result =  float4( lerp(additive,dust,light_dust_blend),1);
		// + float4(-tBackColor.rgb*5*(1-saturate(topDot)),0)
				

		//result =  float4(totalLightColor,1);
//result.a = saturate(1*density);
		/* //light decay 
	 	result.rgb =result.rgb
		 -topColor
		 *saturate((horison+horison*horison)*density*0.5)*
		 (1-saturate(density*angleDensity));
		*/

		//tBackColor =lerp(tBackColor,0, saturate(pow(horison,5)*density*10));
//return float4(result.a,result.a,result.a,1);
		//result = float4(lerp(tBackColor,result,result.a*0).rgb,1); 
		//ou.normal.r = 1;
		ou.mask.a = density*angleDensity;
		ou.color = result;//*0.5;
		return ou;//return result;
		//return lerp(tBackColor,float4(
		//		((saturate(horison)+saturate(-topDot))*horisonColor
		//		+saturate(topDot)*(tBackColor.rgb+topColor)
		//		+sunTotal
		//		)*0.5
		//		,1),density*angleDensity)
		//	
		//	; 
	}
	////float dpdepth = input.Position.z/input.Position.w;
	//float depth = saturate(1-tDepthView.Sample(sCC, screenPosition).r/dpdepth*0.1);
	//float depth2 = saturate(1-tDepthView.Sample(sCC, screenPosition).r/distanceMultiplier/dpdepth);//saturate(1-tDepthView.Sample(sCC, scpos).r/distanceMultiplier*10000);
	// 
	//float ff =  ((dpdepth - tDepthView.Sample(sCC, screenPosition).r/10));
	//if(ff<0) ff = 0.001; 
	//return ff*0.04;
	//ff = max(0,log(ff));
	////float4 rez = float4(depth,depth,depth,1);
	//float3 result = lum * atmodepth * float3(0.4,0.8,1);
	////result = float3(0.4,0.8,1);
	//return float4(result,length(result));
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