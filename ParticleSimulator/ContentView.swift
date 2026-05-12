//
//  ContentView.swift
//  ParticleSimulator
//
//  Created by Nick Watts on 3/23/26.
//

import SwiftUI

struct ContentView: View {
    @State private var model = ParticleSimulationModel()
    @State private var performanceMetrics = PerformanceMetrics()

    var body: some View {
        ZStack {
            MetalView(configuration: model.configuration, performanceMetrics: performanceMetrics)
                .ignoresSafeArea()

            ParticleSimulatorOverlayView(model: model, performanceMetrics: performanceMetrics)
        }
    }
}

#Preview {
    ContentView()
}
