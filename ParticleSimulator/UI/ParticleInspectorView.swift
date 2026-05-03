//
//  ParticleInspectorView.swift
//  ParticleSimulator
//
//  Created by Codex on 3/25/26.
//

import SwiftUI

struct ParticleInspectorView: View {
    let material: ParticleMaterial

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("PROFILE")
                .font(.caption)
                .bold()
                .tracking(1.2)
                .foregroundStyle(.secondary)

            Text(material.detail)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            Divider()

            VStack(alignment: .leading, spacing: 12) {
                Label(material.emissionNote, systemImage: "scope")
                Label(material.motionNote, systemImage: "wind")
                Label(material.fadeNote, systemImage: "sparkles")
            }
            .font(.subheadline)
        }
        .frame(maxWidth: 300, alignment: .leading)
        .simulatorGlassPanel(tint: material.panelTint)
    }
}
