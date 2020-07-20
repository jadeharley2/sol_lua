
float denoiseStrength = 3.0f;
Texture2D tTexture;   
Texture2D tNormal;   

float2 offset[25];
offset[0] = float2(-2,-2);
offset[1] = float2(-1,-2);
offset[2] = float2(0,-2);
offset[3] = float2(1,-2);
offset[4] = float2(2,-2);

offset[5] = float2(-2,-1);
offset[6] = float2(-1,-1);
offset[7] = float2(0,-1);
offset[8] = float2(1,-1);
offset[9] = float2(2,-1);

offset[10] = float2(-2,0);
offset[11] = float2(-1,0);
offset[12] = float2(0,0);
offset[13] = float2(1,0);
offset[14] = float2(2,0);

offset[15] = float2(-2,1);
offset[16] = float2(-1,1);
offset[17] = float2(0,1);
offset[18] = float2(1,1);
offset[19] = float2(2,1);

offset[20] = float2(-2,2);
offset[21] = float2(-1,2);
offset[22] = float2(0,2);
offset[23] = float2(1,2);
offset[24] = float2(2,2);


float kernel[25];
kernel[0] = 1.0f/256.0f;
kernel[1] = 1.0f/64.0f;
kernel[2] = 3.0f/128.0f;
kernel[3] = 1.0f/64.0f;
kernel[4] = 1.0f/256.0f;

kernel[5] = 1.0f/64.0f;
kernel[6] = 1.0f/16.0f;
kernel[7] = 3.0f/32.0f;
kernel[8] = 1.0f/16.0f;
kernel[9] = 1.0f/64.0f;

kernel[10] = 3.0f/128.0f;
kernel[11] = 3.0f/32.0f;
kernel[12] = 9.0f/64.0f;
kernel[13] = 3.0f/32.0f;
kernel[14] = 3.0f/128.0f;

kernel[15] = 1.0f/64.0f;
kernel[16] = 1.0f/16.0f;
kernel[17] = 3.0f/32.0f;
kernel[18] = 1.0f/16.0f;
kernel[19] = 1.0f/64.0f;

kernel[20] = 1.0f/256.0f;
kernel[21] = 1.0f/64.0f;
kernel[22] = 3.0f/128.0f;
kernel[23] = 1.0f/64.0f;
kernel[24] = 1.0f/256.0f;

float4 texelFetch()
float4 denoiser( float2 fragCoord ) 
{
    float splitCoord = (iMouse.x == 0.0) ? iResolution.x/2. + iResolution.x*cos(iTime*.5) : iMouse.x;
    if(fragCoord.x>splitCoord)
    { 
        return texelFetch(iChannel0, fragCoord, 0);
    }
    
    
    float4 sum = float4(0.0);
    float c_phi = 1.0;
    float n_phi = 0.5;
    //float p_phi = 0.3;
	float4 cval = tTexture.Sample( fragCoord);
	float4 nval = tNormal.Sample( fragCoord);
	//float4 pval = texelFetch(iChannel2, fragCoord, 0);
    
    float cum_w = 0.0;
    for(int i=0; i<25; i++)
    {
        float2 uv = fragCoord+offset[i]*denoiseStrength;
        
        float4 ctmp = tTexture.Sample(  uv);
        float4 t = cval - ctmp;
        float dist2 = dot(t,t);
        float c_w = min(exp(-(dist2)/c_phi), 1.0);
        
        float4 ntmp = tNormal.Sample( uv);
        t = nval - ntmp;
        dist2 = max(dot(t,t), 0.0);
        float n_w = min(exp(-(dist2)/n_phi), 1.0);
        
        //float4 ptmp = texelFetch(iChannel2, uv, 0);
        //t = pval - ptmp;
        //dist2 = dot(t,t);
        //float p_w = min(exp(-(dist2)/p_phi), 1.0);
        
        //float weight = c_w*n_w*p_w;
        float weight = c_w*n_w;
        sum += ctmp*weight*kernel[i];
        cum_w += weight*kernel[i];
    }
    if(fragCoord.x<splitCoord)
    {
        return sum/cum_w;
    }
    else
    {
        return cval;
    } 
}

struct VS_IN 
{
	float4 pos : SV_POSITION;
	float2 tcrd : TEXCOORD;
}; 
  

struct PS_IN
{ 
	float4 pos : SV_POSITION;
	float2 tcrd : TEXCOORD;
};

PS_IN VS( VS_IN input ) 
{
	PS_IN output = (PS_IN)0; 
	output.pos =  input.pos;
	output.tcrd = input.tcrd;
	return output;
} 


float4 PS( PS_IN input ) : SV_Target
{
    return denoiser(input.tcrd)  
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