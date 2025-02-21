﻿Shader "Custom/ImageEffect/DistortImageEffect"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_DisplaceTex ("DistortTexture", 2D) = "black" {}
		_DistortAmount ("DistortAmount", Range(0,0.1)) = 0
		_DistortTimeSpeed ("DistortSpeed", Range(0,1.0)) = 0
	}
	SubShader
	{
		// No culling or depth
		Cull Off ZWrite Off ZTest Always

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}
			
			sampler2D _MainTex;
			sampler2D _DisplaceTex;
			float _DistortAmount;
			float _DistortTimeSpeed;
			

			fixed4 frag (v2f i) : SV_Target
			{
				float timeOffset = float2(_Time.x, _Time.y) * _DistortTimeSpeed;
				float2 offset = tex2D(_DisplaceTex, i.uv + timeOffset).xy;
				offset = ((offset * 2) - 1) * _DistortAmount;

				fixed4 col = tex2D(_MainTex, i.uv + offset);

				return col;
			}
			ENDCG
		}
	}
}
