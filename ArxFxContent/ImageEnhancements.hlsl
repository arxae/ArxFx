float3 SharpPass( float3 color, float2 tex, sampler colorsampler)
{
	// TODO: Correct shader code
	return color;
}

float4 PS_ImageEnhancements(float4 vpos : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
	float4 color = tex2D(RFX_backbufferColor, texcoord);

	#if(USE_SHARPENING == 1)
		color.xyz = SharpPass(color.xyz, texcoord.xy, SamplerCurrent);
	#endif

	return color;
}
