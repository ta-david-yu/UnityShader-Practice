Shader "Custom/PeelingShader" {
	Properties {
		_BumpMap ("Bumpmap", 2D) = "bump" {}

		_Color1 ("Color1", Color) = (1,1,1,1)
		_MainTex1 ("Albedo1 (RGB)", 2D) = "white" {}
		_Glossiness1 ("Smoothness1", Range(0,1)) = 0.5
		_Metallic1 ("Metallic1", Range(0,1)) = 0.0

		_Color2 ("Color2", Color) = (1,1,1,1)
		_MainTex2 ("Albedo2 (RGB)", 2D) = "white" {}
		_Glossiness2 ("Smoothness2", Range(0,1)) = 0.5
		_Metallic2 ("Metallic2", Range(0,1)) = 0.0

		_DissolveTex ("Noise (RGB)", 2D) = "white" {}
		_DissolveAmount ("Amount", Range(0.0,1.0)) = 0.0
		_DissolveEdge ("DissolveEdgeAmount", Range(0.0,1.0)) = 0.0
		_DissolveEdgeColor ("DissolveEdgeColor", Color) = (1,1,0,1)
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Standard fullforwardshadows

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		sampler2D _MainTex1;
		sampler2D _MainTex2;
		sampler2D _DissolveTex;
		sampler2D _BumpMap;

		struct Input {
			float2 uv_MainTex1;
			float2 uv_MainTex2;
			float2 uv_DissolveTex;
			float2 uv_BumpMap;
		};

		half _Glossiness1;
		half _Metallic1;
		fixed4 _Color1;

		half _Glossiness2;
		half _Metallic2;
		fixed4 _Color2;

		half _DissolveAmount;
		half _DissolveEdge;
		fixed4 _DissolveEdgeColor;
		

		// Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
		// See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
		// #pragma instancing_options assumeuniformscaling
		UNITY_INSTANCING_CBUFFER_START(Props)
			// put more per-instance properties here
		UNITY_INSTANCING_CBUFFER_END

		void surf (Input IN, inout SurfaceOutputStandard o) {

			half clipValue = tex2D(_DissolveTex, IN.uv_DissolveTex).rgb - _DissolveAmount;
			if (clipValue > 0)
			{
				// Calculate burnt edges
				half edgeColorAmount = 1 - saturate(clipValue / _DissolveEdge);
				fixed4 edgeColor = edgeColorAmount * _DissolveEdgeColor;

				// Albedo comes from a texture tinted by color
				fixed4 c = tex2D (_MainTex1, IN.uv_MainTex1) * _Color1;
				o.Albedo = c.rgb;
				// Metallic and smoothness come from slider variables
				o.Metallic = _Metallic1;
				o.Smoothness = _Glossiness1;
				o.Alpha = c.a;
				o.Emission = edgeColor;
			}
			else
			{
				// Albedo comes from a texture tinted by color
				fixed4 c = tex2D (_MainTex2, IN.uv_MainTex2) * _Color2;
				o.Albedo = c.rgb;
				// Metallic and smoothness come from slider variables
				o.Metallic = _Metallic2;
				o.Smoothness = _Glossiness2;
				o.Alpha = c.a;
			}
			o.Normal = UnpackNormal (tex2D (_BumpMap, IN.uv_BumpMap));
		}
		ENDCG
	}
	FallBack "Diffuse"
}
