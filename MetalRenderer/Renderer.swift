//
//  Renderer.swift
//  MetalRenderer
//
//  Created by dominico park on 2020/08/02.
//  Copyright © 2020 dominico park. All rights reserved.
//

import Foundation
import MetalKit

class Renderer: NSObject {
    //GPU
    static var device: MTLDevice!
    static var library: MTLLibrary!
    let commandQueue: MTLCommandQueue
    let pipelineState: MTLRenderPipelineState
    
    init(view: MTKView) {
        guard let device = MTLCreateSystemDefaultDevice(),
            let commandQueue = device.makeCommandQueue() else {
                fatalError("unable to connect gpu")
        }
        Renderer.device = device
        Renderer.library = device.makeDefaultLibrary()
        self.commandQueue = commandQueue
        self.pipelineState = Renderer.makePipelineState()
        super.init()
    }
    
    static func makePipelineState() -> MTLRenderPipelineState {
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        
        //pixel format
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        
        //shader
        //vertext 위치
        let vertexFunc = Renderer.library.makeFunction(name: "vertex_main")
        //fragment 에 color 입히기
        let fragmentFunc = Renderer.library.makeFunction(name: "fragment_main")
        pipelineStateDescriptor.vertexFunction = vertexFunc
        pipelineStateDescriptor.fragmentFunction = fragmentFunc
        
        return try! Renderer.device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
    }
}

extension Renderer: MTKViewDelegate {
    //metalview size changed
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        print("metalview size changed")
    }
    
    func draw(in view: MTKView) {
        guard let commandBuffer = commandQueue.makeCommandBuffer(),
            let texture = view.currentDrawable,
            let descriptor = view.currentRenderPassDescriptor,
            let commandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor) else {
                return
        }
        commandEncoder.setRenderPipelineState(pipelineState)
        commandEncoder.drawPrimitives(type: .point, vertexStart: 0, vertexCount: 1)
        commandEncoder.endEncoding()
        
        commandBuffer.present(texture)
        commandBuffer.commit()
    }
    
    
}
