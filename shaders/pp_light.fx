float pad=1;

float4x4 Projection;
float4x4 View;
float4x4 World;

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
        ComparisonFunc = LESS;
    };

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
            return   SampleForShadowInner(ShadowTexCoord,g_ShadowMap,bias*biasCascadeMul.x,smpos.z);
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
        return pos.xy/viewSize;//(pos.xy / pos.w) * 0.5 + 0.5;
    }
    float3 getNormal(float2 uv)
    {
        return tNormalView.Sample(sView, uv) * 2.0 - 1.0;
    }
    float3 getPos(float2 uv)
    {
        float depth =  tDepthView.Sample(sView, uv).x;
        depth = linearDepth(depth);
        return mul( float4(camera_fovaspect * (uv * 2.0 - 1.0) * depth, -depth,1),transpose(InvWVP)).xyz;
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
        position = mul(position, transpose(InvWVP));  
    
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

    float3 CookTorrance_GGX(float3 n, float3 l, float3 v, float roughness, float3 f0, float3 albedo) {
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
        float D = GGX_Distribution(NH, roug_sqr);
        float3 F = FresnelSchlick(f0, HV);

        //mix
        float3 specK = G*D*F*0.25/(NV+0.001);    
        float3 diffK = saturate(1.0-F);
        return max(0.0, albedo*diffK*NL/PI + specK);
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
	float4x4 VP =mul(transpose(View),transpose(Projection)); 
	float4 wpos = mul(input.pos,transpose(World));

	PS_IN output = (PS_IN)0; 
	output.pos =  mul(wpos,VP); 
	return output;
} 
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
float4 PS_PBR( PS_IN input ) : SV_Target
{   
    float2 uv = getUV(input.pos);
    float3 normal = getNormal(uv);
    float3 pos = SS_GetPosition(uv);
    float4 mask =  tMaskView.Sample(sView, uv);
	float3 surfcolor = tDiffuseView.Sample(sView, uv);
    //return float4(1,1,1,1);
   // surfcolor *=surfcolor;
	
	float base_subsurface_val = 0;
	float specular_power =  10; 
	float smoothness = mask.y;
	float roughness = 1-smoothness*0.5;
	float metallness = mask.z;
	float sheen = 1;  
	
	float3 light_direction = (lightPos-pos);
	float light_dist = length(light_direction); 

	float3 L = light_direction/light_dist;
	float3 V = normalize(camera_pos-pos);
	float3 N = normal;
	//float3 H = normalize(V+L);


//return float4(N,1)/200;
	//float roug_sqr = roughness*roughness;
	//float G = GGX_PartialGeometry(dot(N,V), roug_sqr) 
	//	* GGX_PartialGeometry(dot(N,L), roug_sqr);
//
	//float D = GGX_Distribution(dot(N,H), roughness*roughness);
// 
	float light_power = max(0,1/(light_dist*light_dist*distanceMultiplier*distanceMultiplier/1000000)/10000);
    float3 LIGHT = CookTorrance_GGX(normal,lightPos-pos,camera_pos-pos,roughness,
		0.24,//float3(0.24, 0.24, 0.24),
		surfcolor)*light_power*lightColor*lightIntensity;
 
    //eLIGHT = 1;
//return float4(pos,1);
    if (applyShadow) 
    {  
		float dotNL = saturate(dot(N,L));
        LIGHT *= saturate(SampleForShadow(float4(pos-camera_pos,1),dotNL))*dotNL; 
    }

	float3 output  = lerp(LIGHT,LIGHT*surfcolor,metallness); 
	//float3 specColor = 0;
	//float3 FK_summ = 0;
 	//float LOD_Aparam = ComputeLOD_AParam();
    //for (uint i=0; i<(uint)uSamplesCount; i++){
    //    float3 H = GGX_Sample(uHammersleyPts[i], roughness*roughness);
    //   // H = mul(H, HTransform);
    //    float3 LightDir = reflect(-V, H);
//
    //    float3 specK; 
    //    float pdf;
    //    float3 FK;
    //    specK = CookTorrance_GGX_sample(N, LightDir, V, roughness,float3(0.24, 0.24, 0.24), FK, pdf);
    //    FK_summ += FK;
    //    float LOD = ComputeLOD(LOD_Aparam, pdf, LightDir);
    //    float3 LightColor = tEnvView.SampleLevel(sView,LightDir.xyz , LOD).rgb;//*LightInt;
	//	// mul(LightDir.xyz, (float3x3)V_InverseMatrix)
    //    specColor += specK * LightColor;
    //}
//
//output = surfcolor*0.1;
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