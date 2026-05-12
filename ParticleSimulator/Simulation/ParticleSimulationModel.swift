//
//  ParticleSimulationModel.swift
//  ParticleSimulator
//
//  Created by Codex on 3/25/26.
//

import Observation
import Foundation

@MainActor
@Observable
final class ParticleSimulationModel {
    let countRange: ClosedRange<Double> = 400...6000
    let sizeRange: ClosedRange<Double> = 2.0...18.0
    let velocityRange: ClosedRange<Double> = 0.2...1.8
    let gravityRange: ClosedRange<Double> = 0.0...2.0
    let windRange: ClosedRange<Double> = -1.2...1.2

    var selectedMaterial: ParticleMaterial {
        didSet {
            guard oldValue != selectedMaterial else { return }
            applyDefaults(for: selectedMaterial)
        }
    }

    var particleCount: Double
    var particleSize: Double
    var velocityScale: Double
    var gravityScale: Double
    var windStrength: Double

    init(selectedMaterial: ParticleMaterial = .fire) {
        self.selectedMaterial = selectedMaterial
        self.particleCount = selectedMaterial.defaultParticleCount
        self.particleSize = selectedMaterial.defaultParticleSize
        self.velocityScale = selectedMaterial.defaultVelocity
        self.gravityScale = selectedMaterial.defaultGravityScale
        self.windStrength = selectedMaterial.defaultWindStrength
    }

    var configuration: ParticleSimulationConfiguration {
        ParticleSimulationConfiguration(
            material: selectedMaterial,
            particleCount: Int(particleCount.rounded()),
            particleSize: Float(particleSize),
            velocityScale: Float(velocityScale),
            gravityScale: Float(gravityScale),
            windStrength: Float(windStrength)
        )
    }

    var particleCountText: String {
        Int(particleCount.rounded()).formatted(.number.grouping(.never))
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

    func resetToPreset() {
        applyDefaults(for: selectedMaterial)
    }

    private func applyDefaults(for material: ParticleMaterial) {
        particleCount = material.defaultParticleCount
        particleSize = material.defaultParticleSize
        velocityScale = material.defaultVelocity
        gravityScale = material.defaultGravityScale
        windStrength = material.defaultWindStrength
    }
}
