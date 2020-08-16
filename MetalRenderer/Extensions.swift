//
//  Extensions.swift
//  MetalRenderer
//
//  Created by junwoo on 2020/08/16.
//  Copyright © 2020 dominico park. All rights reserved.
//

import Foundation
import MetalKit

extension MTLVertexDescriptor {
    static func defaultVertexDescriptor() -> MTLVertexDescriptor {
        let descriptor = MTLVertexDescriptor()
        
        //position
        descriptor.attributes[0].format = .float3
        descriptor.attributes[0].offset = 0
        descriptor.attributes[0].bufferIndex = 0
        
        //color
        descriptor.attributes[1].format = .float3
        descriptor.attributes[1].offset = MemoryLayout<float3>.stride
        descriptor.attributes[1].bufferIndex = 0
        
        //stride
        descriptor.layouts[0].stride = MemoryLayout<Vertex>.stride
        
        return descriptor
    }
}
