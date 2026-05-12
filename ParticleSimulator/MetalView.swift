//
//  MetalView.swift
//  ParticleSimulator
//
//  Created by Nick Watts on 3/23/26.
//

import SwiftUI
import MetalKit

struct MetalView: NSViewRepresentable {
    let configuration: ParticleSimulationConfiguration
    let performanceMetrics: PerformanceMetrics

    func makeNSView(context: Context) -> MTKView {
        guard let device = MTLCreateSystemDefaultDevice() else {
            fatalError("Metal is not supported on this Mac.")
        }

        let view = MTKView(frame: .zero, device: device)
        view.clearColor = configuration.material.clearColor
        view.colorPixelFormat = .bgra8Unorm
        view.preferredFramesPerSecond = 60
        view.enableSetNeedsDisplay = false
        view.isPaused = false

        let renderer = Renderer(
            mtkView: view,
            configuration: configuration,
            performanceMetrics: performanceMetrics
        )
        view.delegate = renderer

        context.coordinator.renderer = renderer
        return view
    }

    func updateNSView(_ nsView: MTKView, context: Context) {
        nsView.clearColor = configuration.material.clearColor
        context.coordinator.renderer?.update(configuration: configuration)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    final class Coordinator {
        var renderer: Renderer?
    }
}

#Preview {
    MetalView(
        configuration: ParticleSimulationModel().configuration,
        performanceMetrics: PerformanceMetrics()
    )
}
