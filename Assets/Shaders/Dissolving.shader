Shader "Custom/Dissolving" {
	Properties
	{
		// Properties is just for editor in resume.
		_Color("Color", Color) = (1,1,1,1)
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		_DissolveScale("Dissolve Progression", Range(0.0, 1.0)) = 0.0
		_DissolveTex("Dissolve Texture", 2D) = "white" {}
		_GlowIntensity("Glow Intensity", Range(0.0, 5.0)) = 3
		_GlowScale("Glow Size", Range(0.0, 5.0)) = 0.5
		_Glow("Glow Color", Color) = (1, 0, 0, 1)
		_GlowEnd("Glow End Color", Color) = (1, 1, 0, 1)
		_GlowColFac("Glow Colorshift", Range(0.01, 2.0)) = 1

		_DissolveStart("Dissolve Start Point", Vector) = (1, 1, 1, 1)
		_DissolveEnd("Dissolve End Point", Vector) = (-1, -1, -1, 1)

		_DissolveBand("Dissolve Band Size", Float) = 0.5
	}
		SubShader{
			Tags {    "Queue" = "Geometry" }

			LOD 200

			CGPROGRAM
			#pragma surface surf Standard vertex:vert
			#pragma target 3.0

			// Declare variables you need in shader here again.
			fixed4 _Color;
			fixed4 _Glow;
			fixed4 _GlowEnd;

			half4 _DissolveStart;
			half4 _DissolveEnd;

			sampler2D _MainTex;
			sampler2D _DissolveTex;

			half _Glossiness;
			half _DissolveScale;
			half _GlowIntensity;
			half _GlowScale;
			half _GlowColFac;
			half _DissolveBand;

			static float3 dDir = normalize(_DissolveEnd - _DissolveStart).xyz;
			static float3 dissolveStartConverted = _DissolveStart.xyz - _DissolveBand * dDir;
			static float dBandFactor = 1 / _DissolveBand;

			// Input you need to use in surf routine. You can pass variables from vertex to surf with that too.
			// You can access to others variables, like vertex color, with semantic words.
			struct Input
			{
				float2 uv_MainTex;
				float2 uv_DissolveTex;
				float dGeometry;
				//float4 color:COLOR; //Give access to vertex color for example.
			};

			void vert(inout appdata_full v, out Input o)
			{
				UNITY_INITIALIZE_OUTPUT(Input,o);

				//Precompute dissolve direction.
				static float3 dDir = normalize(_DissolveEnd.xyz - _DissolveStart.xyz);

				//Precompute gradient start position.
				static float3 dissolveStartConverted = _DissolveStart - _DissolveBand * dDir;

				//Precompute reciprocal of band size.
				static float dBandFactor = 1.0f / _DissolveBand;

				//Calculate geometry-based dissolve coefficient.
				//Compute top of dissolution gradient according to dissolve progression.
				float3 dPoint = lerp(dissolveStartConverted, _DissolveEnd, _DissolveScale);

				//Project vector between current vertex and top of gradient onto dissolve direction.
				//Scale coefficient by band (gradient) size.
				o.dGeometry = dot(v.vertex - dPoint, dDir) * dBandFactor;
			}

			void surf(Input IN, inout SurfaceOutputStandard o) {
				fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;

				//Read from noise texture.
				fixed4 dTex = tex2D(_DissolveTex, IN.uv_DissolveTex);

				//Convert dissolve progression to -1 to 1 scale.
				half dBase = -2 * _DissolveScale + 1;

				//Convert dissolve texture sample based on dissolve progression.
				half dTexRead = dTex.r + dBase;
				//Combine texture factor with geometry coefficient from vertex routine.
				half dFinal = dTexRead + IN.dGeometry;

				//Shift the computed raw alpha value based on the scale factor of the glow.
				//Scale the shifted value based on effect intensity.
				half dPredict = (_GlowScale - dFinal) * _GlowIntensity;

				//Change colour interpolation by adding in another factor controlling the gradient.
				half dPredictCol = (_GlowScale * _GlowColFac - dFinal) * _GlowIntensity;

				//Calculate and clamp glow colour.
				fixed4 glowCol = dPredict * lerp(_Glow, _GlowEnd, clamp(dPredictCol, 0.0f, 1.0f));
				glowCol = clamp(glowCol, 0.0f, 1.0f);

				o.Albedo = c.rgb;
				o.Metallic = 0;
				o.Smoothness = 0;
				o.Emission = glowCol;
				clip(clamp(dFinal, 0.0f, 1.0f) - 0.1);
			}
			ENDCG
		}
			FallBack "Diffuse"
}