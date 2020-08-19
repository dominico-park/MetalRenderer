//
//  ViewController.swift
//  MetalRenderer
//
//  Created by dominico park on 2020/08/02.
//  Copyright © 2020 dominico park. All rights reserved.
//

import Cocoa
import MetalKit

class ViewController: NSViewController {

    @IBOutlet var metalView: MTKView!
    var renderer: Renderer?
    override func viewDidLoad() {
        super.viewDidLoad()
        renderer = Renderer(view: metalView)
        metalView.device = Renderer.device
        metalView.delegate = renderer
        metalView.clearColor = MTLClearColor(red: 1, green: 1, blue: 0.8, alpha: 1)
    }
    
    override func scrollWheel(with event: NSEvent) {
        renderer?.zoom(delta: Float(event.deltaY))
    }
}

