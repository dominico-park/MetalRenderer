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
//    let vertices: [Vertex] = [
//        Vertex(position: float3(-0.5, -0.5, 1), color: float3(1, 0, 0)),
//        Vertex(position: float3(0.5, -0.5, 1), color: float3(0, 1, 0)),
//        Vertex(position: float3(0, 0.5, 1), color: float3(0, 0, 1)),
//        Vertex(position: float3(0.7, 0.7, 1), color: float3(0.5, 0.5, 0.5)),
//    ]
//
//    let indexArr: [UInt16] = [
//        0, 1, 2,
//        2, 1, 3
//    ]
//    let vertexBuffer: MTLBuffer
//    let indexBuffer: MTLBuffer
    var timer: Float = 0
    
    let train: Model
    
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
        //cpu 에서 vertex buffer를 만들기
//        let vertexLength = MemoryLayout<Vertex>.stride * vertices.count
//        vertexBuffer = device.makeBuffer(bytes: vertices, length: vertexLength, options: [])!
//
//        let indexLength = MemoryLayout<UInt16>.stride * indexArr.count
//        indexBuffer = device.makeBuffer(bytes: indexArr, length: indexLength, options: [])!
        
        //import model
        self.train = Model(name: "train")
        self.train.transform.position = [0.4, 0, 0]
        train.transform.scale = 0.5
        
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
}

extension Renderer: MTKViewDelegate {
    //metalview size changed
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        print("metalview size changed")
    }
    
    //each frame draw
    func draw(in view: MTKView) {
        guard let commandBuffer = commandQueue.makeCommandBuffer(),
            let texture = view.currentDrawable,
            let descriptor = view.currentRenderPassDescriptor,
            let commandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor) else {
                return
        }
        
        let projectionMatrix = float4x4(
            projectionFov: radians(fromDegrees: 65),
            near: 0.1,
            far: 100,
            aspect: Float(view.bounds.width / view.bounds.height)
        )
        
        timer += 0.05
        var currentTime = sin(timer)
        
        commandEncoder.setRenderPipelineState(pipelineState)
        commandEncoder.setDepthStencilState(depthStencilState)
        commandEncoder.setVertexBytes(
            &currentTime,
            length: MemoryLayout<Float>.stride,
            index: 2
        )
        
//        var modelTransform = Transform()
//        modelTransform.position = [0.5, 0, 0]
//        modelTransform.rotation.z = radians(fromDegrees: 45)
//        modelTransform.scale = 0.5
//        var modelMatrix = modelTransform.matrix
        var viewTransform = Transform()
        viewTransform.position.y = 1.0
        viewTransform.position.z = -2
        var viewMatrix = projectionMatrix * viewTransform.matrix.inverse
        
        commandEncoder.setVertexBytes(
            &viewMatrix,
            length: MemoryLayout<float4x4>.stride,
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
