Shader "Custom/ShineShader" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0
		_ShineY ("ShineY", float) = 0.0
		_ShineColor ("ShineColor", Color) = (1,1,1,1)
		_ShineGap ("ShineGap", Range(0,1)) = 0.5
		_Shineness ("Shineness", Range(0,5)) = 2.0
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		Cull Off
		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Standard fullforwardshadows

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		sampler2D _MainTex;

		struct Input {
			float2 uv_MainTex;
			float3 worldPos;
			float3 viewDir;
			float3 worldNormal;
		};

		half _Glossiness;
		half _Metallic;
		fixed4 _Color;
		float _ShineY;
		fixed4 _ShineColor;
		float _ShineGap;
		float _Shineness;

		// Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
		// See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
		// #pragma instancing_options assumeuniformscaling
		UNITY_INSTANCING_CBUFFER_START(Props)
			// put more per-instance properties here
		UNITY_INSTANCING_CBUFFER_END

		void surf (Input IN, inout SurfaceOutputStandard o) {
			// Albedo comes from a texture tinted by color
			fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
			o.Albedo = c.rgb;
			// Metallic and smoothness come from slider variables
			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;
			o.Alpha = c.a;
			
			float shineY = _ShineY + sin((IN.worldPos.x + IN.worldPos.z) * 10.0f + _Time.y * 10.0f) / 20.0f;

			float distance = shineY - IN.worldPos.y;
			// clip(distance);
			if (distance > 0.0)
			{			
				o.Emission = _Shineness * _ShineColor * saturate(_ShineGap - distance);
			}
			//if (dot(IN.viewDir, IN.worldNormal) < 0.0)
			//	o.Albedo += 5.0 * _ShineColor;

		}
		ENDCG
	}
	FallBack "Diffuse"
}
