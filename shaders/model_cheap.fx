
#include "headers/enviroment.fxh"

float4x4 Projection;
float4x4 View;
float4x4 World;
float4x4 WorldInv;
 
float4x4 EnvInverse;

SamplerState MeshTextureSampler
{
    Filter = MIN_MAG_MIP_LINEAR;
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