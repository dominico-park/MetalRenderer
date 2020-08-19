//
//  Shaders.metal
//  MetalRenderer
//
//  Created by dominico park on 2020/08/02.
//  Copyright © 2020 dominico park. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

#import "Common.h"



constant float3 color[6] = {
    float3(1, 0, 0),
    float3(0, 1, 0),
    float3(0, 0, 1),
    float3(0, 0, 1),
    float3(0, 1, 0),
    float3(1, 0, 1),
};

struct VertexIn {
    float4 position [[attribute(0)]];
    //float3 color [[attribute(1)]];
};

struct VertexOut {
    float4 position [[position]];
    float3 color;
};

vertex VertexOut vertex_main(VertexIn vertexBuffer [[stage_in]],
                             constant float &timer [[buffer(2)]],
                             constant Uniforms &uniforms [[buffer(21)]],
                             constant int &colorIndex [[buffer(12)]]
                             ) {
    VertexOut result {
        .position = uniforms.projectionMatrix * uniforms.viewMatrix * uniforms.modelMatrix * vertexBuffer.position,
        .color = color[colorIndex]
    };
    result.position.x += timer;
    return result;
}

//rgba
fragment float4 fragment_main(VertexOut in [[stage_in]]) {
    return float4(in.color, 1);
}
