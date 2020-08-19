//
//  Common.h
//  MetalRenderer
//
//  Created by junwoo on 2020/08/19.
//  Copyright © 2020 dominico park. All rights reserved.
//

#ifndef Common_h
#define Common_h

#import <simd/simd.h>

typedef struct {
    matrix_float4x4 modelMatrix;
    matrix_float4x4 viewMatrix;
    matrix_float4x4 projectionMatrix;
} Uniforms;

#endif /* Common_h */
