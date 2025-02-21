﻿Shader "Custom/DissolveShader" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0

		_DissolveTex ("Noise (RGB)", 2D) = "white" {}
		_DissolveAmount ("DissolveAmount", Range(0.0,1.0)) = 0.0

		_DissolveEdge ("DissolveEdgeAmount", Range(0.0,1.0)) = 0.0
		_DissolveEdgeColor ("DissolveEdgeColor", Color) = (1,1,0,1)
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
			float2 uv_DissolveTex;
		};

		half _Glossiness;
		half _Metallic;
		fixed4 _Color;

		sampler2D _DissolveTex;
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
			
			// Clip
			half clipValue = tex2D(_DissolveTex, IN.uv_DissolveTex).rgb - _DissolveAmount;
			clip (clipValue);
			
			// Calculate burnt edges
			half edgeColorAmount = 1 - saturate(clipValue / _DissolveEdge);
			fixed4 edgeColor = edgeColorAmount * _DissolveEdgeColor;

			// Albedo comes from a texture tinted by color
			fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color + edgeColor;
			o.Albedo = c.rgb;
			// Metallic and smoothness come from slider variables
			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;
			o.Alpha = c.a;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
