
float4 pointlightPosition[12];
float4 pointlightColor[12]; 
int shadowid;

float speculardarkenmul = 1;

Texture2D g_ShadowMap;   
Texture2D g_ShadowMap_c2;   
Texture2D g_ShadowMap_c3;   
float4x4 ShadowMapVPMatrix;
float4x4 ShadowMapVPMatrix_c2;
float4x4 ShadowMapVPMatrix_c3;

float3 freshnelRanges = float3(0.5,0.75,1);

float3 biasCascadeMul = float3(1,6,36);
float base_subsurface_val = 0;//

bool nodarkenspec = false;

SamplerState ShadowMapSampler
{
    Filter = MIN_MAG_MIP_POINT;//MIN_MAG_MIP_LINEAR;
    AddressU = Clamp;
    AddressV = Clamp;
};

float Fresnel(float cangle)
{
	if (cangle <0.5)
	{
		return freshnelRanges.z*(1-cangle*2) + freshnelRanges.y*(cangle*2);
	}
	else
	{	
		return freshnelRanges.y*(1-(cangle*2-1)) + freshnelRanges.x*(cangle*2-1);
	}
}
float3 LightUp(float3 normal, float3 lightdir,float3 lightcolor)
{
	float diffuse_intensity = dot(normal,lightdir);
	
	return saturate(diffuse_intensity*lightcolor);
}
float3 LightUpReflective(float3 normal,float3 cameradir, float3 lightdir,float3 lightcolor,float reflectivity)
{
	float diffuse_intencity = dot(normal,lightdir);
	float reflect_intencity =dot( reflect(cameradir,normal),lightdir);
	return saturate(diffuse_intencity*lightcolor
	+reflectivity*reflect_intencity*saturate(lightcolor*2));
}
float3 LightDiffuse(float3 lightcolor,float intencity)
{  
	float realcolor = (lightcolor.r+lightcolor.g+lightcolor.b)/3;
	return float3(
	lightcolor.r+(realcolor-lightcolor.r)*intencity,
	lightcolor.g+(realcolor-lightcolor.g)*intencity,
	lightcolor.b+(realcolor-lightcolor.b)*intencity
	) ;
}
float3 LightDegradation(float3 lightcolor,float waveshift)
{
	return saturate(lightcolor-float3(0.1,0.3,0.5)*waveshift);
}
void LightUpPlanet(// float3 tex, float alpha,float tex_diffuse,
float3 normal,float3 cameradir, float3 lightdir,float3 lightcolor,
float atm_transparency,float atm_refraction,float surface_reflectivity,float surface_reflection_power,
out float3 out_d, out float3 out_s
)
{
	float diffuse_intensity = dot(normal,lightdir)+atm_refraction;
	float reflect_intensity =pow(saturate(dot( reflect(lightdir,normal),cameradir)),surface_reflection_power);

	float degradation = atm_transparency/ (diffuse_intensity*diffuse_intensity);

	float3 lightdegraded =LightDegradation(lightcolor,degradation);


	//return tex*
	
		//(LightDiffuse( 
	out_d=	saturate(diffuse_intensity*lightdegraded)
		//,tex_diffuse)*alpha)
	// +
	;out_s= 
	//LightDiffuse( 
	saturate( reflect_intensity*surface_reflectivity*lightdegraded)
	 //,tex_diffuse)*alpha
	 ;
}

float depth_mul = 1;
float depth_divider = 256;

float depth_shadow_bendadd = 1;

float3 DepthEncode(float depth)
{
	depth = depth * depth_mul;
	float3 result = float3((depth*depth_divider*depth_divider)%1,depth,depth);
	result.y = ((depth*depth_divider*depth_divider - result.x)/depth_divider)%1;
	result.z = (((depth*depth_divider*depth_divider - result.x)/depth_divider-result.y)/depth_divider)%1;
	
	return result;
}
float DepthDecode(float3 depth)
{
	return (depth.x/depth_divider/depth_divider+depth.y/depth_divider+depth.z)/depth_mul;
}

// for 4096px shadowmap
//#define SHADOWWARP_ENABLED
float dshift = 0.0001;
float dshiftdg = 0.00007071; 
float bias_base =0;
float bias_slopemul =0.00001;

float GetIsInViewMatrix(float4 worldposition, float4x4 viewProj)
{
	float4 smpos = mul(worldposition,transpose(ShadowMapVPMatrix)); 
	if(smpos.x>-1&&smpos.x<1&&smpos.y>-1&&smpos.y<1)
	{
		return 1;
	}
	else 
	{
		smpos = mul(worldposition,transpose(ShadowMapVPMatrix_c2)); 
		if(smpos.x>-1&&smpos.x<1&&smpos.y>-1&&smpos.y<1)
		{ 
			return 2;
		}
		else
		{
			smpos = mul(worldposition,transpose(ShadowMapVPMatrix_c3)); 
			if(smpos.x>-1&&smpos.x<1&&smpos.y>-1&&smpos.y<1)
			{ 
				return 3;
			}
			else
			{
				return 0;
			}
		}
	} 
}

SamplerComparisonState ShadowSampler
{
   // sampler state
   Filter = COMPARISON_MIN_MAG_LINEAR_MIP_POINT;
   AddressU = CLAMP;
   AddressV = CLAMP;

   // sampler comparison state
   ComparisonFunc = LESS;
};
float2 poissonDisk[4] = {
  float2( -0.94201624, -0.39906216 ) ,
  float2( 0.94558609, -0.76890725 ) ,
  float2( -0.094184101, -0.92938870 ) ,
  float2( 0.34495938, 0.29387760 ) 
};
float  SampleForShadowInner(float2 ShadowTexCoord,Texture2D g_ShadowMap,float bias,float depth)
{  
	float vis =0;
	[unroll]
	for (int i=0;i<4;i++)
	{
	  vis +=g_ShadowMap.SampleCmp(ShadowSampler, ShadowTexCoord+poissonDisk[i]*dshift,depth-bias)*0.25;
	}
	return vis;  
}

float  SampleForShadow(float4 worldposition,float dotNL)
{ 
	float camdist = max(1,pow(length(worldposition.xyz)*100,4)/100);
	//bias = 0.0001*tan(acos(dotNL)); 
	float bias = bias_base + bias_slopemul*tan(acos(dotNL));//*camdist; 
	// dotNL is dot( n,l ), clamped between 0 and 1
	bias = clamp(bias, 0,0.01); 

	//ShadowMap matrix VP space depth  
	float4 smpos = mul(worldposition,transpose(ShadowMapVPMatrix));
	///////////////////////////////////
	#ifdef SHADOWWARP_ENABLED
		smpos.x=smpos.x/(abs(smpos.x)+depth_shadow_bendadd);
		smpos.y=smpos.y/(abs(smpos.y)+depth_shadow_bendadd);
	#endif
	///////////////////////////////////
	//if(ShadowTexCoord.x<=0||ShadowTexCoord.y<=0||ShadowTexCoord.x>=1||ShadowTexCoord.y>=1) return 9e20;
	
	float2 ShadowTexCoord = float2(0.5,-0.5) * smpos.xy /  smpos.w + float2( 0.5, 0.5 );
	
	if(smpos.x>-1&&smpos.x<1&&smpos.y>-1&&smpos.y<1)
	{
		return SampleForShadowInner(ShadowTexCoord,g_ShadowMap,bias*biasCascadeMul.x,smpos.z);
	}
	else 
	{
		smpos = mul(worldposition,transpose(ShadowMapVPMatrix_c2)); 
		if(smpos.x>-1&&smpos.x<1&&smpos.y>-1&&smpos.y<1)
		{
			ShadowTexCoord = float2(0.5,-0.5) * smpos.xy /  smpos.w + float2( 0.5, 0.5 ); 
			return SampleForShadowInner(ShadowTexCoord,g_ShadowMap_c2,bias*biasCascadeMul.y,smpos.z);
		}
		else
		{
			smpos = mul(worldposition,transpose(ShadowMapVPMatrix_c3)); 
			if(smpos.x>-1&&smpos.x<1&&smpos.y>-1&&smpos.y<1)
			{
				ShadowTexCoord = float2(0.5,-0.5) * smpos.xy /  smpos.w + float2( 0.5, 0.5 );  
				return SampleForShadowInner(ShadowTexCoord,g_ShadowMap_c3,bias*biasCascadeMul.z,smpos.z);
			}
		}
	} 
	
	return 1;
	//return smdepth.xyz;
}
//float3 Lightbleed(float3 colintensity)
//{
//	float power = length(colintensity);
//	float3 colordist = colintensity/power;
//	return colintensity +  saturate(float3(0.1,0.1,0.1)+colordist)*power/10;
//}
float3 Lightbleed(float3 colintensity)
{
	return colintensity;
	float3 bleed = max(float3(0,0,0),colintensity-float3(1,1,1));
	float amount = bleed.x+bleed.y+bleed.z ; 
	return colintensity;//(colintensity-bleed) + float3(0.333*amount,0.333*amount,0.333*amount) ;
}
float3 ApplyPointLights(float3 position, float3 normal, float3 camdir,
	float specular_intencity, float specular_power = 10,
	bool applyShadow = false,bool applyAmbient = true 
	)
{
	//diffuse + specular = 1
	
	//return float3(smf,smf,smf);
	
	float3 result = float3(0,0,0);
	[unroll]
	for(int i=0;i<12;i++)
	{
		float3 lpos = pointlightPosition[i];
		float3 lcol = pointlightColor[i];
		float3 direction = (lpos-position);
		float ldist = length(direction); direction/=ldist;
		
		float dotNL = max(base_subsurface_val,saturate(dot(normal,direction)));
		
		float diffuse =  dotNL;
		if(!nodarkenspec)
		{
			diffuse = diffuse * saturate(1-specular_intencity*speculardarkenmul);
		} 
		
		float3 reflection = reflect(direction,normal); 
		float  smf = 1;
		if(i==shadowid)
		{
			if (applyShadow) 
			{ 
				//{
					smf = saturate(SampleForShadow(float4(position,1),dotNL))*dotNL;
				//}
			}
			//smf =0;
		}
		
		float3 ambient = 0;
		if (applyAmbient) 
		{
			ambient = lcol * (1/(ldist*ldist))*0.2;
		} 
		float cmangle = saturate(dot(-normalize(position),normal)); 
		 
		float3 specular = saturate(specular_intencity) * pow(saturate(dot(reflection,camdir)),specular_power)*Fresnel(cmangle);
		
		if(i==shadowid)
		{ 
			//specular =  specular * saturate(smf); 
		}
		float3 lresult = ambient + Lightbleed(lcol * (diffuse + specular) * (1/(ldist*ldist))) ;
		if(i==shadowid)
		{ 
			lresult = lresult*smf;
			//lresult= smf;
		}
		//else
		//{ 
		//	lresult = 0;
		//}
		result += lresult;
	}
	return result;//
} 

float3 ApplyPointLights2(float3 position, float3 normal, float3 camdir, float3 surfcolor,
	float smoothness = 0, float metallness = 0, float sheen = 0, float specular_power = 10,
	bool applyShadow = false)
{
	//diffuse + specular = 1
	
	//return float3(smf,smf,smf);
	float smf = 1;
	if(shadowid>=-1)
	{
		float3 light_pos = pointlightPosition[shadowid];
		float3 light_col = pointlightColor[shadowid];
		float3 light_direction = (light_pos-position);
		float light_dist = length(light_direction); 
		light_direction/=light_dist;
		float diffuse_intencity = saturate(dot(normal,light_direction));
		smf = saturate(SampleForShadow(float4(position,1),diffuse_intencity))*diffuse_intencity;  
	}
	
	float3 result = float3(0,0,0);
	[unroll]
	for(int i=0;i<12;i++)
	{
		float3 light_pos = pointlightPosition[i];
		float3 light_col = pointlightColor[i];
		float3 light_direction = (light_pos-position);
		float light_dist = length(light_direction); 
		light_direction/=light_dist;
		float3 light_reflection = reflect(light_direction,normal); 
		float cam_angle = saturate(dot(-normalize(position),normal)); 
		 
		float light_power = 1/(light_dist*light_dist);
		float diffuse_intencity = max(base_subsurface_val,saturate(dot(normal,light_direction)));
		float specular_intencity = pow(saturate(dot(light_reflection,camdir)),specular_power)*Fresnel(cam_angle);
		
		float3 diffuse = saturate(1-smoothness) * diffuse_intencity;
		float3 specular =  sheen * specular_intencity * lerp(float3(1,1,1),surfcolor,metallness);
		 //saturate(smoothness) *
		float3 lresult = ((diffuse + specular)* light_col * light_power);
		
		//float  smf = 1;
		if(applyShadow && i==shadowid)
		{ 
			//smf = saturate(SampleForShadow(float4(position,1),diffuse_intencity))*diffuse_intencity; 
			
			result += lresult*smf; 
		}
		else
		{
			result += lresult;
		}
		
		//Lightbleed
	}
	return result;//
} 

 