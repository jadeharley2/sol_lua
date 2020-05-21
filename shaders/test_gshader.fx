
float4x4 Projection;
float4x4 View;
float4x4 World;

float Explode = -0.3;

//float4 datat[512];//8^3

Texture3D<float4> g_Data;       

 

struct VS_IN
{
	float4 Pos : POSITION;
    float3 Norm : NORMAL; 
    float2 Tex : TEXCOORD0;
};


struct GSPS_INPUT
{
    float4 Pos : SV_POSITION;
    float3 Norm : TEXCOORD0;
    float2 Tex : TEXCOORD1;
};
 
//struct PS_IN
//{ 
//	float4 pos : SV_POSITION;
//	float2 tcrd : TEXCOORD0;
//    float3 norm : TEXCOORD1; 
//};
//


float GetD(int x,int y,int z)
{
	float4 data = g_Data.Load(int4(x,y,z,0),0);
	return data.x+data.y+data.z+data.w;
	//return datat[x+y*8+z*64];
}
void Plane( inout TriangleStream<GSPS_INPUT> TriStream,float4x4 mx, float3 p1,float3 p2,float3 p3,float3 p4)
{ 
    GSPS_INPUT outputA;
    GSPS_INPUT outputB;
    GSPS_INPUT outputC;
    GSPS_INPUT outputD;
	float3 N =normalize( cross(p1-p2,p1-p3));
	
	outputA.Pos =  mul(float4(p1,1),mx);
	outputA.Norm = N;
	outputA.Tex = float2(0,0);
	outputB.Pos =  mul(float4(p2,1),mx);
	outputB.Norm = N;
	outputB.Tex = float2(0,0);
	outputC.Pos =  mul(float4(p3,1),mx);
	outputC.Norm = N;
	outputC.Tex = float2(0,0); 
	outputD.Pos =  mul(float4(p4,1),mx);
	outputD.Norm = N;
	outputD.Tex = float2(0,0); 
	
	TriStream.Append( outputA );
	TriStream.Append( outputB );
	TriStream.Append( outputC );
    TriStream.RestartStrip();
	
	TriStream.Append( outputC );
	TriStream.Append( outputB );
	TriStream.Append( outputD ); 
    TriStream.RestartStrip();
}



GSPS_INPUT VS( VS_IN input) 
{
	GSPS_INPUT output = (GSPS_INPUT)0;
	//float4x4 mx = mul(mul(transpose(World) ,	transpose(View)),	transpose(Projection));
	
	output.Pos = input.Pos;// mul(	input.Pos,		 mx); 
	output.Tex = input.Tex;
	output.Norm = input.Norm;
	return output;
} 

[maxvertexcount(64)]
void GS( triangle GSPS_INPUT input[3], inout TriangleStream<GSPS_INPUT> TriStream )
{
    GSPS_INPUT output;
	float4x4 mx = mul(mul(transpose(World) ,	transpose(View)),	transpose(Projection));
    
    //
    // Calculate the face normal
    //
    float3 faceEdgeA = input[1].Pos - input[0].Pos;
    float3 faceEdgeB = input[2].Pos - input[0].Pos;
    float3 faceNormal = normalize( cross(faceEdgeA, faceEdgeB) );
    float3 ExplodeAmt = faceNormal*Explode;
    
    //
    // Calculate the face center
    //
    float3 centerPos = (input[0].Pos.xyz + input[1].Pos.xyz + input[2].Pos.xyz)/3.0;
    float2 centerTex = (input[0].Tex + input[1].Tex + input[2].Tex)/3.0;
    centerPos += faceNormal*Explode;
    
    //
    // Output the pyramid
    //
    for( int i=0; i<3; i++ )
    {
        output.Pos = input[i].Pos + float4(ExplodeAmt,0);
        //output.Pos = mul( output.Pos, View );
        //output.Pos = mul( output.Pos, Projection );
		output.Pos =  mul(output.Pos,mx);
        output.Norm = input[i].Norm;
        output.Tex = input[i].Tex;
        TriStream.Append( output );
        
        int iNext = (i+1)%3;
        output.Pos = input[iNext].Pos + float4(ExplodeAmt,0);
        //output.Pos = mul( output.Pos, View );
        //output.Pos = mul( output.Pos, Projection );
		output.Pos =  mul(output.Pos,mx);
        output.Norm = input[iNext].Norm;
        output.Tex = input[iNext].Tex;
        TriStream.Append( output );
        
        output.Pos = float4(centerPos,1) + float4(ExplodeAmt,0);
        //output.Pos = mul( output.Pos, View );
        //output.Pos = mul( output.Pos, Projection );
		output.Pos =  mul(output.Pos,mx);
        output.Norm = faceNormal;
        output.Tex = centerTex;
        TriStream.Append( output );
        
        TriStream.RestartStrip();
    }
    
    //for( int i=2; i>=0; i-- )
    //{
    //    output.Pos = input[i].Pos + float4(ExplodeAmt,0);
    //    //output.Pos = mul( output.Pos, View );
    //    //output.Pos = mul( output.Pos, Projection );
	//	output.Pos =  mul(output.Pos,mx);
    //    output.Norm = -input[i].Norm;
    //    output.Tex = input[i].Tex;
    //    TriStream.Append( output );
    //}
    TriStream.RestartStrip();
	
	
    for( int x=1; x<7; x++ )
    {
		for( int y=1; y<7; y++ )
		{
			for( int z=1; z<7; z++ )
			{ 
				float d = GetD(x,y,z);
				float xp = GetD(x+1,y,z);
				float xm = GetD(x-1,y,z);
				float3 p = float3(x,y,z);
				float3 mmm = float3(-1,-1,-1)/2+p;
				float3 mmp = float3(-1,-1,+1)/2+p;
				float3 mpm = float3(-1,+1,-1)/2+p;
				float3 mpp = float3(-1,+1,+1)/2+p;
				float3 pmm = float3(+1,-1,-1)/2+p; 
				float3 pmp = float3(+1,-1,+1)/2+p;
				float3 ppm = float3(+1,+1,-1)/2+p;
				float3 ppp = float3(+1,+1,+1)/2+p;
				
				//if(xp<d)
				//{
					Plane(TriStream,mx,pmm,pmp,ppm,ppp);
				//}
				//if(xm<d)
				//{
				//}
			}
		}
	}
}


[maxvertexcount(36)] //min 0 - max - 3*2*6 = 36
void GS2( triangle GSPS_INPUT input[3], inout TriangleStream<GSPS_INPUT> TriStream )
{
	float4x4 mx = mul(mul(transpose(World) ,	transpose(View)),	transpose(Projection));
	float3 p = input[0].Pos;
	int px = floor(p.x);
	int py = floor(p.y);
	int pz = floor(p.z);
	float d = GetD(px,py,pz); 
	
	float3 mmm = float3(-1,-1,-1)/2+p;
	float3 mmp = float3(-1,-1,+1)/2+p;
	float3 mpm = float3(-1,+1,-1)/2+p;
	float3 mpp = float3(-1,+1,+1)/2+p;
	float3 pmm = float3(+1,-1,-1)/2+p; 
	float3 pmp = float3(+1,-1,+1)/2+p;
	float3 ppm = float3(+1,+1,-1)/2+p;
	float3 ppp = float3(+1,+1,+1)/2+p;
	
	
	if (d>0.5)
	{
		float xp = GetD(px+1,py,pz); 
		float xm = GetD(px-1,py,pz);
		float yp = GetD(px,py+1,pz);
		float ym = GetD(px,py-1,pz);
		float zp = GetD(px,py,pz+1);
		float zm = GetD(px,py,pz-1);
		
		//Z
		if(zm<0.5) 
			Plane(TriStream,mx,ppm,mpm,pmm,mmm); 
		if(zp<0.5) 
			Plane(TriStream,mx,ppp,pmp,mpp,mmp); 
		
		//X
		if(xp<0.5)
			Plane(TriStream,mx,pmm,pmp,ppm,ppp);  
		if(xm<0.5) 
			Plane(TriStream,mx,mmm,mpm,mmp,mpp);  
		 
		//Y
		if(ym<0.5)
			Plane(TriStream,mx,pmp,pmm,mmp,mmm); 
		if(yp<0.5) 
			Plane(TriStream,mx,ppp,mpp,ppm,mpm); 
	}
}

float4 PS( GSPS_INPUT input ) : SV_Target
{ 
	float l = saturate(dot( input.Norm,float3(-1,-1,-1)))*0.9+0.1;
	return float4(abs(input.Norm)*l,1);
}
 

//struct GSPS_INPUT
//{
//    float4 Pos : SV_POSITION;
//    float3 Norm : TEXCOORD0;
//    float2 Tex : TEXCOORD1;
//};
 
technique10 Render
{
	pass P0
	{
		SetVertexShader( CompileShader( vs_4_0, VS() ) );
		//SetGeometryShader( CompileShader( gs_4_0, GS2() ) );
		SetGeometryShader(ConstructGSWithSO(  CompileShader( gs_4_0, GS2() ), 
			"0:SV_POSITION.xyzw; 1:TEXCOORD0.xyz; 2:TEXCOORD1.xy"  ) );
		SetPixelShader( CompileShader( ps_4_0, PS() ) );
	}
}