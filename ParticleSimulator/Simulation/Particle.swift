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
