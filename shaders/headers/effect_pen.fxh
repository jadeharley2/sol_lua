
// search matrix.
float3x3 effect_pen_GX = float3x3( -1.0, 0.0, 1.0,
						-2.0, 0.0, 2.0,
						-1.0, 0.0, 1.0 );
float3x3 effect_pen_GY =  float3x3( 1.0,  2.0,  1.0,
						0.0,  0.0,  0.0,
						-1.0, -2.0, -1.0 );
float effect_pen_Process(Texture2D tTexture, SamplerState sSampler,float fWidth,float fHeight,float2 fTexCoord)
{  
				
	float4  fSumX = float4( 0.0,0.0,0.0,0.0 );
	float4  fSumY = float4( 0.0,0.0,0.0,0.0 );
	float4 fTotalSum = float4( 0.0,0.0,0.0,0.0 );
	float fXIndex = fTexCoord.x * fWidth;
	float fYIndex = fTexCoord.y * fHeight;
	// Gradient calculation.
	for(float I=-1.0; I<=1.0; I = I + 1.0)
	{
		for(float J=-1.0; J<=1.0; J = J + 1.0)
		{
			float fTempX = ( fXIndex + I + 0.5 ) / fWidth ;
			float fTempY = ( fYIndex + J + 0.5 ) / fHeight ;
			float4 fTempSumX = tTexture.Sample( sSampler, float2( fTempX, fTempY ));
			fSumX = fSumX + ( fTempSumX * float4( effect_pen_GX[(int)(I+1.0)][(int)(J+1.0)],
												effect_pen_GX[(int)(I+1.0)][(int)(J+1.0)],
												effect_pen_GX[(int)(I+1.0)][(int)(J+1.0)],
												effect_pen_GX[(int)(I+1.0)][(int)(J+1.0)]));
		}
	}  
	for(float I=-1.0; I<=1.0; I = I + 1.0)
	{
		for(float J=-1.0; J<=1.0; J = J + 1.0)
		{
			float fTempX = ( fXIndex + I + 0.5 ) / fWidth ;
			float fTempY = ( fYIndex + J + 0.5 ) / fHeight ;
			float4 fTempSumY = tTexture.Sample( sSampler, float2( fTempX, fTempY ));
			fSumY = fSumY + ( fTempSumY * float4( effect_pen_GY[(int)(I+1.0)][(int)(J+1.0)],
												effect_pen_GY[(int)(I+1.0)][(int)(J+1.0)],
												effect_pen_GY[(int)(I+1.0)][(int)(J+1.0)],
												effect_pen_GY[(int)(I+1.0)][(int)(J+1.0)]));
		}
	} 
	// Combine X Directional and Y Directional Gradient.
	float4 fTem = fSumX * fSumX + fSumY * fSumY;
	fTotalSum = sqrt( fTem );
	//return fTotalSum<0.8?0:1;
	return fTotalSum;
}