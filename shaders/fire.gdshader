shader_type spatial;

uniform float flameTaperFactor = 0.9;
uniform float flameTipAmplitudeX = 0.01;
uniform float flameTipAmplitudeZ = 0.01;
uniform float flameTipFrequencyX = 1.0;
uniform float flameTipFrequencyZ = 1.0;
uniform vec3 topColor : source_color = vec3(1, 0, 0);
uniform vec3 bottomColor : source_color = vec3(1, 1, 0);
uniform vec3 fresnelColor : source_color = vec3(0, 0, 1);
uniform float fresnelAmount : hint_range(0, 100) = 5.0;
uniform float fresnelIntensity : hint_range(0, 100) = 2.0;
uniform float baseAlpha : hint_range(0,1) = 0.0;
uniform float colorFadeHeight : hint_range(0,1) = 0.4;
uniform float darkZoneRadius : hint_range(0,1) = 0.8;
uniform float flickerSpeed : hint_range(0,100) = 3.0;


vec3 FresnelGlow(float amount, float intensity, vec3 color, vec3 normal, vec3 view)
{
	return pow((1.0 - dot(normalize(normal), normalize(view))), amount) * color * intensity;
}

void vertex() {

	// Called for every vertex the material is visible on.
	VERTEX.x = mix(VERTEX.x, 0, (1.0 - UV.y) * flameTaperFactor)
	+ (sin(TIME * flameTipFrequencyX) * (1.0-UV.y)) * flameTipAmplitudeX
	+ (cos(TIME * flameTipFrequencyX) * (1.0-UV.y)) * flameTipAmplitudeX;
	VERTEX.z = mix(VERTEX.z, 0, (1.0 - UV.y) * flameTaperFactor)
	+ (sin(TIME * flameTipFrequencyZ) * (1.0-UV.y)) * flameTipAmplitudeZ
	- (cos(TIME * flameTipFrequencyZ) * (1.0-UV.y)) * flameTipAmplitudeZ;

	VERTEX.x += sin(TIME * 50.0 + VERTEX.y * 7.0) * 0.002;
	VERTEX.x += cos(TIME * 100.0 + VERTEX.y * 15.0) * 0.0015 * flickerSpeed;

}

void fragment() {

	RIM = 1.0;
	ROUGHNESS = 0.5;
	SPECULAR = 0.1;
	RIM_TINT = 15.0;
	ALBEDO = mix(bottomColor, topColor, UV.y * colorFadeHeight * (sin(TIME) + 120.0) / 100.0);
	ALPHA = baseAlpha;
	EMISSION = ALBEDO * 1.0;

	vec3 fresnel = FresnelGlow(fresnelAmount, fresnelIntensity, fresnelColor, NORMAL, VIEW);
	float fresnel_strength = length(fresnel);
	ALPHA = clamp(fresnel_strength, 0.5, 1.0);

}
