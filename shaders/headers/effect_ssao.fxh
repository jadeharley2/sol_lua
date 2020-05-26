// search matrix.

float4x4 ViewProjection;
float4x4 InverseViewProjection;

const float ssao_total_strength = 2.0; 
const float ssao_area =0.00075;//0.0075*1;
const float ssao_falloff = 0.0001;//0.000001*1000;//0.000001;

const float ssao_radius = 0.0002;//0.0002*100;

 int ssao_samples = 256; 
 
SamplerState sSampler
{
    Filter = MIN_MAG_MIP_POINT;//MIN_MAG_MIP_LINEAR;
    AddressU = Wrap;
    AddressV = Wrap;
};
Texture2D tSSAONoise; 


float3 ssao_sample_sphere[256] = {
	float3(-0.3411618, -0.7536697, 0.5617744),
	float3(-0.6122842, -0.6879793, 0.3896055),
	float3(0.4277442, 0.647072, -0.631136),
	float3(-0.5722739, 0.3462577, 0.7433761),
	float3(-0.03845344, -0.9926321, 0.114904),
	float3(0.5222836, -0.7030866, 0.4825858),
	float3(-0.2502896, 0.1983775, -0.9476293),
	float3(-0.4106614, 0.8898844, -0.1986534),
	float3(-0.6124867, -0.7626162, 0.2080302),
	float3(0.817996, -0.4879157, 0.304665),
	float3(-0.2596155, -0.3029152, -0.9169744),
	float3(0.7277991, -0.6835294, -0.05564382),
	float3(-0.7140638, -0.2257377, -0.6626881),
	float3(-0.2238428, 0.8875951, -0.4025782),
	float3(0.09027108, 0.5258412, 0.8457791),
	float3(0.699468, -0.5633227, 0.4397863),
	float3(0.6820896, -0.5756756, 0.450945),
	float3(-0.8971666, 0.2247314, -0.3802472),
	float3(-0.4126137, -0.7809922, -0.4688293),
	float3(-0.1861057, 0.6839147, 0.7054257),
	float3(-0.7239476, 0.6435379, -0.2485133),
	float3(0.4260093, 0.8005436, -0.4214806),
	float3(0.501604, 0.03620869, 0.8643392),
	float3(-0.7518773, 0.4450295, 0.4864455),
	float3(0.3290634, 0.8090477, 0.4869899),
	float3(0.4098562, 0.5478587, -0.7292932),
	float3(-0.02632071, -0.004686357, -0.9996426),
	float3(0.7028441, 0.5315411, -0.4727308),
	float3(0.6613613, -0.4634052, 0.5897939),
	float3(0.4234624, 0.4018595, -0.8119043),
	float3(-0.7987238, 0.5280897, -0.2883776),
	float3(-0.6246712, -0.2735796, 0.731396),
	float3(0.7021973, 0.4774297, 0.5281852),
	float3(0.2473836, -0.8696448, 0.4272228),
	float3(0.4840056, 0.8120674, -0.3260141),
	float3(-0.9118257, -0.2692715, 0.3099464),
	float3(0.1334236, 0.1575084, -0.9784628),
	float3(-0.7410071, 0.6647342, -0.0950619),
	float3(0.6471452, -0.4193378, -0.6366781),
	float3(-0.6736474, 0.7283727, 0.1251896),
	float3(0.1021465, -0.8363759, 0.5385551),
	float3(0.6075215, 0.4944922, -0.6216068),
	float3(-0.7048668, 0.339673, 0.6227239),
	float3(0.5714817, 0.3492567, 0.7425823),
	float3(-0.5328581, 0.8339769, -0.1433347),
	float3(-0.3013949, -0.7052301, 0.6417255),
	float3(0.6613494, 0.3148826, 0.6807833),
	float3(-0.6792375, -0.5036163, -0.5338605),
	float3(0.6077455, -0.5965613, 0.5241757),
	float3(0.6858661, -0.4246474, -0.5909843),
	float3(0.5226426, 0.6036228, 0.6020666),
	float3(-0.2972479, -0.6416196, -0.7070841),
	float3(0.6115174, 0.4931415, -0.6187551),
	float3(-0.5575233, 0.4792721, 0.6778392),
	float3(-0.7724023, 0.3281572, 0.5437901),
	float3(-0.3164545, 0.5036857, -0.8038391),
	float3(-0.792855, 0.1200546, -0.597468),
	float3(-0.5173857, -0.6672484, -0.5358095),
	float3(0.3687604, -0.09606294, 0.9245473),
	float3(0.2703347, -0.9113346, 0.3104644),
	float3(-0.7162123, -0.4474334, -0.5355774),
	float3(0.05991366, 0.8480678, 0.5264897),
	float3(-0.6500965, 0.6430389, 0.4048155),
	float3(-0.3356017, -0.3275281, -0.883231),
	float3(0.4715997, 0.2956917, 0.8307589),
	float3(-0.6461012, -0.7631316, -0.01354464),
	float3(-0.8466037, -0.01735614, -0.5319409),
	float3(0.4456381, 0.8592637, 0.2511425),
	float3(0.8759771, 0.1988437, 0.4394602),
	float3(0.6540512, 0.6407072, 0.4021335),
	float3(-0.70755, -0.4559599, 0.539883),
	float3(-0.1254018, 0.9239497, -0.3613743),
	float3(-0.260564, -0.07038592, 0.9628875),
	float3(-0.7618878, -0.3525839, 0.5433338),
	float3(-0.6017151, 0.2107085, -0.770416),
	float3(0.9947584, -0.1005867, -0.01838586),
	float3(-0.9202465, -0.01609152, -0.3910083),
	float3(-0.5372444, -0.7678065, 0.3490582),
	float3(-0.9243168, 0.2633438, -0.2762037),
	float3(0.8477355, 0.2468373, -0.4694848),
	float3(-0.8739029, -0.283683, -0.3947374),
	float3(-0.5497251, -0.4850511, -0.6800939),
	float3(0.1108684, -0.5613052, 0.8201492),
	float3(0.5947706, 0.7323371, 0.3315574),
	float3(0.6047155, -0.4533197, -0.6548437),
	float3(0.4808164, 0.03840104, -0.87598),
	float3(-0.04601334, -0.7346391, -0.6768959),
	float3(-0.606809, -0.1737944, -0.7756149),
	float3(-0.4373919, 0.5177791, -0.7352504),
	float3(-0.7401494, -0.6115054, -0.279714),
	float3(0.6550866, 0.3436269, 0.6728909),
	float3(-0.2289626, 0.7237588, 0.6509604),
	float3(0.05116545, -0.9582131, -0.2814423),
	float3(-0.7425628, -0.284447, -0.6063748),
	float3(0.6431993, 0.2001647, 0.7390729),
	float3(0.5240501, 0.1353721, 0.8408602),
	float3(-0.2298685, 0.3502758, -0.9080018),
	float3(-0.8697444, -0.4853408, -0.08938205),
	float3(-0.4443124, 0.5353928, 0.7182904),
	float3(-0.5981711, 0.7801045, -0.1833801),
	float3(-0.7250762, -0.195446, -0.6603525),
	float3(-0.2258957, 0.4531209, 0.8623529),
	float3(0.6616601, -0.3081497, -0.6835567),
	float3(-0.4360286, -0.8969047, -0.07376307),
	float3(-0.8598899, -0.1142082, 0.4975399),
	float3(-0.8129281, -0.02626817, 0.5817713),
	float3(-0.4451893, -0.3077955, -0.8408737),
	float3(-0.8791355, 0.4716599, 0.06824642),
	float3(-0.4990253, 0.8618941, -0.09006806),
	float3(-0.07001642, -0.7413986, -0.6674023),
	float3(0.7421705, -0.1629072, -0.650111),
	float3(0.6120736, 0.5650561, 0.5532427),
	float3(0.8181875, -0.1928122, 0.5416573),
	float3(0.5208221, -0.6290097, -0.5771405),
	float3(0.3656794, -0.8901332, 0.2719218),
	float3(0.1891731, -0.803723, 0.5641301),
	float3(0.4540166, -0.7739433, -0.4414528),
	float3(-0.839775, 0.526603, 0.1321636),
	float3(-0.6324136, -0.7358427, 0.2420508),
	float3(0.1689426, -0.7143298, 0.6791106),
	float3(0.06739727, -0.8261915, -0.5593435),
	float3(-0.7801244, -0.5072351, 0.3662218),
	float3(-0.2102478, -0.9775304, -0.01517901),
	float3(0.4972543, -0.6624519, -0.5602639),
	float3(-0.9055887, 0.123971, -0.4056358),
	float3(-0.9056022, -0.2831086, 0.3158072),
	float3(0.7583227, 0.3434108, 0.5540902),
	float3(0.2820868, 0.571498, 0.7705952),
	float3(0.5924884, 0.7670321, 0.2462102),
	float3(-0.000342067, 0.6829509, 0.7304643),
	float3(-0.689025, -0.3592761, -0.6294166),
	float3(0.6683815, -0.3401693, 0.6614764),
	float3(0.7348224, -0.01411597, 0.6781126),
	float3(0.6379099, -0.4025576, -0.6565199),
	float3(-0.371863, 0.6569937, -0.6558027),
	float3(-0.4415253, -0.7338324, -0.5162805),
	float3(-0.394224, -0.8556048, 0.3354517),
	float3(-0.9177423, 0.3391689, -0.2066725),
	float3(-0.7211826, 0.6745626, -0.1576737),
	float3(-0.4448081, -0.6840297, -0.5781429),
	float3(-0.6777719, 0.5677425, -0.4672192),
	float3(0.603866, 0.3477835, 0.7172117),
	float3(0.5393735, -0.7386479, -0.4043212),
	float3(-0.2779468, -0.5259402, 0.8038236),
	float3(0.5634386, 0.8254151, -0.03502743),
	float3(0.4771759, -0.3009893, 0.8256565),
	float3(0.5126858, 0.1907634, 0.8371156),
	float3(-0.1418134, -0.6378074, 0.7570274),
	float3(-0.7194838, -0.5020198, 0.4799158),
	float3(0.7774401, 0.605202, -0.1712235),
	float3(0.01770668, -0.1316168, -0.9911425),
	float3(-0.09491127, 0.9132371, -0.3962194),
	float3(0.729975, 0.4325818, -0.529159),
	float3(0.1105537, -0.1157111, 0.9871113),
	float3(0.6421344, 0.6398519, 0.4222002),
	float3(0.6246894, -0.6253784, 0.4676163),
	float3(0.9051068, -0.4078714, 0.1200946),
	float3(-0.2173058, 0.5617745, 0.7982404),
	float3(0.1385157, 0.4355362, 0.8894502),
	float3(-0.5705446, -0.2658949, -0.7770321),
	float3(0.7007957, 0.6102213, -0.36948),
	float3(0.623471, 0.6041342, 0.496292),
	float3(0.4296265, -0.2582504, -0.8652905),
	float3(-0.5958455, 0.7759166, 0.2071756),
	float3(0.4332716, -0.6133689, -0.660344),
	float3(0.8915855, 0.05774397, -0.4491558),
	float3(-0.717275, -0.1876671, -0.6710422),
	float3(0.6993661, -0.7146275, 0.01395318),
	float3(0.5815601, -0.6902505, 0.430514),
	float3(-0.2718218, 0.9083641, -0.3177857),
	float3(0.520292, 0.04318257, -0.852896),
	float3(0.9561854, 0.2530909, 0.1471549),
	float3(0.2867097, -0.6849, -0.6698579),
	float3(0.6525322, -0.5976645, 0.4658313),
	float3(0.6259498, 0.7043477, -0.3347851),
	float3(0.9192633, 0.3881265, 0.06567203),
	float3(0.2858369, 0.3068622, -0.9078176),
	float3(-0.2495999, -0.4174192, -0.8737626),
	float3(-0.4663002, 0.6884556, 0.5555116),
	float3(0.4280037, -0.7803852, 0.4558638),
	float3(-0.9515457, -0.2710624, -0.145211),
	float3(0.8788316, 0.2005006, -0.4329601),
	float3(-0.513373, 0.8506572, 0.1132723),
	float3(0.1948853, -0.9795508, -0.04999949),
	float3(-0.4715944, -0.8089818, -0.3509231),
	float3(-0.6115488, -0.5656319, -0.5532347),
	float3(-0.6621696, 0.7261943, -0.1848598),
	float3(-0.6416107, 0.5580826, -0.5261935),
	float3(-0.5084423, -0.5674555, -0.6476734),
	float3(-0.6307716, 0.6532167, 0.4188499),
	float3(0.3071854, 0.6349188, -0.7088832),
	float3(-0.4308592, 0.8234035, 0.369279),
	float3(-0.1625194, -0.8235332, -0.5434893),
	float3(0.7442641, 0.1708267, 0.6456696),
	float3(0.7573367, -0.6502218, -0.06043724),
	float3(0.1565377, -0.7780718, -0.6083587),
	float3(0.4170364, 0.840857, 0.3450219),
	float3(0.2110267, 0.3294058, -0.920304),
	float3(-0.3235668, 0.8670228, 0.3789142),
	float3(-0.8064708, -0.2808309, -0.5203257),
	float3(-0.4397382, -0.57707, -0.688201),
	float3(0.6486199, 0.6295224, -0.4277777),
	float3(-0.06199378, 0.8071797, -0.5870414),
	float3(0.269738, 0.7464663, -0.6083004),
	float3(-0.7315842, -0.5953187, -0.332235),
	float3(-0.04042117, -0.8560171, 0.5153649),
	float3(0.6174315, 0.4072589, -0.6729922),
	float3(-0.8217398, 0.03690208, 0.5686668),
	float3(0.7443503, -0.583768, -0.3242802),
	float3(0.6190059, 0.5693295, -0.5410135),
	float3(-0.8306648, -0.4576089, 0.3171594),
	float3(0.8332548, 0.5518132, 0.03447885),
	float3(0.6485517, -0.6083279, -0.4575129),
	float3(-0.4844306, -0.6238903, -0.61326),
	float3(-0.6239555, -0.5580246, -0.5470723),
	float3(-0.8937821, 0.3676267, -0.2569127),
	float3(0.5935045, 0.7932984, 0.1357575),
	float3(0.8938079, -0.3172504, 0.3169535),
	float3(-0.7306966, -0.6695195, 0.1335139),
	float3(-0.5719321, 0.6934806, 0.4381533),
	float3(0.7647381, 0.07422739, -0.6400515),
	float3(-0.9805774, 0.1161597, 0.1580343),
	float3(0.1514073, -0.9284478, -0.3392054),
	float3(0.5824729, 0.1848404, -0.791555),
	float3(-0.3814228, 0.7193094, 0.5806123),
	float3(-0.6917979, 0.7130144, -0.1141314),
	float3(0.9005209, 0.1234322, 0.4169252),
	float3(0.4360649, -0.5569924, 0.7068287),
	float3(0.1132177, -0.6868421, 0.7179343),
	float3(0.8337194, 0.5085436, 0.2151635),
	float3(0.8113493, 0.3740802, -0.4491951),
	float3(-0.06228723, -0.9661094, 0.2505054),
	float3(-0.7240874, -0.6870717, 0.06024866),
	float3(0.06391601, 0.9482182, -0.3111219),
	float3(-0.5882968, -0.7525818, -0.2958505),
	float3(-0.1769665, 0.1627124, 0.9706737),
	float3(-0.6291859, -0.6045159, -0.4885546),
	float3(-0.9158026, -0.06909133, -0.3956414),
	float3(-0.7337175, -0.6633537, -0.147039),
	float3(-0.984857, -0.1520732, -0.08324944),
	float3(0.6722158, 0.2635191, -0.6918697),
	float3(0.427577, 0.598905, 0.6771194),
	float3(0.6039601, 0.7734733, -0.1922786),
	float3(-0.586392, -0.5996608, 0.5445652),
	float3(0.7507369, -0.6111427, 0.2507961),
	float3(-0.5278487, 0.3585821, -0.7699316),
	float3(0.407609, -0.9046112, 0.124633),
	float3(-0.5168985, 0.7648761, 0.3844223),
	float3(-0.1003621, 0.7456095, -0.6587821),
	float3(0.652595, -0.2511674, -0.7148669),
	float3(-0.6581028, 0.7298641, 0.1849295),
	float3(-0.7237769, 0.636654, -0.2661176),
	float3(-0.8025947, -0.2129375, -0.5572247),
	float3(-0.5063325, 0.6845796, 0.5243836),
	float3(-0.2679352, -0.7023448, -0.6594865),
	float3(-0.649442, -0.5614038, -0.5128847)
}; // */
 
float ssao_raylen[8] ={
	0.1,0.2,0.3,0.5,

	0.7,1,2,3
};
  
  
float3 SSAO(float3 color,float2 tcrd)
{
	//texelDepth - ��� ������ ��� ������
	float3 localNormal = SS_GetNormal(tcrd).xyz;
	float3 texelNormal = normalize((localNormal -float3(0.5,0.5,0.5))*2);
	
	float texelDepth = SS_GetDepth(tcrd); 
	float3 texelPosition = SS_GetPosition(tcrd,texelDepth);
	 
	float radius_depth = ssao_radius/(texelDepth );
	float occlusion = 0.0;
	// color = 1;
	
	float ssaomul = (30*8*10)/ssao_samples;

	float ssaoOff = tSSAONoise.Sample(sSampler, tcrd*viewSize/512).r;	 //32

	for(int i=0; i < ssao_samples; i++) 
	{
		float3 ray = radius_depth * ssao_sample_sphere[(i+ssaoOff*32)%256];
		float dotD = dot(-normalize(ray),texelNormal);
		
		if(sign(dotD)<0)
		{
			float raylen = ssao_raylen[i%8]; 
			float3 hemi_ray = ray*0.00006*texelDepth*10000*raylen;
			float3 worldpos = texelPosition+hemi_ray;
			float2 texpos = SS_GetUV(worldpos).xy;
			float occ_depth = SS_GetDepth(texpos);
			float difference = texelDepth-occ_depth;//hemi_ray.z;
			float fadeout = 1-saturate(max(difference,0)/0.0005);
			
			if(difference>0)//&&difference<0.0005)//���� ������� ����� ��� ��������� �������
			{
				//float3 diff2 = 
				//occlusion +=
				//	max(0.0,dot(texelNormal,normalize(worldpos))-g_bias)
				//	*(1.0/(1.0+d))
				//	*g_intensity;
				occlusion += difference*fadeout*ssaomul;//*ssaoOff;
				/////////occlusion += dot(texelNormal,normalize(worldpos))*1000;
				//occlusion+=(-difference)*0.001;
			}
			else//������
			{
				//color+=SS_GetColor(texpos,2)* (1.0 / ssao_samples);
				//occlusion +=0;
			}
			//if(difference>0)
			//{
			//	occlusion += 1; 
			//}
		//	occlusion = fadeout;
		} 
	} 
	//return saturate(1-occlusion*10); 
	return saturate(1-occlusion*10)*color; 
	//return float3(1,1,1)*(1-occlusion* (1.0 / ssao_samples));
	//return color*(1-occlusion* (1.0 / ssao_samples));
	
}
 

float3 SSAO_HARD(float3 color,float2 tcrd)
{
	//texelDepth - ��� ������ ��� ������
	float3 localNormal = SS_GetNormal(tcrd).xyz;
	float3 texelNormal = normalize((localNormal -float3(0.5,0.5,0.5))*2);
	
	float texelDepth = SS_GetDepth(tcrd); 
	float3 texelPosition = SS_GetPosition(tcrd,texelDepth);
	 
	float radius_depth = ssao_radius/(texelDepth );
	float occlusion = 0.0;
	// color = 1;
	
	float ssaomul = (30*8*10)/ssao_samples;

	for(int i=0; i < ssao_samples; i++) 
	{
		float3 ray = radius_depth * ssao_sample_sphere[i%256];
		float dotD = dot(-normalize(ray),texelNormal);
		
		if(sign(dotD)<0)
		{
			float raylen = ssao_raylen[i%8]; 
			float3 hemi_ray = ray*0.00006*texelDepth*10000*raylen;
			float3 worldpos = texelPosition+hemi_ray;
			float2 texpos = SS_GetUV(worldpos).xy;
			float occ_depth = SS_GetDepth(texpos);
			float difference = texelDepth-occ_depth;//hemi_ray.z;
			float fadeout = 1-saturate(max(difference,0)/0.0005);
			
			if(difference>0)//&&difference<0.0005)//���� ������� ����� ��� ��������� �������
			{ 
				occlusion += difference*fadeout*ssaomul; 
			} 
		} 
	}  
	return saturate(1-occlusion*10)*color;  
}
 