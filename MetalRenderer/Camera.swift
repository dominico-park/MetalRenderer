//
//  Camera.swift
//  MetalRenderer
//
//  Created by junwoo on 2020/08/19.
//  Copyright © 2020 dominico park. All rights reserved.
//

import Foundation
import MetalKit

class Camera {
    
    var transform = Transform()
    var viewMatrix: float4x4 {
        let translate = float4x4(translation: transform.position)
        let rotate = float4x4(rotation: transform.rotation)
        let scale = float4x4(scaling: transform.scale)
        return (translate * scale * rotate).inverse
    }
    
    var fov = radians(fromDegrees: 65)
    var near: Float = 0.1
    var far: Float = 100
    var aspect: Float = 1
    
    var projectionMatrix: float4x4 {
        return float4x4(
            projectionFov: fov,
            near: near,
            far: far,
            aspect: aspect)
    }
}
