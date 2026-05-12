//
//  Particle.swift
//  ParticleSimulator
//
//  Created by Codex on 3/25/26.
//

import simd

struct Particle {
    var position: SIMD2<Float>
    var velocity: SIMD2<Float>
    var color: SIMD4<Float>
    var size: Float
    var life: Float
    var maxLife: Float
    var pad: Float = 0
}

struct ParticleSimulationUniforms {
    var environmentAcceleration: SIMD2<Float>
    var deltaTime: Float
    var dragFactor: Float
    var sizeFactor: Float
    var minimumSize: Float
    var minimumAlpha: Float
    var baseSize: Float
    var velocityScale: Float
    var materialID: UInt32
    var particleCount: UInt32
    var frameIndex: UInt32
}
