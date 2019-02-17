
float3 hdr_ToLogScale(float3 lin,float minVal,float maxVal)
{
	return log10(minVal+lin*(minVal-maxVal));
}
float3 hdr_ToLogScaleU(float3 lin)
{
	return log10(lin);
}
float3 hdr_ToLinearScale(float3 logscale)
{
	return pow(10,logscale);
} 