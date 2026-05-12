//
//  ParticleControlPanelView.swift
//  ParticleSimulator
//
//  Created by Codex on 3/25/26.
//

import Observation
import SwiftUI

struct ParticleControlPanelView: View {
    @Bindable var model: ParticleSimulationModel

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Text("CONTROL DECK")
                    .font(.caption)
                    .bold()
                    .tracking(1.2)
                    .foregroundStyle(.secondary)

                Text("Emitter Mixer")
                    .font(.title3.bold())

                Text("Swap particle families, then tune the active system without covering the center viewport.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Particle Type")
                        .font(.caption)
                        .bold()
                        .foregroundStyle(.secondary)

                    Picker("Particle Type", selection: $model.selectedMaterial) {
                        ForEach(ParticleMaterial.allCases) { material in
                            Label(material.displayName, systemImage: material.systemImage)
                                .tag(material)
                        }
                    }
                    .pickerStyle(.menu)
                    .labelsHidden()
                    .accessibilityLabel("Particle Type")

                    Text(model.selectedMaterial.summary)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Divider()

                ParticleControlSliderView(
                    title: "Particle Count",
                    valueText: model.particleCountText,
                    value: $model.particleCount,
                    range: model.countRange,
                    step: 100,
                    tint: model.selectedMaterial.accent
                )

                ParticleControlSliderView(
                    title: "Particle Size",
                    valueText: model.particleSizeText,
                    value: $model.particleSize,
                    range: model.sizeRange,
                    step: 0.5,
                    tint: model.selectedMaterial.accent
                )

                ParticleControlSliderView(
                    title: "Velocity",
                    valueText: model.velocityText,
                    value: $model.velocityScale,
                    range: model.velocityRange,
                    step: 0.05,
                    tint: model.selectedMaterial.accent
                )

                Divider()

                VStack(alignment: .leading, spacing: 4) {
                    Text("Environmental Forces")
                        .font(.caption)
                        .bold()
                        .foregroundStyle(.secondary)

                    Text("Adjust the global pull and side draft without respawning the current particles.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                ParticleControlSliderView(
                    title: "Gravity",
                    valueText: model.gravityText,
                    value: $model.gravityScale,
                    range: model.gravityRange,
                    step: 0.05,
                    tint: model.selectedMaterial.accent
                )

                ParticleControlSliderView(
                    title: "Wind",
                    valueText: model.windText,
                    value: $model.windStrength,
                    range: model.windRange,
                    step: 0.05,
                    tint: model.selectedMaterial.accent
                )
            }

            Divider()

            HStack(alignment: .center, spacing: 12) {
                Button("Reset Preset", systemImage: "arrow.counterclockwise", action: model.resetToPreset)
                    .controlSize(.large)
                    .simulatorGlassButtonStyle()

                Spacer(minLength: 12)

                Label(model.selectedMaterial.displayName, systemImage: model.selectedMaterial.systemImage)
                    .font(.subheadline.bold())
                    .foregroundStyle(model.selectedMaterial.accent)
            }
        }
        .frame(maxWidth: 320, alignment: .leading)
        .simulatorGlassPanel(tint: model.selectedMaterial.panelTint, interactive: true)
    }
}
