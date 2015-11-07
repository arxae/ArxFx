texture   texBloom1 { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RENDERMODE;};
texture   texBloom2 { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RENDERMODE;};
texture   texBloom3 { Width = BUFFER_WIDTH/2; Height = BUFFER_HEIGHT/2; Format = RENDERMODE;};
texture   texBloom4 { Width = BUFFER_WIDTH/4; Height = BUFFER_HEIGHT/4; Format = RENDERMODE;};
texture   texBloom5 { Width = BUFFER_WIDTH/8; Height = BUFFER_HEIGHT/8; Format = RENDERMODE;};

texture   texDirt   < string source = "ArxFxContent/textures/lensdirt.png"; > {Width = BUFFER_WIDTH;Height = BUFFER_HEIGHT;Format = RGBA8;};

sampler SamplerBloom1 { Texture = texBloom1; };
sampler SamplerBloom2 { Texture = texBloom2; };
sampler SamplerBloom3 { Texture = texBloom3; };
sampler SamplerBloom4 { Texture = texBloom4; };
sampler SamplerBloom5 { Texture = texBloom5; };

sampler2D SamplerDirt
{
	Texture = texDirt;
	MinFilter = LINEAR;
	MagFilter = LINEAR;
	MipFilter = LINEAR;
	AddressU = Clamp;
	AddressV = Clamp;
};

float4 PS_Lighting(float4 vpos : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
	float4 color = tex2D(RFX_backbufferColor, texcoord);

	#if (USE_BLOOM == 1)
		float3 colorbloom=0;

		colorbloom.xyz += tex2D(SamplerBloom3, texcoord.xy).xyz*1.0;
		colorbloom.xyz += tex2D(SamplerBloom5, texcoord.xy).xyz*9.0;
		colorbloom.xyz *= 0.1;

		colorbloom.xyz = saturate(colorbloom.xyz);
		float colorbloomgray = dot(colorbloom.xyz, 0.333);
		colorbloom.xyz = lerp(colorbloomgray, colorbloom.xyz, fBloomSaturation);
		colorbloom.xyz *= fBloomTint;
		float colorgray = dot(color.xyz, 0.333);

		if(iBloomMixmode == 1) color.xyz = color.xyz + colorbloom.xyz;
		if(iBloomMixmode == 2) color.xyz = 1-(1-color.xyz)*(1-colorbloom.xyz);
		if(iBloomMixmode == 3) color.xyz = max(0.0f,max(color.xyz,lerp(color.xyz,(1.0f - (1.0f - saturate(colorbloom.xyz)) *(1.0f - saturate(colorbloom.xyz * 1.0))),1.0)));
		if(iBloomMixmode == 4) color.xyz = max(color.xyz, colorbloom.xyz);
	#endif

	#if (USE_LENSDIRT == 1)
		float lensdirtmult = dot(tex2D(SamplerBloom5, texcoord.xy).xyz,0.333);
		float3 dirttex = tex2D(SamplerDirt, texcoord.xy).xyz;

		float3 lensdirt = dirttex.xyz*lensdirtmult*fLensdirtIntensity*fLensdirtTint;
		lensdirt = lerp(dot(lensdirt.xyz,0.333), lensdirt.xyz, fLensdirtSaturation);

		if(iLensdirtMixmode == 1) color.xyz = color.xyz + lensdirt.xyz;
		if(iLensdirtMixmode == 2) color.xyz = 1-(1-color.xyz)*(1-lensdirt.xyz);
		if(iLensdirtMixmode == 3) color.xyz = max(0.0f,max(color.xyz,lerp(color.xyz,(1.0f - (1.0f - saturate(lensdirt.xyz)) *(1.0f - saturate(lensdirt.xyz * 1.0))),1.0)));
		if(iLensdirtMixmode == 4) color.xyz = max(color.xyz, lensdirt.xyz);
	#endif

	return color;
}
