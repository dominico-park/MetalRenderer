//
//  Shaders.metal
//  MetalRenderer
//
//  Created by dominico park on 2020/08/02.
//  Copyright © 2020 dominico park. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct VertexIn {
    float4 position [[attribute(0)]];
    float3 color [[attribute(1)]];
};

struct VertexOut {
    float4 position [[position]];
    float3 color;
};

vertex VertexOut vertex_main(VertexIn vertexBuffer [[stage_in]],
                             constant float &timer [[buffer(2)]],
                             constant float4x4 &modelMatrix [[buffer(21)]]) {
    VertexOut result {
        .position = modelMatrix * vertexBuffer.position,
        .color = vertexBuffer.color
    };
    result.position.x += timer;
    return result;
}

//rgba
fragment float4 fragment_main(VertexOut in [[stage_in]]) {
    return float4(in.color, 1);
}
