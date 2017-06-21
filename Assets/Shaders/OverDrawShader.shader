Shader "Custom/OverDrawShader"
{
	Properties
	{
		_OverDrawColor ("Color", Color) = (1, 1, 1, 1)
	}
	SubShader
	{
		Tags 
		{ 
			"Queue" = "Transparent"
		}
		LOD 100
		ZTest Always
		ZWrite Off
		Blend One One

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
			};

			float4 _OverDrawColor;

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				return _OverDrawColor;
			}
			ENDCG
		}
	}
}
