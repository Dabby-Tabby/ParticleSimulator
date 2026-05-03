//
//  View+SimulatorChrome.swift
//  ParticleSimulator
//
//  Created by Codex on 3/25/26.
//

import SwiftUI

extension View {
    @ViewBuilder
    func simulatorGlassPanel(tint: Color, interactive: Bool = false) -> some View {
        if #available(macOS 26.0, *) {
            self
                .padding(20)
                .glassEffect(
                    .regular.tint(tint).interactive(interactive),
                    in: RoundedRectangle(cornerRadius: 20)
                )
        } else {
            self
                .padding(20)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
                .overlay {
                    RoundedRectangle(cornerRadius: 20)
                        .strokeBorder(Color.primary.opacity(0.12))
                }
        }
    }

    @ViewBuilder
    func simulatorGlassButtonStyle(prominent: Bool = false) -> some View {
        if #available(macOS 26.0, *) {
            if prominent {
                self.buttonStyle(.glassProminent)
            } else {
                self.buttonStyle(.glass)
            }
        } else {
            if prominent {
                self.buttonStyle(.borderedProminent)
            } else {
                self.buttonStyle(.bordered)
            }
        }
    }
}
