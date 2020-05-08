
TextureCube g_EnvTexture; 
TextureCube g_EnvTexture_prev;

float envBlendAmount; 

SamplerState EnvSampler
{
    Filter = MIN_MAG_MIP_LINEAR;
    AddressU = Wrap;
    AddressV = Wrap;
};

float3 EnvSample(float3 dir)
{ 
	float3 sample_a = g_EnvTexture.Sample(EnvSampler,dir);
	float3 sample_b = g_EnvTexture_prev.Sample(EnvSampler,dir);
	return lerp(sample_a,sample_b,envBlendAmount);
}
float3 EnvSampleLevel(float3 dir,float specular)
{
	float miplevel = (1-saturate(specular))*20;
	float3 sample_a = g_EnvTexture.SampleLevel(EnvSampler,dir,miplevel);
	float3 sample_b = g_EnvTexture_prev.SampleLevel(EnvSampler,dir,miplevel);
	return lerp(sample_a,sample_b,envBlendAmount);
}