//
//  Renderer.swift
//  ParticleSimulator
//
//  Created by Nick Watts on 3/23/26.
//

import Foundation
import Metal
import MetalKit
import simd

final class Renderer: NSObject, MTKViewDelegate {
    private let device: MTLDevice
    private let commandQueue: MTLCommandQueue
    private let pipelineState: MTLRenderPipelineState

    private var configuration: ParticleSimulationConfiguration
    private var particles: [Particle] = []
    private var particleBuffer: MTLBuffer?

    private var lastTime: CFTimeInterval = CACurrentMediaTime()

    init(mtkView: MTKView, configuration: ParticleSimulationConfiguration) {
        guard let device = mtkView.device else {
            fatalError("MTKView has no Metal device.")
        }
        self.device = device
        self.configuration = configuration

        guard let commandQueue = device.makeCommandQueue() else {
            fatalError("Could not create command queue.")
        }
        self.commandQueue = commandQueue

        guard let library = device.makeDefaultLibrary() else {
            fatalError("Could not create default Metal library.")
        }

        let vertexFunction = library.makeFunction(name: "particleVertex")
        let fragmentFunction = library.makeFunction(name: "particleFragment")

        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.label = "Particle Pipeline"
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.colorAttachments[0].pixelFormat = mtkView.colorPixelFormat

        // Add alpha blending so particles look better
        let attachment = pipelineDescriptor.colorAttachments[0]!
        attachment.isBlendingEnabled = true
        attachment.rgbBlendOperation = .add
        attachment.alphaBlendOperation = .add
        attachment.sourceRGBBlendFactor = .sourceAlpha
        attachment.sourceAlphaBlendFactor = .sourceAlpha
        attachment.destinationRGBBlendFactor = .oneMinusSourceAlpha
        attachment.destinationAlphaBlendFactor = .oneMinusSourceAlpha

        do {
            pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        } catch {
            fatalError("Failed to create render pipeline state: \(error)")
        }

        super.init()

        rebuildParticleSystem()
    }

    func update(configuration: ParticleSimulationConfiguration) {
        guard self.configuration != configuration else { return }
        self.configuration = configuration
        rebuildParticleSystem()
    }

    private func rebuildParticleSystem() {
        particles = (0..<configuration.particleCount).map { _ in
            configuration.material.makeParticle(
                baseSize: configuration.particleSize,
                velocityScale: configuration.velocityScale
            )
        }

        makeParticleBuffer()
        uploadParticlesToGPU()
        lastTime = CACurrentMediaTime()
    }

    private func respawnParticle(at index: Int) {
        configuration.material.respawn(
            &particles[index],
            baseSize: configuration.particleSize,
            velocityScale: configuration.velocityScale
        )
    }

    private func makeParticleBuffer() {
        let length = max(MemoryLayout<Particle>.stride * particles.count, MemoryLayout<Particle>.stride)

        if particleBuffer?.length != length {
            particleBuffer = device.makeBuffer(length: length, options: .storageModeShared)
            particleBuffer?.label = "Particle Buffer"
        }
    }

    private func uploadParticlesToGPU() {
        guard let particleBuffer, !particles.isEmpty else { return }

        particles.withUnsafeBytes { rawBuffer in
            guard let baseAddress = rawBuffer.baseAddress else { return }
            particleBuffer.contents().copyMemory(from: baseAddress, byteCount: rawBuffer.count)
        }
    }

    private func updateParticles(deltaTime dt: Float) {
        let material = configuration.material
        let dragFactor = max(0, 1 - material.drag * dt)
        let sizeFactor = max(0.75, 1 - material.sizeDecayRate * dt)

        for i in particles.indices {
            particles[i].life -= dt

            if particles[i].life <= 0 {
                respawnParticle(at: i)
                continue
            }

            particles[i].position += particles[i].velocity * dt
            particles[i].velocity += material.acceleration * dt
            particles[i].velocity *= dragFactor

            let t = max(particles[i].life / particles[i].maxLife, 0)
            particles[i].color.w = max(material.minimumAlpha, t)

            particles[i].size = max(material.minimumSize, particles[i].size * sizeFactor)

            if material.isOutOfBounds(particles[i]) {
                respawnParticle(at: i)
            }
        }

        uploadParticlesToGPU()
    }

    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        // You can store size here later for aspect ratio logic
    }

    func draw(in view: MTKView) {
        guard
            let drawable = view.currentDrawable,
            let passDescriptor = view.currentRenderPassDescriptor,
            let commandBuffer = commandQueue.makeCommandBuffer(),
            let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: passDescriptor),
            let particleBuffer = particleBuffer
        else {
            return
        }

        let now = CACurrentMediaTime()
        let dt = Float(now - lastTime)
        lastTime = now

        updateParticles(deltaTime: min(dt, 1.0 / 30.0))

        renderEncoder.setRenderPipelineState(pipelineState)
        renderEncoder.setVertexBuffer(particleBuffer, offset: 0, index: 0)
        renderEncoder.drawPrimitives(type: .point, vertexStart: 0, vertexCount: particles.count)
        renderEncoder.endEncoding()

        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}
