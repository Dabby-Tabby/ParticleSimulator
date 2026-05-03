# GPU Particle System in Apple Metal for macOS

**Final Project Report**  
**Course:** CS 4361.001 Computer Graphics  
**Student:** Nicholas Watts  
**Submission Date:** May 3, 2026

## Team Member and Project Title

This was an individual project completed by Nicholas Watts.

The project title is **GPU Particle System in Apple Metal for macOS**.

## Problem Summary

Particle systems are a common technique in computer graphics for representing effects that are difficult to model with rigid geometry, such as fire, smoke, sparks, dust, rain, and other natural phenomena. Instead of modeling one solid object, a particle system represents the effect as many small particles that each have properties such as position, velocity, color, size, and lifetime. When many particles are simulated and rendered together, they can create visually convincing effects.

The original project proposal focused on building a real-time particle system for macOS using Apple Metal. The main problem was to create visually appealing particle-based effects while maintaining interactive performance as the number of particles increases. Traditional CPU-based particle systems can become expensive when particle counts grow, so the proposal planned to explore GPU-based simulation and rendering using Metal.

This problem is important because particle systems are widely used in games, simulations, visual effects, and interactive graphics applications. The project also connects directly to core computer graphics topics: rendering pipelines, buffers, shaders, alpha blending, animation, simulation updates, and performance tradeoffs.

## Description of Work

The final implementation is a macOS particle simulator built with SwiftUI, MetalKit, and Metal shaders. The application displays a full-window particle viewport rendered with Metal and overlays a modern SwiftUI control interface for selecting and tuning particle effects.

The Metal portion of the project uses an `MTKView`, an `MTLRenderPipelineState`, a shared particle buffer, and custom vertex and fragment shaders. Each particle is rendered as a soft circular point sprite. The fragment shader discards pixels outside the circular point shape and uses smooth alpha falloff so the particles blend more naturally. Alpha blending is enabled in the render pipeline so overlapping particles can build up visible density.

The simulation state is represented with a `Particle` structure containing position, velocity, color, size, life, and maximum life. The renderer updates particle motion each frame, handles lifetime decay, respawns particles, applies material-specific acceleration and drag, fades particles over time, and uploads the updated particle data to a Metal buffer for rendering.

The project also became more modular than the original fixed particle demo. The final version defines a `ParticleMaterial` preset system with three particle types:

- **Fire:** A narrow rising plume with warm colors, faster upward motion, and quick fading.
- **Water:** A cooler falling sheet with heavier downward motion and larger droplet particles.
- **Dust:** A wide drifting field with slower motion, softer colors, and longer particle lifetimes.

The SwiftUI interface includes a corner-focused Liquid Glass style overlay. The control panel stays near the edges of the window so the center of the particle viewport remains visible. The UI includes:

- A particle type picker for Fire, Water, and Dust.
- A particle count slider.
- A particle size slider.
- A velocity slider.
- A reset button for returning to preset defaults.
- A live HUD showing the selected preset and current parameter values.
- A profile panel describing the selected effect's emission, motion, and fade behavior.

One major change from the original proposal is that the final project uses Metal for rendering, but the current particle simulation update is still performed on the CPU in Swift. The CPU updates the particle array each frame, and the updated array is copied into an `MTLBuffer` for the GPU to render. The original proposal planned for particle updates to run entirely on the GPU with Metal shaders or a compute pass. That full compute-based simulation path was not completed by the final submission deadline.

The main challenge was balancing the rendering work, simulation logic, and user-facing controls. Metal rendering required matching the Swift particle memory layout with the Metal shader structure, setting up the pipeline correctly, and handling alpha blending. The SwiftUI/Metal bridge also required keeping the `MTKView` alive while still allowing SwiftUI controls to update the active particle configuration. Another challenge was making the interface useful without covering the simulation view, which led to a corner-based overlay design.

## Results

The final result is an interactive macOS particle simulator that renders thousands of particles in real time using Metal. The project achieved a working Metal render pipeline, live particle animation, multiple effect presets, and adjustable runtime parameters.

The concrete results are:

- A macOS SwiftUI application with an embedded `MTKView`.
- A Metal render pipeline using custom vertex and fragment shaders.
- Point-sprite particle rendering with circular alpha falloff.
- Alpha blending for softer overlapping particles.
- Runtime particle state with position, velocity, color, size, life, and maximum life.
- Material-specific particle spawning, motion, fade, size decay, and respawn behavior.
- Three selectable particle presets: Fire, Water, and Dust.
- Interactive controls for particle count, particle size, and velocity.
- A modern corner-based UI overlay that keeps the main viewport mostly unobstructed.
- A reset action for restoring each preset's default settings.

The current default preset values are:

| Preset | Default Count | Default Size | Default Velocity Scale | Visual Behavior |
| --- | ---: | ---: | ---: | --- |
| Fire | 2400 | 7.5 | 1.00x | Rising warm plume |
| Water | 1800 | 8.5 | 0.90x | Falling cool sheet |
| Dust | 3200 | 5.5 | 0.35x | Slow drifting haze |

The adjustable ranges are:

| Parameter | Range |
| --- | --- |
| Particle Count | 400 to 6000 |
| Particle Size | 2.0 to 18.0 |
| Velocity Scale | 0.20x to 1.80x |

### Screenshots and Video

**Figure 1:** Fire preset with the Liquid Glass control deck visible in the upper-left corner.

![Figure 1: Fire preset](../d1.png)

**Figure 2:** Water preset showing falling blue particles and the live HUD.

![Figure 2: Water preset](../d2.png)

**Figure 3:** Dust preset showing the wider, slower ambient particle field.

![Figure 3: Dust preset](../d3.png)

The demo video is included with the project files:

**Demo Video:** [demo.mov](media/demo.mov)

## Analysis of Work

The project met several of the original goals, but not all of them.

The strongest completed goals were the macOS application, the Metal rendering pipeline, real-time particle rendering, runtime particle properties, a complete visual effect system, multiple presets, and interactive parameter controls. The application demonstrates core graphics concepts such as buffers, shaders, blending, animation, and a render loop. It also provides a more polished user interface than originally described in the proposal.

The main goal that was only partially met was GPU-based particle simulation. The final program uses Metal to render particles, but it does not yet use a Metal compute shader to update particle state directly on the GPU. Particle motion, lifetime, fading, and respawn logic are currently handled in Swift on the CPU. This still produces an interactive Metal-rendered particle system, but it does not fully satisfy the original goal of updating and rendering particles entirely on the GPU.

The project also changed direction slightly in terms of presets. The proposal mentioned effects such as fire, smoke, sparks, and snowfall. The final version implements Fire, Water, and Dust. These still demonstrate different particle behaviors: upward motion, downward motion, and slow drifting motion. They also make the simulator more modular by separating particle behavior into material presets.

Overall, the final project is successful as a real-time Metal-rendered particle simulator with interactive controls and multiple visual presets. It is less complete as a GPU-compute simulation project. The next technical step would be moving the particle update loop from Swift into a Metal compute kernel. That would better match the original proposal and would allow larger particle counts to scale more efficiently.

## Original Goal Completion

| Original Goal | Final Status | Notes |
| --- | --- | --- |
| Create a macOS application using Apple Metal | Completed | The project uses SwiftUI, MetalKit, and an `MTKView`. |
| Implement GPU-based particle updates | Partially completed | Rendering uses Metal, but simulation updates are currently CPU-side. |
| Render several thousand particles in real time | Completed | Presets use thousands of particles with adjustable count up to 6000. |
| Support particle properties such as position, velocity, lifetime, size, and color | Completed | These properties are represented in the shared particle structure. |
| Implement at least one complete visual effect | Completed | Fire, Water, and Dust presets are implemented. |
| Add interactive controls for particle parameters | Completed | UI includes controls for type, count, size, velocity, and reset. |
| Optimize performance and responsiveness | Partially completed | Rendering uses Metal buffers and point sprites, but CPU simulation remains the main scalability limit. |
| Add multiple presets or environmental forces if possible | Completed | Three presets are available; acceleration and drag vary by preset. |

## Compile and Run Instructions

### Requirements

- macOS 26.2 or later.
- Xcode 26.2 or later.
- A Mac that supports Apple Metal.
- The Metal toolchain component installed in Xcode.

If Xcode reports that the Metal toolchain is missing, install it with:

```sh
xcodebuild -downloadComponent MetalToolchain
```

### Build and Run in Xcode

1. Open `ParticleSimulator.xcodeproj`.
2. Select the `ParticleSimulator` scheme.
3. Choose `My Mac` as the run destination.
4. Build and run with `Command-R`.
5. Use the corner control deck to select Fire, Water, or Dust.
6. Adjust particle count, particle size, and velocity while the simulation is running.

### Command-Line Build

From the project directory:

```sh
xcodebuild \
  -project ParticleSimulator.xcodeproj \
  -scheme ParticleSimulator \
  -configuration Debug \
  -derivedDataPath ./DerivedData \
  build
```

If only a compile check is needed and signing causes issues, use:

```sh
xcodebuild \
  -project ParticleSimulator.xcodeproj \
  -scheme ParticleSimulator \
  -configuration Debug \
  -derivedDataPath ./DerivedData \
  CODE_SIGNING_ALLOWED=NO \
  CODE_SIGNING_REQUIRED=NO \
  build
```

### Important Build Note

Before submitting or building, make sure any scratch files that are not valid Swift source are removed from the app target. In the current workspace, `ParticleSimulator/Simulation/Cheat.swift` appears to contain pseudocode rather than Swift code. If it is included in the synchronized Xcode target, it should be removed from the project or renamed outside the target before building.

## Future Work

The most important future improvement is moving particle simulation from the CPU to a Metal compute shader. This would allow particle state to stay on the GPU between frames and would better match the original goal of a fully GPU-based particle system.

Other possible improvements include:

- Add compute-shader particle updates.
- Add gravity and wind controls to the UI.
- Add lifetime controls and color gradient controls.
- Add more presets such as Smoke, Sparks, Snow, and Rain.
- Add multiple emitters.
- Add collision against simple scene geometry.
- Add a performance HUD showing frame rate and particle count.
- Add preset saving and loading.
- Add video recording or screenshot export.

## Conclusion

This project produced a working real-time particle simulator for macOS using Apple Metal for rendering and SwiftUI for the interface. The final application can render thousands of particles with alpha blending, switch between multiple particle materials, and adjust important simulation parameters at runtime. Although the simulation update is not yet fully GPU-compute based, the project demonstrates the major graphics concepts from the proposal and creates a strong foundation for a more advanced GPU particle system.
