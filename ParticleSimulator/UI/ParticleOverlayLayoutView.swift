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
    let performanceMetrics: PerformanceMetrics
    private let panelSpacing: CGFloat = 14

    var body: some View {
        HStack(alignment: .top, spacing: 20) {
            VStack(alignment: .leading, spacing: panelSpacing) {
                ParticleControlPanelView(model: model)
                ParticleInspectorView(material: model.selectedMaterial)
            }

            Spacer(minLength: 20)

            VStack(alignment: .trailing, spacing: panelSpacing) {
                SimulationStatusPanelView(configuration: model.configuration)
                PerformanceHUDView(
                    metrics: performanceMetrics,
                    tint: model.selectedMaterial.secondaryPanelTint
                )
            }
        }
    }
}
