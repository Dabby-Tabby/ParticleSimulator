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
    private let computePipelineState: MTLComputePipelineState

    private var configuration: ParticleSimulationConfiguration
    private var particles: [Particle] = []
    private var particleBuffer: MTLBuffer?
    private weak var performanceMetrics: PerformanceMetrics?

    private var lastTime: CFTimeInterval = CACurrentMediaTime()
    private var frameIndex: UInt32 = 0
    private var metricsSampleStartTime: CFTimeInterval = CACurrentMediaTime()
    private var metricsFrameCount = 0
    private var metricsFrameDurationTotal: CFTimeInterval = 0
    private var metricsUpdateDurationTotal: CFTimeInterval = 0
    private let metricsSampleInterval: CFTimeInterval = 0.5

    init(
        mtkView: MTKView,
        configuration: ParticleSimulationConfiguration,
        performanceMetrics: PerformanceMetrics?
    ) {
        guard let device = mtkView.device else {
            fatalError("MTKView has no Metal device.")
        }
        self.device = device
        self.configuration = configuration
        self.performanceMetrics = performanceMetrics

        guard let commandQueue = device.makeCommandQueue() else {
            fatalError("Could not create command queue.")
        }
        self.commandQueue = commandQueue

        guard let library = device.makeDefaultLibrary() else {
            fatalError("Could not create default Metal library.")
        }

        let vertexFunction = library.makeFunction(name: "particleVertex")
        let fragmentFunction = library.makeFunction(name: "particleFragment")
        guard let computeFunction = library.makeFunction(name: "updateParticlesCompute") else {
            fatalError("Could not find updateParticlesCompute Metal function.")
        }

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
            computePipelineState = try device.makeComputePipelineState(function: computeFunction)
        } catch {
            fatalError("Failed to create Metal pipeline state: \(error)")
        }

        super.init()

        rebuildParticleSystem()
    }

    func update(configuration: ParticleSimulationConfiguration) {
        guard self.configuration != configuration else { return }

        let shouldRebuildParticleSystem =
            self.configuration.material != configuration.material ||
            self.configuration.particleCount != configuration.particleCount ||
            self.configuration.particleSize != configuration.particleSize ||
            self.configuration.velocityScale != configuration.velocityScale

        self.configuration = configuration

        if shouldRebuildParticleSystem {
            rebuildParticleSystem()
        }
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

    private func makeSimulationUniforms(deltaTime dt: Float) -> ParticleSimulationUniforms {
        let material = configuration.material
        let dragFactor = max(0, 1 - material.drag * dt)
        let sizeFactor = max(0.75, 1 - material.sizeDecayRate * dt)
        let environmentAcceleration = SIMD2<Float>(
            configuration.windStrength * material.windResponse,
            material.acceleration.y * configuration.gravityScale
        )

        return ParticleSimulationUniforms(
            environmentAcceleration: environmentAcceleration,
            deltaTime: dt,
            dragFactor: dragFactor,
            sizeFactor: sizeFactor,
            minimumSize: material.minimumSize,
            minimumAlpha: material.minimumAlpha,
            baseSize: configuration.particleSize,
            velocityScale: configuration.velocityScale,
            materialID: material.gpuPresetID,
            particleCount: UInt32(particles.count),
            frameIndex: frameIndex
        )
    }

    private func encodeParticleUpdate(commandBuffer: MTLCommandBuffer, deltaTime dt: Float) {
        guard let particleBuffer, !particles.isEmpty else { return }
        guard let computeEncoder = commandBuffer.makeComputeCommandEncoder() else { return }

        var uniforms = makeSimulationUniforms(deltaTime: dt)
        let threadCount = MTLSize(width: particles.count, height: 1, depth: 1)
        let threadgroupWidth = min(256, computePipelineState.maxTotalThreadsPerThreadgroup)
        let threadsPerThreadgroup = MTLSize(width: threadgroupWidth, height: 1, depth: 1)

        computeEncoder.label = "Particle Simulation Compute Encoder"
        computeEncoder.setComputePipelineState(computePipelineState)
        computeEncoder.setBuffer(particleBuffer, offset: 0, index: 0)
        computeEncoder.setBytes(
            &uniforms,
            length: MemoryLayout<ParticleSimulationUniforms>.stride,
            index: 1
        )
        computeEncoder.dispatchThreads(threadCount, threadsPerThreadgroup: threadsPerThreadgroup)
        computeEncoder.endEncoding()

        frameIndex &+= 1
    }

    private func recordPerformanceSample(frameStartTime: CFTimeInterval, updateDuration: CFTimeInterval) {
        guard let performanceMetrics else { return }

        let now = CACurrentMediaTime()
        let frameDuration = now - frameStartTime

        metricsFrameCount += 1
        metricsFrameDurationTotal += frameDuration
        metricsUpdateDurationTotal += updateDuration

        let sampleDuration = now - metricsSampleStartTime
        guard sampleDuration >= metricsSampleInterval else { return }

        let frameCount = max(metricsFrameCount, 1)
        let framesPerSecond = Double(frameCount) / sampleDuration
        let frameTimeMilliseconds = framesPerSecond > 0 ? 1000 / framesPerSecond : 0
        let cpuFrameTimeMilliseconds = (metricsFrameDurationTotal / Double(frameCount)) * 1000
        let cpuUpdateMilliseconds = (metricsUpdateDurationTotal / Double(frameCount)) * 1000
        let particleCount = particles.count

        DispatchQueue.main.async { [weak performanceMetrics] in
            performanceMetrics?.update(
                framesPerSecond: framesPerSecond,
                frameTimeMilliseconds: frameTimeMilliseconds,
                cpuFrameTimeMilliseconds: cpuFrameTimeMilliseconds,
                cpuUpdateMilliseconds: cpuUpdateMilliseconds,
                particleCount: particleCount
            )
        }

        metricsSampleStartTime = now
        metricsFrameCount = 0
        metricsFrameDurationTotal = 0
        metricsUpdateDurationTotal = 0
    }

    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        // You can store size here later for aspect ratio logic
    }

    func draw(in view: MTKView) {
        let frameStartTime = CACurrentMediaTime()

        guard
            let drawable = view.currentDrawable,
            let passDescriptor = view.currentRenderPassDescriptor,
            let commandBuffer = commandQueue.makeCommandBuffer(),
            let particleBuffer = particleBuffer
        else {
            return
        }

        let now = CACurrentMediaTime()
        let dt = Float(now - lastTime)
        lastTime = now

        let updateStartTime = CACurrentMediaTime()
        encodeParticleUpdate(commandBuffer: commandBuffer, deltaTime: min(dt, 1.0 / 30.0))
        let updateDuration = CACurrentMediaTime() - updateStartTime

        guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: passDescriptor) else {
            return
        }

        renderEncoder.setRenderPipelineState(pipelineState)
        renderEncoder.setVertexBuffer(particleBuffer, offset: 0, index: 0)
        renderEncoder.drawPrimitives(type: .point, vertexStart: 0, vertexCount: particles.count)
        renderEncoder.endEncoding()

        commandBuffer.present(drawable)
        commandBuffer.commit()

        recordPerformanceSample(frameStartTime: frameStartTime, updateDuration: updateDuration)
    }
}
