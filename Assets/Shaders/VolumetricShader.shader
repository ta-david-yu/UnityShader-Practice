// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Custom/VolumeShader"
{
	Properties
	{
		_Color ("MainColor", Color) = (1,1,1,1)
		_SphereColor ("SphereColor", Color) = (1,0,0,1)
		_Center ("SphereCenter", Vector) = (0,0,0,0)
		_Radius ("SphereRadius", float) = 2.0
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"

			#define STEPS 128 
			#define STEP_SIZE 0.01

			struct appdata
			{
				float4 vertex : POSITION;
			};

			struct v2f
			{
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
				float3 worldPos : TEXCOORD1;
			};

			float4 _Color;
			float4 _SphereColor;
			float4 _Center;
			float _Radius;
			

			float insideSphere(float3 p, float3 center, float radius)
			{
				return distance(p, center) - radius;
			}

			bool racastHitSphere(float3 start, float3 direction, float3 center, float radius)
			{
				for (int i = 0; i < STEPS; i++)
				{
					float newDis = insideSphere(start, center, radius);

					if (newDis < 0)
						return true;

					start += direction * (newDis + 0.1);
				}
				return false;
			}

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = _Color;
				float3 direction = normalize(i.worldPos - _WorldSpaceCameraPos);

				if (racastHitSphere(i.worldPos, direction, _Center, _Radius))
					col = _SphereColor;
				// apply fog
				UNITY_APPLY_FOG(i.fogCoord, col);

				return col;
			}
			ENDCG
		}
	}
}
