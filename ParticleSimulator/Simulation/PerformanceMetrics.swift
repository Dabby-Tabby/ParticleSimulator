//
//  PerformanceMetrics.swift
//  ParticleSimulator
//
//  Created by Codex on 5/12/26.
//

import Foundation
import Observation

@Observable
final class PerformanceMetrics {
    var framesPerSecond: Double = 0
    var frameTimeMilliseconds: Double = 0
    var cpuFrameTimeMilliseconds: Double = 0
    var cpuUpdateMilliseconds: Double = 0
    var particleCount: Int = 0

    var fpsText: String {
        framesPerSecond.formatted(.number.precision(.fractionLength(0)))
    }

    var frameTimeText: String {
        "\(frameTimeMilliseconds.formatted(.number.precision(.fractionLength(2)))) ms"
    }

    var cpuFrameTimeText: String {
        "\(cpuFrameTimeMilliseconds.formatted(.number.precision(.fractionLength(2)))) ms"
    }

    var cpuUpdateTimeText: String {
        "\(cpuUpdateMilliseconds.formatted(.number.precision(.fractionLength(2)))) ms"
    }

    var particleCountText: String {
        particleCount.formatted(.number.grouping(.never))
    }

    func update(
        framesPerSecond: Double,
        frameTimeMilliseconds: Double,
        cpuFrameTimeMilliseconds: Double,
        cpuUpdateMilliseconds: Double,
        particleCount: Int
    ) {
        self.framesPerSecond = framesPerSecond
        self.frameTimeMilliseconds = frameTimeMilliseconds
        self.cpuFrameTimeMilliseconds = cpuFrameTimeMilliseconds
        self.cpuUpdateMilliseconds = cpuUpdateMilliseconds
        self.particleCount = particleCount
    }
}
