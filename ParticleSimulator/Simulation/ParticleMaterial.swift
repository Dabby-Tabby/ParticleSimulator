//
//  ParticleMaterial.swift
//  ParticleSimulator
//
//  Created by Codex on 3/25/26.
//

import Metal
import SwiftUI
import simd

enum ParticleMaterial: String, CaseIterable, Identifiable {
    case fire
    case water
    case dust
    case smoke
    case sparks
    case snow

    var id: Self { self }

    var gpuPresetID: UInt32 {
        switch self {
        case .fire: 0
        case .water: 1
        case .dust: 2
        case .smoke: 3
        case .sparks: 4
        case .snow: 5
        }
    }

    var displayName: String {
        switch self {
        case .fire: "Fire"
        case .water: "Water"
        case .dust: "Dust"
        case .smoke: "Smoke"
        case .sparks: "Sparks"
        case .snow: "Snow"
        }
    }

    var systemImage: String {
        switch self {
        case .fire: "flame.fill"
        case .water: "drop.fill"
        case .dust: "aqi.low"
        case .smoke: "cloud.fill"
        case .sparks: "sparkles"
        case .snow: "snowflake"
        }
    }

    var summary: String {
        switch self {
        case .fire:
            "Narrow thermal plume with fast lift and a short fade."
        case .water:
            "Heavy downward sheet with cooler color and a longer tail."
        case .dust:
            "Wide ambient field with slow drift and lingering haze."
        case .smoke:
            "Soft upward plume with slow curl, broad diffusion, and long fade."
        case .sparks:
            "Hot ballistic flecks with fast launch, sharp falloff, and bright pop."
        case .snow:
            "Cold drifting field with slow fall speed and wind-readable motion."
        }
    }

    var detail: String {
        switch self {
        case .fire:
            "Use fire for concentrated combustion studies, torch-like jets, or any scene that needs a hot centerline and quick dissipation."
        case .water:
            "Use water for rainfall and splash prototypes where particles stay cohesive, move decisively, and remain readable against a dark backdrop."
        case .dust:
            "Use dust for atmospheric layers, debris passes, and mood-heavy scenes where broad coverage matters more than directional force."
        case .smoke:
            "Use smoke for chimney plumes, exhaust, and soft volume-like effects where slow diffusion and long-lived particles matter."
        case .sparks:
            "Use sparks for welding bursts, ember sprays, or impacts where particles should launch hard, arc quickly, and disappear fast."
        case .snow:
            "Use snow for weather passes where thousands of small particles need gentle downward motion and visible side drift."
        }
    }

    var emissionNote: String {
        switch self {
        case .fire:
            "Emitter anchors low and tight to keep the core bright."
        case .water:
            "Emitter spans the upper edge for a curtain-like drop field."
        case .dust:
            "Emitter fills most of the frame for ambient coverage."
        case .smoke:
            "Emitter stays low and moderately wide to build a rising plume."
        case .sparks:
            "Emitter stays low and tight so flecks burst from a hot source."
        case .snow:
            "Emitter blankets the top edge for steady weather coverage."
        }
    }

    var motionNote: String {
        switch self {
        case .fire:
            "Velocity biases upward, then gravity pulls the plume apart."
        case .water:
            "Velocity starts downward and stays heavy with low drag."
        case .dust:
            "Velocity is intentionally weak so particles drift and settle."
        case .smoke:
            "Velocity rises slowly, then drag and wind spread the plume."
        case .sparks:
            "Velocity launches outward before gravity bends paths down."
        case .snow:
            "Velocity falls gently so wind becomes the most readable force."
        }
    }

    var fadeNote: String {
        switch self {
        case .fire:
            "Smaller lifespan and faster shrink make the plume flicker."
        case .water:
            "Larger droplets keep their body longer before leaving frame."
        case .dust:
            "Long lifetime preserves the haze and keeps the field soft."
        case .smoke:
            "Long lifetime and large points create a soft translucent column."
        case .sparks:
            "Short lifetime and rapid shrink keep the burst crisp."
        case .snow:
            "Slow decay keeps flakes legible across the viewport."
        }
    }

    var accent: Color {
        switch self {
        case .fire: .orange
        case .water: .cyan
        case .dust: .brown
        case .smoke: .gray
        case .sparks: .yellow
        case .snow: .white
        }
    }

    var panelTint: Color {
        accent.opacity(0.22)
    }

    var secondaryPanelTint: Color {
        switch self {
        case .fire:
            Color.red.opacity(0.18)
        case .water:
            Color.blue.opacity(0.18)
        case .dust:
            Color.yellow.opacity(0.16)
        case .smoke:
            Color.gray.opacity(0.18)
        case .sparks:
            Color.orange.opacity(0.20)
        case .snow:
            Color.white.opacity(0.18)
        }
    }

    var defaultParticleCount: Double {
        switch self {
        case .fire: 2400
        case .water: 1800
        case .dust: 3200
        case .smoke: 3600
        case .sparks: 1400
        case .snow: 4200
        }
    }

    var defaultParticleSize: Double {
        switch self {
        case .fire: 7.5
        case .water: 8.5
        case .dust: 5.5
        case .smoke: 10.0
        case .sparks: 3.2
        case .snow: 4.2
        }
    }

    var defaultVelocity: Double {
        switch self {
        case .fire: 1.0
        case .water: 0.9
        case .dust: 0.35
        case .smoke: 0.45
        case .sparks: 1.45
        case .snow: 0.42
        }
    }

    var defaultGravityScale: Double {
        switch self {
        case .fire: 1.0
        case .water: 1.15
        case .dust: 0.45
        case .smoke: 0.25
        case .sparks: 1.7
        case .snow: 0.7
        }
    }

    var defaultWindStrength: Double {
        switch self {
        case .fire: 0.0
        case .water: 0.0
        case .dust: 0.15
        case .smoke: 0.12
        case .sparks: 0.0
        case .snow: 0.05
        }
    }

    var clearColor: MTLClearColor {
        switch self {
        case .fire:
            MTLClearColor(red: 0.08, green: 0.04, blue: 0.03, alpha: 1.0)
        case .water:
            MTLClearColor(red: 0.03, green: 0.07, blue: 0.11, alpha: 1.0)
        case .dust:
            MTLClearColor(red: 0.09, green: 0.08, blue: 0.06, alpha: 1.0)
        case .smoke:
            MTLClearColor(red: 0.05, green: 0.05, blue: 0.055, alpha: 1.0)
        case .sparks:
            MTLClearColor(red: 0.045, green: 0.025, blue: 0.015, alpha: 1.0)
        case .snow:
            MTLClearColor(red: 0.025, green: 0.045, blue: 0.065, alpha: 1.0)
        }
    }

    var acceleration: SIMD2<Float> {
        switch self {
        case .fire:
            SIMD2<Float>(0, -0.42)
        case .water:
            SIMD2<Float>(0, -0.24)
        case .dust:
            SIMD2<Float>(0, -0.05)
        case .smoke:
            SIMD2<Float>(0, -0.08)
        case .sparks:
            SIMD2<Float>(0, -0.82)
        case .snow:
            SIMD2<Float>(0, -0.08)
        }
    }

    var windResponse: Float {
        switch self {
        case .fire: 0.72
        case .water: 0.32
        case .dust: 1.0
        case .smoke: 0.85
        case .sparks: 0.45
        case .snow: 0.95
        }
    }

    var drag: Float {
        switch self {
        case .fire: 0.12
        case .water: 0.02
        case .dust: 0.04
        case .smoke: 0.16
        case .sparks: 0.06
        case .snow: 0.03
        }
    }

    var sizeDecayRate: Float {
        switch self {
        case .fire: 0.18
        case .water: 0.05
        case .dust: 0.03
        case .smoke: 0.025
        case .sparks: 0.28
        case .snow: 0.005
        }
    }

    var minimumSize: Float {
        switch self {
        case .fire: 1.6
        case .water: 2.4
        case .dust: 1.8
        case .smoke: 4.0
        case .sparks: 1.0
        case .snow: 2.0
        }
    }

    var minimumAlpha: Float {
        switch self {
        case .fire: 0.06
        case .water: 0.10
        case .dust: 0.18
        case .smoke: 0.12
        case .sparks: 0.02
        case .snow: 0.32
        }
    }

    func makeParticle(baseSize: Float, velocityScale: Float) -> Particle {
        let lifetime = makeLifetime()

        return Particle(
            position: makeSpawnPosition(),
            velocity: makeVelocity(scale: velocityScale),
            color: makeColor(),
            size: makeSize(baseSize: baseSize),
            life: lifetime,
            maxLife: lifetime
        )
    }

    func respawn(_ particle: inout Particle, baseSize: Float, velocityScale: Float) {
        particle = makeParticle(baseSize: baseSize, velocityScale: velocityScale)
    }

    func isOutOfBounds(_ particle: Particle) -> Bool {
        switch self {
        case .fire:
            particle.position.y > 1.12 || abs(particle.position.x) > 1.18 || particle.position.y < -1.18
        case .water:
            particle.position.y < -1.12 || abs(particle.position.x) > 1.18 || particle.position.y > 1.18
        case .dust:
            particle.position.y > 1.18 || particle.position.y < -1.18 || abs(particle.position.x) > 1.22
        case .smoke:
            particle.position.y > 1.18 || particle.position.y < -1.2 || abs(particle.position.x) > 1.24
        case .sparks:
            particle.position.y > 1.18 || particle.position.y < -1.18 || abs(particle.position.x) > 1.22
        case .snow:
            particle.position.y < -1.14 || particle.position.y > 1.18 || abs(particle.position.x) > 1.24
        }
    }

    private func makeSpawnPosition() -> SIMD2<Float> {
        switch self {
        case .fire:
            SIMD2<Float>(random(-0.18...0.18), random(-0.96 ... -0.82))
        case .water:
            SIMD2<Float>(random(-0.78...0.78), random(0.76...0.96))
        case .dust:
            SIMD2<Float>(random(-0.94...0.94), random(-0.82...0.48))
        case .smoke:
            SIMD2<Float>(random(-0.26...0.26), random(-0.92 ... -0.76))
        case .sparks:
            SIMD2<Float>(random(-0.12...0.12), random(-0.90 ... -0.78))
        case .snow:
            SIMD2<Float>(random(-1.0...1.0), random(0.84...1.06))
        }
    }

    private func makeVelocity(scale: Float) -> SIMD2<Float> {
        let clampedScale = max(scale, 0.05)

        return switch self {
        case .fire:
            SIMD2<Float>(random(-0.22...0.22) * clampedScale, random(0.58...1.28) * clampedScale)
        case .water:
            SIMD2<Float>(random(-0.08...0.08) * clampedScale, -random(0.95...1.55) * clampedScale)
        case .dust:
            SIMD2<Float>(random(-0.16...0.16) * clampedScale, random(0.03...0.18) * clampedScale)
        case .smoke:
            SIMD2<Float>(random(-0.12...0.12) * clampedScale, random(0.20...0.58) * clampedScale)
        case .sparks:
            SIMD2<Float>(random(-0.95...0.95) * clampedScale, random(1.05...1.85) * clampedScale)
        case .snow:
            SIMD2<Float>(random(-0.08...0.08) * clampedScale, -random(0.18...0.48) * clampedScale)
        }
    }

    private func makeColor() -> SIMD4<Float> {
        switch self {
        case .fire:
            SIMD4<Float>(random(0.84...1.0), random(0.36...0.72), random(0.08...0.22), 0.92)
        case .water:
            SIMD4<Float>(random(0.28...0.54), random(0.62...0.92), random(0.88...1.0), 0.88)
        case .dust:
            SIMD4<Float>(random(0.68...0.84), random(0.60...0.74), random(0.42...0.56), 0.68)
        case .smoke:
            SIMD4<Float>(random(0.38...0.62), random(0.38...0.62), random(0.42...0.68), 0.50)
        case .sparks:
            SIMD4<Float>(random(0.95...1.0), random(0.56...0.88), random(0.08...0.22), 0.95)
        case .snow:
            SIMD4<Float>(random(0.86...1.0), random(0.90...1.0), random(0.96...1.0), 0.78)
        }
    }

    private func makeSize(baseSize: Float) -> Float {
        switch self {
        case .fire:
            baseSize * random(0.72...1.26)
        case .water:
            baseSize * random(0.82...1.32)
        case .dust:
            baseSize * random(0.58...1.22)
        case .smoke:
            baseSize * random(0.95...1.75)
        case .sparks:
            baseSize * random(0.45...1.05)
        case .snow:
            baseSize * random(0.55...1.15)
        }
    }

    private func makeLifetime() -> Float {
        switch self {
        case .fire:
            random(1.1...2.6)
        case .water:
            random(1.6...3.4)
        case .dust:
            random(4.2...7.8)
        case .smoke:
            random(4.8...9.0)
        case .sparks:
            random(0.65...1.8)
        case .snow:
            random(5.0...10.0)
        }
    }
}

private func random(_ range: ClosedRange<Float>) -> Float {
    Float.random(in: range)
}
