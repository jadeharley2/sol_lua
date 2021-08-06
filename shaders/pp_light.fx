float pad=1;

float4x4 Projection;
float4x4 View;
float4x4 World;
float4x4 WorldInv;
float4x4 projWorld; 

float4x4 InvWVP;

float2 viewSize;

float3 lightPos = float3(0,0,0);
float3 lightColor=float3(1,1,1);
float lightIntensity = 1;
// lightInvRange = 1.0 / light_radius^2 
uniform float lightInvRange=5;

float3 camera_pos;
float camera_near=0.1;
float camera_far=100;
float camera_fovaspect;
// camera_fovaspect.x = tan(fov / 2.0) * aspect;
// camera_fovaspect.y = tan(fov / 2.0);
float3 freshnelRanges = float3(0.5,0.75,1);
float distanceMultiplier=1;

float2 uHammersleyPts[16];
float PI = 3.1415926;

Texture2D tDiffuseView;     
Texture2D tNormalView;     
Texture2D tDepthView;      
Texture2D tMaskView;   
    
TextureCube tEnvView;   

bool isspotlight;
float4x4 projWorld2=0;
Texture2D tProjected;    
float4 pad2=1;
float pad3=1;
SamplerState sView
{
    Filter = MIN_MAG_MIP_POINT;//MIN_MAG_MIP_LINEAR;
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
struct PS_IN
{ 
	float4 pos : SV_POSITION; 
	float norm : TEXCOORD; 
	float wdp : TEXCOORD1; 
}; 



//######## SHADOWS ########
    bool applyShadow;
    Texture2D g_ShadowMap;   
    Texture2D g_ShadowMap_c2;   
    Texture2D g_ShadowMap_c3;   
    float4x4 ShadowMapVPMatrix;
    float4x4 ShadowMapVPMatrix_c2;
    float4x4 ShadowMapVPMatrix_c3;

    // for 4096px shadowmap
    //#define SHADOWWARP_ENABLED
    float dshift = 0.0001;
    float dshiftdg = 0.00007071; 
    float bias_base =0;
    float bias_slopemul =0.00001;
    float3 biasCascadeMul = float3(1,6,36);

    SamplerComparisonState ShadowSampler
    {
        // sampler state
        Filter = COMPARISON_MIN_MAG_LINEAR_MIP_POINT;
        AddressU = CLAMP;
        AddressV = CLAMP;

        // sampler comparison state
        ComparisonFunc = GREATER;
    };

    float GetIsInViewMatrix(float4 worldposition, float4x4 viewProj)
    {
        float4 smpos = mul(worldposition,ShadowMapVPMatrix); 
        if(smpos.x>-1&&smpos.x<1&&smpos.y>-1&&smpos.y<1)
        {
            return 1;
        }
        else 
        {
            smpos = mul(worldposition,ShadowMapVPMatrix_c2); 
            if(smpos.x>-1&&smpos.x<1&&smpos.y>-1&&smpos.y<1)
            { 
                return 2;
            }
            else
            {
                smpos = mul(worldposition,ShadowMapVPMatrix_c3); 
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
    float3 ShadowViewIndex(float4 worldposition, float4x4 viewProj)
    {
        float4 smpos = mul(worldposition,ShadowMapVPMatrix); 
        if(smpos.x>-1&&smpos.x<1&&smpos.y>-1&&smpos.y<1)
        {
            return float3(1,0,0);
        }
        else 
        {
            smpos = mul(worldposition,ShadowMapVPMatrix_c2); 
            if(smpos.x>-1&&smpos.x<1&&smpos.y>-1&&smpos.y<1)
            { 
                return float3(0,1,0);
            }
            else
            {
                smpos = mul(worldposition,ShadowMapVPMatrix_c3); 
                if(smpos.x>-1&&smpos.x<1&&smpos.y>-1&&smpos.y<1)
                { 
                    return float3(0,0,1);
                }
                else
                {
                    return float3(1,1,1);
                }
            }
        } 
    }
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
        vis +=g_ShadowMap.SampleCmp(ShadowSampler, ShadowTexCoord+poissonDisk[i]*dshift,depth+bias)*0.25;
        }
        return vis;  
    }

    float  SampleForShadow(float4 worldposition,float dotNL)
    { 
        float camdist = max(1,pow(length(worldposition.xyz)*100,4)/100);
        //bias = 0.0001*tan(acos(dotNL)); 
        float bias =0.000001f;// 
       // bias_base  + bias_slopemul;//*tan(acos(dotNL));//*camdist; 
        // dotNL is dot( n,l ), clamped between 0 and 1
        bias = clamp(bias, 0,0.01); 

        //ShadowMap matrix VP space depth  
        float4 smpos = mul(worldposition,ShadowMapVPMatrix);
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
            return   SampleForShadowInner(ShadowTexCoord,g_ShadowMap,bias*biasCascadeMul.x,smpos.z);
        }
        else 
        {
            smpos = mul(worldposition,ShadowMapVPMatrix_c2); 
            if(smpos.x>-1&&smpos.x<1&&smpos.y>-1&&smpos.y<1)
            {
                ShadowTexCoord = float2(0.5,-0.5) * smpos.xy /  smpos.w + float2( 0.5, 0.5 ); 
                return SampleForShadowInner(ShadowTexCoord,g_ShadowMap_c2,bias*biasCascadeMul.y,smpos.z);
            }
            else
            {
                smpos = mul(worldposition,ShadowMapVPMatrix_c3); 
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
     
//######## SHADOWS END ########



//######## TOOLS ########

    float linearDepth(float depth)
    {
        return 2.0 * camera_near * camera_far /
                (camera_far + camera_near -
                (depth * 2.0 - 1.0) * (camera_far - camera_near));
    }
    float2 getUV(float4 pos)
    {
        return pos.xy/viewSize;
        //float2 pre = pos.xy/viewSize*float2(0.5,1);
        //return float2(0.5-pre.x,pre.y);//(pos.xy / pos.w) * 0.5 + 0.5;
    }
    float3 getNormal(float2 uv)
    {
        return tNormalView.Sample(sView, uv) * 2.0 - 1.0;
    }
    float3 getPos(float2 uv)
    {
        float depth =  tDepthView.Sample(sView, uv).x;
        depth = linearDepth(depth);
        return mul( float4(camera_fovaspect * (uv * 2.0 - 1.0) * depth, -depth,1),InvWVP).xyz;
    }
    float3 SS_GetPosition(float2 UV)
    {
        float depth =  tDepthView.Sample(sView, UV).x;
        float4 position = 1.0f; 
    
        position.x = UV.x * 2.0f - 1.0f; 
        position.y = -(UV.y * 2.0f - 1.0f); 

        position.z = depth; 
    //position.w = 1;
        //Transform Position from Homogenous Space to World Space 
        position = mul(position, InvWVP);  
    
        //position *= position.w;
        position /= position.w;

        return position.xyz;
    }

    float attenuation(float3 pos)
    {
        float3 direction = lightPos - pos;
        float value = dot(direction, direction) * lightInvRange;
        float invlvl = length(direction);

        return min(1,1.0/(invlvl*invlvl)/100000);//1.0 - clamp(value, 0.0, 1.0);
    }

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

//######## TOOLS END ########

//######## PBR ########
    float GGX_PartialGeometry(float cosThetaN, float alpha) {
        float cosTheta_sqr = saturate(cosThetaN*cosThetaN);
        float tan2 = ( 1 - cosTheta_sqr ) / cosTheta_sqr;
        float GP = 2 / ( 1 + sqrt( 1 + alpha * alpha * tan2 ) );
        return GP;
    }
    float GGX_Distribution(float cosThetaNH, float alpha) {
        float alpha2 = alpha * alpha;
        float NH_sqr = saturate(cosThetaNH * cosThetaNH);
        float den = NH_sqr * alpha2 + (1.0 - NH_sqr);
        return alpha2 / ( PI * den * den );
    }
    float3 GGX_Sample(float2 E, float alpha) {
        float Phi = 2.0*PI*E.x;
        float cosThetha = saturate(sqrt( (1.0 - E.y) / (1.0 + alpha*alpha * E.y - E.y) ));
        float sinThetha = sqrt( 1.0 - cosThetha*cosThetha);
        return float3(sinThetha*cos(Phi), sinThetha*sin(Phi), cosThetha);
    }

    float3 FresnelSchlick(float3 F0, float cosTheta) {
        return F0 + (1.0 - F0) * pow(1.0 - saturate(cosTheta), 5.0);
    }

    float sqr(float x)
    {
        return x*x;
    }

    float GTR2_aniso(float NdH, float HdX, float HdY, float ax, float ay)
    {
        return 1.0f / (PI * ax*ay * sqr(sqr(HdX/ax) + sqr(HdY/ay) + NdH*NdH));
    }


    float3 CookTorrance_GGX(float3 n, float3 l, float3 v, float roughness, half subsurface_coeff, float3 f0, float3 albedo) {
        n = normalize(n*float3(0.1,0.1,0.1));
        v = normalize(v);
        l = normalize(l);
        float3 h = normalize(v+l);
        //precompute dots
        float NL1 = saturate(dot(n, l)); //default
        float NL2 = pow(dot(n, l)/2+0.5,2);//halflambert mod
        float NL = lerp(NL1,NL2,subsurface_coeff);// diffuse intencity
        if (NL <= 0.01) NL=0.01;//return 0.0;
        float NV = dot(n, v);  //normal*view dot
        if (NV <= 0.01) NV = 0.01;//return 0.2;
        float NH = dot(n, h); //
        float HV = dot(h, v);
        
        //precompute roughness square
        float roug_sqr = roughness*roughness;
        
        //calc coefficients
        float G = GGX_PartialGeometry(NV, roug_sqr) * GGX_PartialGeometry(NL, roug_sqr);
        float D = GGX_Distribution(NH, roug_sqr);
        float3 F = FresnelSchlick(f0, HV); //0.25



        //mix
        float3 specK = G*D*F*0.25/(NV+0.001);    
        float3 diffK = saturate(1.0-F);
        return  max(0.0, albedo*diffK*saturate(NL)/PI + specK*saturate(NL));
    }

    float3 CookTorrance_GGX_sample(float3 n, float3 l, float3 v, float roughness, float3 f0, out float3 FK, out float pdf) {
        n = normalize(n);
        v = normalize(v);
        l = normalize(l);
        float3 h = normalize(v+l);
        //precompute dots
        float NL = dot(n, l);
        if (NL <= 0.0) return 0.0;
        float NV = dot(n, v);
        if (NV <= 0.0) return 0.0;
        float NH = dot(n, h);
        float HV = dot(h, v);
        
        //precompute roughness square
        float roug_sqr = roughness*roughness;
        
        //calc coefficients
        float G = GGX_PartialGeometry(NV, roug_sqr) * GGX_PartialGeometry(NL, roug_sqr);
        float3 F = FresnelSchlick(f0, HV);
        FK = F;
        
        float D = GGX_Distribution(NH, roug_sqr);
        pdf = D*NH/(4.0*HV); 

        float3 specK = G*F*HV/(NV*NH);
        return max(0.0, specK);
    }

    int uSamplesCount = 16;
    float ComputeLOD_AParam(){
        float w=1, h=1;
        //uRadiance.GetDimensions(w, h);
        return 0.5*log2(w*h/uSamplesCount);
    }
    float ComputeLOD(float AParam, float pdf, float3 l) {
        float du = 2.0*1.2*(abs(l.z)+1.0);
        return max(0.0, AParam-0.5*log2(pdf*du*du)+1.0);
    }

//######## PBR END ########

PS_IN VS( VS_IN input ) 
{
	float4x4 VP =mul(View,Projection); 
	float4 wpos = mul(input.pos,World);

	PS_IN output = (PS_IN)0; 
	output.pos =  mul(wpos,VP); 
    float3 xnrm = mul(input.norm,(float3x3)World);
    output.wdp = length(wpos.xyz);
    output.norm = dot(normalize(xnrm),(wpos.xyz)/output.wdp);
	return output;
} 
/*
float4 PS( PS_IN input ) : SV_Target
{  
	//return float4(1,1,1,1);
	//return float4(input.pos.xy/viewSize,0,1);
    float2 uv = getUV(input.pos);
    float3 normal = getNormal(uv);
    float3 pos = SS_GetPosition(uv);
    float4 mask =  tMaskView.Sample(sView, uv);
	float3 surfcolor = tDiffuseView.Sample(sView, uv);
    ///	//return  linearDepth(tDepthView.Sample(sView, uv).x)*100;
    ///	//return float4(pos*100,1);
    ///	//return float4(normalize(camera_pos-pos),1);
    ///    float att = attenuation(pos);
    ///
    ///    float3 lightdir = normalize(lightPos - pos);
    ///    float diffuseIntensity = dot(normal, lightdir) * att+att*0.3;
    ///
    ///    float3 reflectdir = reflect(lightdir, normal);
    ///	float shininess = 10*mask.y;//stub
    ///    float spec = pow(clamp(dot(normalize(pos-camera_pos), reflectdir), 0.0, 1.0), shininess);
    ///
    ///  
    ///    return float4(diffuse * (lightIntensity + spec*mask.y) * diffuseIntensity*lightColor,1)*mask.x;


	float base_subsurface_val = 0;
	float specular_power =  10; 
	float smoothness = mask.y;
	float metallness = mask.z;
	float sheen = 1; 

	float3 position = pos;
	float3 light_pos = lightPos;
	float3 light_col = lightColor;
	float3 camdir = normalize(pos-camera_pos);


	float3 light_direction = (light_pos-position);
	float light_dist = length(light_direction); 
	light_direction/=light_dist;
	float3 light_reflection = reflect(light_direction,normal); 
	float cam_angle = saturate(dot(-normalize(position),normal)); 
		
	float light_power = 1/(light_dist*light_dist);
	float diffuse_intencity = max(base_subsurface_val,saturate(dot(normal,light_direction)));
	float specular_intencity = pow(saturate(dot(light_reflection,camdir)),specular_power)*Fresnel(cam_angle);
	
	float3 diffuse = surfcolor * saturate(1-smoothness) * diffuse_intencity;
	float3 specular =  sheen * specular_intencity * lerp(float3(1,1,1),surfcolor,metallness);
		//saturate(smoothness) *
	float3 lresult = ((diffuse + specular)* light_col * light_power)/500000;
	return float4(lresult,1)*mask.x;

}
*/
float3 Hue(float H)
{
    float R = abs(H * 6 - 3) - 1;
    float G = 2 - abs(H * 6 - 2);
    float B = 2 - abs(H * 6 - 4);
    return saturate(float3(R,G,B));
}
float3 HSVtoRGB(in float3 HSV)
{
    return ((Hue(HSV.x) - 1) * HSV.y + 1) * HSV.z;
}

float3 RGBtoHSV(in float3 RGB)
{
    float3 HSV = 0;
    HSV.z = max(RGB.r, max(RGB.g, RGB.b));
    float M = min(RGB.r, min(RGB.g, RGB.b));
    float C = HSV.z - M;
    if (C != 0)
    {
        HSV.y = C / HSV.z;
        float3 Delta = (HSV.z - RGB) / C;
        Delta.rgb -= Delta.brg;
        Delta.rg += float2(2,4);
        if (RGB.r >= HSV.z)
            HSV.x = Delta.b;
        else if (RGB.g >= HSV.z)
            HSV.x = Delta.r;
        else
            HSV.x = Delta.g;
        HSV.x = frac(HSV.x / 6);
    }
    return HSV;
}
float4 PS_PBR( PS_IN input ) : SV_Target
{     
    //return 0;
    float2 uv = getUV(input.pos);
	//return float4(uv/viewSize,0,1)*0.1;

    float3 normal = getNormal(uv);
    float3 pos = SS_GetPosition(uv);
    float4 mask =  tMaskView.Sample(sView, uv);
	float3 surfcolor = tDiffuseView.Sample(sView, uv);
    
    float ndot =input.norm*input.norm*20;
   // return float4(float3(1,1,1)*saturate(input.wdp),0.1);
    //return float4(ndot,ndot,ndot,0.11);
     //return float4( g_ShadowMap_c3.Sample(sView, uv).r/2*float3(1,1,1),1);
   // surfcolor *=surfcolor;
	
	float base_subsurface_val = 0;
	float specular_power =  10; 
	float smoothness = mask.y;
	float roughness = saturate(1-smoothness*0.95);//*0.5;
	float metallness = mask.z;
    half subsurface_coeff = mask.a;
	//half sheen = 1;  
	
	float3 light_direction = (lightPos-pos);
	float light_dist = length(light_direction); 

	float3 L = light_direction/light_dist;
	float3 V = normalize(camera_pos-pos);
	float3 N = normal;
	//float3 H = normalize(V+L);


//return float4(N,1)/200;

// 
	float light_power = saturate(ndot)*saturate(input.wdp*20)*3*
     max(0,1/(light_dist*light_dist*distanceMultiplier*distanceMultiplier/1000000)/10000);
    

    float3 LIGHT = CookTorrance_GGX(normal,lightPos-pos,camera_pos-pos,roughness,subsurface_coeff,
		saturate(metallness),//saturate((smoothness+metallness)*0.75),//float3(0.24, 0.24, 0.24),
		surfcolor)*lightColor*lightIntensity;
     
     
    //eLIGHT = 1;
//return float4(LIGHT,1);
    float dotNL = saturate(dot(N,L));
    if ( applyShadow) 
    {  
        
		float dotNLS = min(dotNL,0.99);
        float4 pp = float4(pos-camera_pos,1);
              
        LIGHT *= saturate(SampleForShadow(pp,dotNLS));//*dotNL; 
        //LIGHT *= ShadowViewIndex(pp,dotNLS);
          
    }
    if (isspotlight)
    {
        float3 invpos = mul(float4( pos,1),WorldInv).xyz;
        float3 lpos = invpos;
           // mul(float4(pos,1),transpose(projWorld)).xyz; 

        lpos.yz/=lpos.x;
        float intensity =saturate( sqrt(lpos.y*lpos.y+lpos.z*lpos.z));
        
      //  LIGHT *= saturate(100*pow(dot(smpos*100,float3(1,0,0)),1));
        float inte =saturate(1-length(lpos.yz))*saturate(lpos.x);
         
        LIGHT*=10*inte*light_power
        ;
    }
    else
    {
        LIGHT *=saturate(light_power/100)*100;
        //LIGHT *=light_power;
    }
    //LIGHT = LIGHT*float3(1,0,0);

    //if(light_power!=light_power){
    //    light_power =10;//  -light_power;
    //}
    //float3 hsv = RGBtoHSV(LIGHT);
    //hsv.z = round( hsv.z/5)*5;
    //LIGHT = HSVtoRGB(hsv);
  //  return float4(light_power,light_power,light_power,1)*10000000*mask.x;
	float3 output  = lerp(LIGHT,LIGHT*surfcolor,metallness); 
    
	return float4(output,1)*mask.x*0.1;

}


technique10 Render
{
	pass P0
	{
		SetGeometryShader( 0 );
		SetVertexShader( CompileShader( vs_4_0, VS() ) );
		SetPixelShader( CompileShader( ps_4_0, PS_PBR() ) );
	}
}