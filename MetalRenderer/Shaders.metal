//
//  Shaders.metal
//  MetalRenderer
//
//  Created by dominico park on 2020/08/02.
//  Copyright © 2020 dominico park. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

//position: x, y, z, w
constant float4 position[3] = {
    float4(-1, -1, 0, 1),
    float4(1, -0.5, 0.3, 1),
    float4(0.5, 1, 1, 1)
};

//color rgb
constant float3 color[3] = {
    float3(1, 0, 0),
    float3(0, 1, 0),
    float3(0, 0, 1)
};

struct VertexOut {
    float4 position [[position]];
    float point_size [[point_size]];
    float3 color;
};

vertex VertexOut vertex_main(uint vertexId [[vertex_id]]) {
    VertexOut result {
        .position = position[vertexId],
        .point_size = 60,
        .color = color[vertexId]
    };
    return result;
}

//rgba
fragment float4 fragment_main(VertexOut in [[stage_in]]) {
    return float4(in.color, 1);
}
