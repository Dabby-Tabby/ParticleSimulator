//
//  PerformanceHUDView.swift
//  ParticleSimulator
//
//  Created by Codex on 5/12/26.
//

import SwiftUI

struct PerformanceHUDView: View {
    let metrics: PerformanceMetrics
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 8) {
                Text("PERFORMANCE")
                    .font(.caption)
                    .bold()
                    .tracking(1.2)
                    .foregroundStyle(.secondary)

                Text("Renderer Telemetry")
                    .font(.headline.bold())

                Text("CPU timing is sampled twice per second to avoid polluting the measurement.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Divider()

            VStack(alignment: .leading, spacing: 10) {
                LabeledContent {
                    Text(metrics.fpsText)
                        .monospacedDigit()
                        .contentTransition(.numericText())
                } label: {
                    Label("FPS", systemImage: "speedometer")
                }

                LabeledContent {
                    Text(metrics.frameTimeText)
                        .monospacedDigit()
                        .contentTransition(.numericText())
                } label: {
                    Label("Frame", systemImage: "timer")
                }

                LabeledContent {
                    Text(metrics.cpuFrameTimeText)
                        .monospacedDigit()
                        .contentTransition(.numericText())
                } label: {
                    Label("CPU Frame", systemImage: "cpu")
                }

                LabeledContent {
                    Text(metrics.cpuUpdateTimeText)
                        .monospacedDigit()
                        .contentTransition(.numericText())
                } label: {
                    Label("CPU Sim", systemImage: "waveform.path.ecg")
                }

                LabeledContent {
                    Text(metrics.particleCountText)
                        .monospacedDigit()
                        .contentTransition(.numericText())
                } label: {
                    Label("Particles", systemImage: "circle.grid.3x3.fill")
                }
            }
            .font(.subheadline)
        }
        .frame(maxWidth: 280, alignment: .leading)
        .simulatorGlassPanel(tint: tint)
    }
}
