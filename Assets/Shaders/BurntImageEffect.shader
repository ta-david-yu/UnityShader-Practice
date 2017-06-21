Shader "Custom/ImageEffect/BurntImageEffect"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}

		_DissolveTex ("Noise (RGB)", 2D) = "white" {}
		_DissolveAmount ("DissolveAmount", Range(0.0,1.0)) = 0.0

		_DissolveEdge ("DissolveEdgeAmount", Range(0.0,1.0)) = 0.0
		_DissolveEdgeColor ("DissolveEdgeColor", Color) = (1,1,0,1)

		_BurnRamp ("Burn Ramp (RGB)", 2D) = "white" {}
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
			sampler2D _DissolveTex;
			sampler2D _BurnRamp;
			half _DissolveAmount;
		
			half _DissolveEdge;
			fixed4 _DissolveEdgeColor;

			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv);

				// if < 0, clip to black
				float burntValue = tex2D(_DissolveTex, i.uv).rgb - _DissolveAmount;
				if (burntValue < 0)
				{
					col *= 0.0;
				}
				else
				{
					float negAmount = saturate(burntValue / _DissolveEdge);
					float edgeColorAmount = 1 - saturate(burntValue / _DissolveEdge);

					fixed4 edgeColor = edgeColorAmount * _DissolveEdgeColor;
					
					col += edgeColor;
					// col *= 1 / negAmount;
				}
					

				return col;
			}
			ENDCG
		}
	}
}
