//
//  SimulationStatusPanelView.swift
//  ParticleSimulator
//
//  Created by Codex on 3/25/26.
//

import SwiftUI

struct SimulationStatusPanelView: View {
    let configuration: ParticleSimulationConfiguration

    private var material: ParticleMaterial {
        configuration.material
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("LIVE HUD")
                    .font(.caption)
                    .bold()
                    .tracking(1.2)
                    .foregroundStyle(.secondary)

                Label(material.displayName, systemImage: material.systemImage)
                    .font(.title3.bold())
                    .foregroundStyle(material.accent)

                Text(material.summary)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Divider()

            VStack(alignment: .leading, spacing: 12) {
                LabeledContent {
                    Text(configuration.particleCountText)
                        .monospacedDigit()
                        .contentTransition(.numericText())
                } label: {
                    Label("Particles", systemImage: "circle.grid.3x3.fill")
                }

                LabeledContent {
                    Text(configuration.particleSizeText)
                        .monospacedDigit()
                        .contentTransition(.numericText())
                } label: {
                    Label("Point Size", systemImage: "circle.dotted")
                }

                LabeledContent {
                    Text(configuration.velocityText)
                        .monospacedDigit()
                        .contentTransition(.numericText())
                } label: {
                    Label("Velocity", systemImage: "wind")
                }
            }
            .font(.subheadline)
        }
        .frame(maxWidth: 280, alignment: .leading)
        .simulatorGlassPanel(tint: material.secondaryPanelTint)
    }
}
