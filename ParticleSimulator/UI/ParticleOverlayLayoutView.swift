//
//  ParticleOverlayLayoutView.swift
//  ParticleSimulator
//
//  Created by Codex on 3/25/26.
//

import Observation
import SwiftUI

struct ParticleOverlayLayoutView: View {
    @Bindable var model: ParticleSimulationModel

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top, spacing: 20) {
                ParticleControlPanelView(model: model)
                Spacer(minLength: 20)
                SimulationStatusPanelView(configuration: model.configuration)
            }

            Spacer(minLength: 32)

            HStack(alignment: .bottom, spacing: 20) {
                ParticleInspectorView(material: model.selectedMaterial)
                Spacer(minLength: 20)
            }
        }
    }
}
