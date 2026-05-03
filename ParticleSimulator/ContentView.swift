//
//  ContentView.swift
//  ParticleSimulator
//
//  Created by Nick Watts on 3/23/26.
//

import SwiftUI

struct ContentView: View {
    @State private var model = ParticleSimulationModel()

    var body: some View {
        ZStack {
            MetalView(configuration: model.configuration)
                .ignoresSafeArea()

            ParticleSimulatorOverlayView(model: model)
        }
    }
}

#Preview {
    ContentView()
}
