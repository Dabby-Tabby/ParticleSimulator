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
    var gravityScale: Float
    var windStrength: Float

    init(
        material: ParticleMaterial,
        particleCount: Int,
        particleSize: Float,
        velocityScale: Float,
        gravityScale: Float,
        windStrength: Float
    ) {
        self.material = material
        self.particleCount = max(particleCount, 100)
        self.particleSize = max(particleSize, 1)
        self.velocityScale = max(velocityScale, 0.05)
        self.gravityScale = max(0, min(gravityScale, 2))
        self.windStrength = max(-1.2, min(windStrength, 1.2))
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

    var gravityText: String {
        "\(gravityScale.formatted(.number.precision(.fractionLength(2))))x"
    }

    var windText: String {
        let sign = windStrength >= 0 ? "+" : ""
        return "\(sign)\(windStrength.formatted(.number.precision(.fractionLength(2))))"
    }
}
