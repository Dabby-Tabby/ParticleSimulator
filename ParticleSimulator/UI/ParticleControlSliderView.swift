//
//  ParticleControlSliderView.swift
//  ParticleSimulator
//
//  Created by Codex on 3/25/26.
//

import SwiftUI

struct ParticleControlSliderView: View {
    let title: String
    let valueText: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    let step: Double
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline, spacing: 12) {
                Text(title)
                    .font(.subheadline.bold())

                Spacer(minLength: 12)

                Text(valueText)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
                    .contentTransition(.numericText())
            }

            Slider(value: $value, in: range, step: step)
                .tint(tint)
                .accessibilityLabel(title)
        }
    }
}
