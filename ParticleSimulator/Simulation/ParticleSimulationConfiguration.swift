//
//  ParticleSimulationConfiguration.swift
//  ParticleSimulator
//
//  Created by Codex on 3/25/26.
//

import Foundation

struct ParticleSimulationConfiguration: Equatable {
    var material: ParticleMaterial
    var particleCount: Int
    var particleSize: Float
    var velocityScale: Float

    init(
        material: ParticleMaterial,
        particleCount: Int,
        particleSize: Float,
        velocityScale: Float
    ) {
        self.material = material
        self.particleCount = max(particleCount, 100)
        self.particleSize = max(particleSize, 1)
        self.velocityScale = max(velocityScale, 0.05)
    }

    var particleCountText: String {
        particleCount.formatted(.number.grouping(.never))
    }

    var particleSizeText: String {
        "\(particleSize.formatted(.number.precision(.fractionLength(1)))) pt"
    }

    var velocityText: String {
        "\(velocityScale.formatted(.number.precision(.fractionLength(2))))x"
    }
}
