//
//  Shaders.metal
//  ParticleSimulator
//
//  Created by Nick Watts on 3/23/26.
//

#include <metal_stdlib>
using namespace metal;

struct Particle {
    float2 position;
    float2 velocity;
    float4 color;
    float size;
    float life;
    float maxLife;
    float pad;
};

struct VertexOut {
    float4 position [[position]];
    float4 color;
    float pointSize [[point_size]];
};

vertex VertexOut particleVertex(
    const device Particle* particles [[buffer(0)]],
    uint vid [[vertex_id]]
) {
    Particle p = particles[vid];

    VertexOut out;
    out.position = float4(p.position, 0.0, 1.0);
    out.color = p.color;
    out.pointSize = p.size;
    return out;
}

fragment float4 particleFragment(
    VertexOut in [[stage_in]],
    float2 pointCoord [[point_coord]]
) {
    // pointCoord goes from (0,0) to (1,1) across the point sprite
    float2 centered = pointCoord * 2.0 - 1.0;
    float dist = length(centered);

    // Make each point a soft circle
    if (dist > 1.0) {
        discard_fragment();
    }

    float alpha = smoothstep(1.0, 0.2, 1.0 - dist);
    return float4(in.color.rgb, in.color.a * alpha);
}
