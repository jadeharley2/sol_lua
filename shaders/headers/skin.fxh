
bool SkinningEnabled = false;
float4x4 Bones[256];  
void Skin(inout float4 Position,inout float3 Normal,float4 Weights,int4 Indices)
{ 

	float4x3 skinning = (float4x3)transpose(
		 Bones[(int)Indices[0]] *  Weights.x 
		+Bones[(int)Indices[1]] *  Weights.y 
		+Bones[(int)Indices[2]] *  Weights.z
		+Bones[(int)Indices[3]] *  Weights.w ) ; 
		
    Position.xyz = mul(Position, skinning);
    Normal = mul(Normal, (float3x3)skinning);
}