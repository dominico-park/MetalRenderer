//
//  Shaders.metal
//  MetalRenderer
//
//  Created by dominico park on 2020/08/02.
//  Copyright © 2020 dominico park. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;


struct VertexOut {
    float4 position [[position]];
    float3 color;
};

vertex VertexOut vertex_main(device const float4 *positionBuffer [[buffer(0)]],
                             device const float3 *colorBuffer [[buffer(1)]],
                             uint vertexId [[vertex_id]],
                             constant float4x4 &modelMatrix [[buffer(21)]]) {
    VertexOut result {
        .position = modelMatrix * positionBuffer[vertexId],
        .color = colorBuffer[vertexId]
    };
    return result;
}

//rgba
fragment float4 fragment_main(VertexOut in [[stage_in]]) {
    return float4(in.color, 1);
}
