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
    float point_size [[point_size]];
    float3 color;
};

//position: x, y, z, w
vertex VertexOut vertex_main() {
    VertexOut result {
        .position = float4(0, 0, 0, 1),
        .point_size = 60,
        .color = float3(0, 1, 0)
    };
    return result;
}

//rgba
fragment float4 fragment_main() {
    return float4(0, 0, 1, 1);
}
