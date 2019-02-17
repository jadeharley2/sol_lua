
bool clipenabled = false;
float4 clipplane;

void ClipProcess(float3 wpos)
{ 
	if(clipenabled)
	{
		float val = dot(clipplane.xyz,wpos)+clipplane.w;
		clip(val);
	}
}
