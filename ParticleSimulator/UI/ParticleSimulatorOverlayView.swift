//
//  ParticleSimulatorOverlayView.swift
//  ParticleSimulator
//
//  Created by Codex on 3/25/26.
//

import Observation
import SwiftUI

struct ParticleSimulatorOverlayView: View {
    @Bindable var model: ParticleSimulationModel

    var body: some View {
        Group {
            if #available(macOS 26.0, *) {
                GlassEffectContainer(spacing: 24) {
                    ParticleOverlayLayoutView(model: model)
                }
            } else {
                ParticleOverlayLayoutView(model: model)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(20)
        .fontDesign(.monospaced)
    }
}
