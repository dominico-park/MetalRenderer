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
    let depthStencilState: MTLDepthStencilState

    var timer: Float = 0
    let camera: Camera = Camera()
    let train: Model
    var uniforms = Uniforms()
    
    init(view: MTKView) {
        guard let device = MTLCreateSystemDefaultDevice(),
            let commandQueue = device.makeCommandQueue() else {
                fatalError("unable to connect gpu")
        }
        Renderer.device = device
        Renderer.library = device.makeDefaultLibrary()
        self.commandQueue = commandQueue
        self.pipelineState = Renderer.makePipelineState()
        depthStencilState = Renderer.makeDepthStencilState()
        
        view.depthStencilPixelFormat = .depth32Float
 
        self.train = Model(name: "train")
        self.train.transform.position = [0.4, 0, 0]
        train.transform.scale = 0.5
        camera.transform.position = [0, 1.0, -2]
        
        super.init()
    }
    
    static func makeDepthStencilState() -> MTLDepthStencilState {
        let depthDescriptor = MTLDepthStencilDescriptor()
        depthDescriptor.depthCompareFunction = .less
        depthDescriptor.isDepthWriteEnabled = true
        return Renderer.device.makeDepthStencilState(descriptor: depthDescriptor)!
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
        pipelineStateDescriptor.vertexDescriptor = MTLVertexDescriptor.defaultVertexDescriptor()
        pipelineStateDescriptor.depthAttachmentPixelFormat = .depth32Float
        return try! Renderer.device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
    }
    
    func zoom(delta: Float) {
        let sensitivity: Float = 0.05
        let cameraVector = camera.transform.matrix.upperLeft.columns.2
        camera.transform.position += delta * sensitivity * cameraVector
    }
}

extension Renderer: MTKViewDelegate {
    //metalview size changed
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        camera.aspect = Float(view.bounds.width / view.bounds.height)
    }
    
    //each frame draw
    func draw(in view: MTKView) {
        guard let commandBuffer = commandQueue.makeCommandBuffer(),
            let texture = view.currentDrawable,
            let descriptor = view.currentRenderPassDescriptor,
            let commandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor) else {
                return
        }
        
        uniforms.viewMatrix = camera.viewMatrix
        uniforms.projectionMatrix = camera.projectionMatrix
        uniforms.modelMatrix = train.transform.matrix
        
        timer += 0.05
        var currentTime = sin(timer)
        
        commandEncoder.setRenderPipelineState(pipelineState)
        commandEncoder.setDepthStencilState(depthStencilState)
        commandEncoder.setVertexBytes(
            &currentTime,
            length: MemoryLayout<Float>.stride,
            index: 2
        )
        
        commandEncoder.setVertexBytes(
            &uniforms,
            length: MemoryLayout<Uniforms>.stride,
            index: 21
        )
        
        //vertex buffer 를 gpu 에 전달
        for mtkMesh in train.mtkMeshes {
            
            for vertexBuffer in mtkMesh.vertexBuffers {
                commandEncoder.setVertexBuffer(vertexBuffer.buffer, offset: 0, index: 0)
                
                var colorIndex: Int = 0
                
                for subMesh in mtkMesh.submeshes {
                    
                    commandEncoder.setVertexBytes(
                        &colorIndex,
                        length: MemoryLayout<Int>.stride,
                        index: 12
                    )
                    
                    commandEncoder.drawIndexedPrimitives(
                        type: .triangle,
                        indexCount: subMesh.indexCount,
                        indexType: subMesh.indexType,
                        indexBuffer: subMesh.indexBuffer.buffer,
                        indexBufferOffset: subMesh.indexBuffer.offset
                    )
                    colorIndex += 1
                }
            }
        }
        
        commandEncoder.endEncoding()
        
        commandBuffer.present(texture)
        commandBuffer.commit()
    }
    
    
}
