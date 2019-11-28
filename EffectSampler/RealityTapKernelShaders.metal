//
//  Shockwave.metal
//
//  Created by Alex Linkov on 11/25/19.
//  Copyright © 2019 SDWR. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;


kernel void ripple(texture2d<float, access::write> target [[texture(0)]],
                    texture2d<float, access::sample> source [[texture(1)]],
                    constant float &timer [[buffer(0)]],
                    constant float2 &touchedPoint [[buffer(1)]],
                    uint2 gridPosition [[thread_position_in_grid]])
{
    
    
    float time = timer *  1.3;

    
    float3 waveParams = float3( 10.0, 0.8, 0.1 );
    float2 tmp = float2( touchedPoint.xy /  float2(source.get_width(), source.get_height()) );
    float2 uv = float2(gridPosition) / float2(source.get_width(), source.get_height());
    float2 texCoord = uv;
    float dist = distance(uv, tmp);
    
    if ( (dist <= ((time ) + waveParams.z )) && ( dist >= ((time ) - waveParams.z)) )
    {
           float diff = (dist - (time));
           float powDiff = 1.0 - pow(abs(diff*waveParams.x), waveParams.y);
        
           float diffTime = diff  * powDiff;
           float2 diffUV = normalize(uv - tmp);
           texCoord = uv + (diffUV * diffTime);
           
    }
    
    constexpr sampler textureSampler(coord::normalized,
                                     address::repeat,
                                     min_filter::linear,
                                     mag_filter::linear,
                                     mip_filter::linear );
    
    float4 outputColor = source.sample(textureSampler,texCoord).rgba;
    target.write(outputColor, gridPosition);
    


}


kernel void shockwave(texture2d<float, access::write> target [[texture(0)]],
                    texture2d<float, access::sample> source [[texture(1)]],
                    constant float &timer [[buffer(0)]],
                    constant float2 &touchedPoint [[buffer(1)]],
                    uint2 gridPosition [[thread_position_in_grid]])
{
    
    

    if ((gridPosition.x >= source.get_width()) || (gridPosition.y >= source.get_height())) {
        return;
    }

    
    float currentTime = timer *  1.3;

    float3 WaveParams = float3(18.0, 0.8, 0.2 );

    float2 WaveCentre = float2( touchedPoint.xy /  float2(source.get_width(), source.get_height()) );
    float2 texCoord = float2(gridPosition) / float2(source.get_width(), source.get_height());
    
    float Dist = distance(texCoord, WaveCentre);


    constexpr sampler textureSampler(coord::normalized,
                                     address::repeat,
                                     min_filter::linear,
                                     mag_filter::linear,
                                     mip_filter::linear );


    float4 outputColor = source.sample(textureSampler,texCoord).rgba;


    if ((Dist <= ((currentTime) + (WaveParams.z))) &&
    (Dist >= ((currentTime) - (WaveParams.z))))
    {

        //The pixel offset distance based on the input parameters
        float Diff = (Dist - currentTime);
        float ScaleDiff = (1.0 - pow(abs(Diff * WaveParams.x), WaveParams.y));
        float DiffTime = (Diff  * ScaleDiff);

        //The direction of the distortion
        float2 DiffTexCoord = normalize(texCoord - WaveCentre);

        //Perform the distortion and reduce the effect over time
        texCoord += ((DiffTexCoord * DiffTime) / (currentTime * Dist * 40.0));


        outputColor = source.sample(textureSampler,texCoord).rgba;

        //Blow out the color and reduce the effect over time
        outputColor += (outputColor * ScaleDiff) / (currentTime * Dist * 40.0);
    }



    target.write(outputColor, gridPosition);

}
