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

struct ParticleSimulationUniforms {
    float2 environmentAcceleration;
    float deltaTime;
    float dragFactor;
    float sizeFactor;
    float minimumSize;
    float minimumAlpha;
    float baseSize;
    float velocityScale;
    uint materialID;
    uint particleCount;
    uint frameIndex;
};

struct VertexOut {
    float4 position [[position]];
    float4 color;
    float pointSize [[point_size]];
};

#define MATERIAL_FIRE 0u
#define MATERIAL_WATER 1u
#define MATERIAL_DUST 2u
#define MATERIAL_SMOKE 3u
#define MATERIAL_SPARKS 4u
#define MATERIAL_SNOW 5u

uint hashValue(uint value) {
    value ^= value >> 16;
    value *= 0x7feb352du;
    value ^= value >> 15;
    value *= 0x846ca68bu;
    value ^= value >> 16;
    return value;
}

float random01(uint particleID, uint frameIndex, uint materialID, uint salt) {
    uint seed = particleID * 747796405u
        + frameIndex * 2891336453u
        + materialID * 1597334677u
        + salt * 3812015801u;

    return float(hashValue(seed)) * (1.0f / 4294967295.0f);
}

float randomRange(
    uint particleID,
    uint frameIndex,
    uint materialID,
    uint salt,
    float lowerBound,
    float upperBound
) {
    return lowerBound + (upperBound - lowerBound) * random01(particleID, frameIndex, materialID, salt);
}

float2 makeSpawnPosition(constant ParticleSimulationUniforms& uniforms, uint particleID) {
    switch (uniforms.materialID) {
    case MATERIAL_FIRE:
        return float2(
            randomRange(particleID, uniforms.frameIndex, uniforms.materialID, 1u, -0.18f, 0.18f),
            randomRange(particleID, uniforms.frameIndex, uniforms.materialID, 2u, -0.96f, -0.82f)
        );
    case MATERIAL_WATER:
        return float2(
            randomRange(particleID, uniforms.frameIndex, uniforms.materialID, 3u, -0.78f, 0.78f),
            randomRange(particleID, uniforms.frameIndex, uniforms.materialID, 4u, 0.76f, 0.96f)
        );
    case MATERIAL_DUST:
        return float2(
            randomRange(particleID, uniforms.frameIndex, uniforms.materialID, 5u, -0.94f, 0.94f),
            randomRange(particleID, uniforms.frameIndex, uniforms.materialID, 6u, -0.82f, 0.48f)
        );
    case MATERIAL_SMOKE:
        return float2(
            randomRange(particleID, uniforms.frameIndex, uniforms.materialID, 7u, -0.26f, 0.26f),
            randomRange(particleID, uniforms.frameIndex, uniforms.materialID, 8u, -0.92f, -0.76f)
        );
    case MATERIAL_SPARKS:
        return float2(
            randomRange(particleID, uniforms.frameIndex, uniforms.materialID, 9u, -0.12f, 0.12f),
            randomRange(particleID, uniforms.frameIndex, uniforms.materialID, 10u, -0.90f, -0.78f)
        );
    case MATERIAL_SNOW:
        return float2(
            randomRange(particleID, uniforms.frameIndex, uniforms.materialID, 11u, -1.0f, 1.0f),
            randomRange(particleID, uniforms.frameIndex, uniforms.materialID, 12u, 0.84f, 1.06f)
        );
    default:
        return float2(0.0f, 0.0f);
    }
}

float2 makeVelocity(constant ParticleSimulationUniforms& uniforms, uint particleID) {
    float clampedScale = max(uniforms.velocityScale, 0.05f);

    switch (uniforms.materialID) {
    case MATERIAL_FIRE:
        return float2(
            randomRange(particleID, uniforms.frameIndex, uniforms.materialID, 13u, -0.22f, 0.22f) * clampedScale,
            randomRange(particleID, uniforms.frameIndex, uniforms.materialID, 14u, 0.58f, 1.28f) * clampedScale
        );
    case MATERIAL_WATER:
        return float2(
            randomRange(particleID, uniforms.frameIndex, uniforms.materialID, 15u, -0.08f, 0.08f) * clampedScale,
            -randomRange(particleID, uniforms.frameIndex, uniforms.materialID, 16u, 0.95f, 1.55f) * clampedScale
        );
    case MATERIAL_DUST:
        return float2(
            randomRange(particleID, uniforms.frameIndex, uniforms.materialID, 17u, -0.16f, 0.16f) * clampedScale,
            randomRange(particleID, uniforms.frameIndex, uniforms.materialID, 18u, 0.03f, 0.18f) * clampedScale
        );
    case MATERIAL_SMOKE:
        return float2(
            randomRange(particleID, uniforms.frameIndex, uniforms.materialID, 19u, -0.12f, 0.12f) * clampedScale,
            randomRange(particleID, uniforms.frameIndex, uniforms.materialID, 20u, 0.20f, 0.58f) * clampedScale
        );
    case MATERIAL_SPARKS:
        return float2(
            randomRange(particleID, uniforms.frameIndex, uniforms.materialID, 21u, -0.95f, 0.95f) * clampedScale,
            randomRange(particleID, uniforms.frameIndex, uniforms.materialID, 22u, 1.05f, 1.85f) * clampedScale
        );
    case MATERIAL_SNOW:
        return float2(
            randomRange(particleID, uniforms.frameIndex, uniforms.materialID, 23u, -0.08f, 0.08f) * clampedScale,
            -randomRange(particleID, uniforms.frameIndex, uniforms.materialID, 24u, 0.18f, 0.48f) * clampedScale
        );
    default:
        return float2(0.0f, 0.0f);
    }
}

float4 makeColor(constant ParticleSimulationUniforms& uniforms, uint particleID) {
    switch (uniforms.materialID) {
    case MATERIAL_FIRE:
        return float4(
            randomRange(particleID, uniforms.frameIndex, uniforms.materialID, 25u, 0.84f, 1.0f),
            randomRange(particleID, uniforms.frameIndex, uniforms.materialID, 26u, 0.36f, 0.72f),
            randomRange(particleID, uniforms.frameIndex, uniforms.materialID, 27u, 0.08f, 0.22f),
            0.92f
        );
    case MATERIAL_WATER:
        return float4(
            randomRange(particleID, uniforms.frameIndex, uniforms.materialID, 28u, 0.28f, 0.54f),
            randomRange(particleID, uniforms.frameIndex, uniforms.materialID, 29u, 0.62f, 0.92f),
            randomRange(particleID, uniforms.frameIndex, uniforms.materialID, 30u, 0.88f, 1.0f),
            0.88f
        );
    case MATERIAL_DUST:
        return float4(
            randomRange(particleID, uniforms.frameIndex, uniforms.materialID, 31u, 0.68f, 0.84f),
            randomRange(particleID, uniforms.frameIndex, uniforms.materialID, 32u, 0.60f, 0.74f),
            randomRange(particleID, uniforms.frameIndex, uniforms.materialID, 33u, 0.42f, 0.56f),
            0.68f
        );
    case MATERIAL_SMOKE:
        return float4(
            randomRange(particleID, uniforms.frameIndex, uniforms.materialID, 34u, 0.38f, 0.62f),
            randomRange(particleID, uniforms.frameIndex, uniforms.materialID, 35u, 0.38f, 0.62f),
            randomRange(particleID, uniforms.frameIndex, uniforms.materialID, 36u, 0.42f, 0.68f),
            0.50f
        );
    case MATERIAL_SPARKS:
        return float4(
            randomRange(particleID, uniforms.frameIndex, uniforms.materialID, 37u, 0.95f, 1.0f),
            randomRange(particleID, uniforms.frameIndex, uniforms.materialID, 38u, 0.56f, 0.88f),
            randomRange(particleID, uniforms.frameIndex, uniforms.materialID, 39u, 0.08f, 0.22f),
            0.95f
        );
    case MATERIAL_SNOW:
        return float4(
            randomRange(particleID, uniforms.frameIndex, uniforms.materialID, 40u, 0.86f, 1.0f),
            randomRange(particleID, uniforms.frameIndex, uniforms.materialID, 41u, 0.90f, 1.0f),
            randomRange(particleID, uniforms.frameIndex, uniforms.materialID, 42u, 0.96f, 1.0f),
            0.78f
        );
    default:
        return float4(1.0f);
    }
}

float makeSize(constant ParticleSimulationUniforms& uniforms, uint particleID) {
    switch (uniforms.materialID) {
    case MATERIAL_FIRE:
        return uniforms.baseSize * randomRange(particleID, uniforms.frameIndex, uniforms.materialID, 43u, 0.72f, 1.26f);
    case MATERIAL_WATER:
        return uniforms.baseSize * randomRange(particleID, uniforms.frameIndex, uniforms.materialID, 44u, 0.82f, 1.32f);
    case MATERIAL_DUST:
        return uniforms.baseSize * randomRange(particleID, uniforms.frameIndex, uniforms.materialID, 45u, 0.58f, 1.22f);
    case MATERIAL_SMOKE:
        return uniforms.baseSize * randomRange(particleID, uniforms.frameIndex, uniforms.materialID, 46u, 0.95f, 1.75f);
    case MATERIAL_SPARKS:
        return uniforms.baseSize * randomRange(particleID, uniforms.frameIndex, uniforms.materialID, 47u, 0.45f, 1.05f);
    case MATERIAL_SNOW:
        return uniforms.baseSize * randomRange(particleID, uniforms.frameIndex, uniforms.materialID, 48u, 0.55f, 1.15f);
    default:
        return uniforms.baseSize;
    }
}

float makeLifetime(constant ParticleSimulationUniforms& uniforms, uint particleID) {
    switch (uniforms.materialID) {
    case MATERIAL_FIRE:
        return randomRange(particleID, uniforms.frameIndex, uniforms.materialID, 49u, 1.1f, 2.6f);
    case MATERIAL_WATER:
        return randomRange(particleID, uniforms.frameIndex, uniforms.materialID, 50u, 1.6f, 3.4f);
    case MATERIAL_DUST:
        return randomRange(particleID, uniforms.frameIndex, uniforms.materialID, 51u, 4.2f, 7.8f);
    case MATERIAL_SMOKE:
        return randomRange(particleID, uniforms.frameIndex, uniforms.materialID, 52u, 4.8f, 9.0f);
    case MATERIAL_SPARKS:
        return randomRange(particleID, uniforms.frameIndex, uniforms.materialID, 53u, 0.65f, 1.8f);
    case MATERIAL_SNOW:
        return randomRange(particleID, uniforms.frameIndex, uniforms.materialID, 54u, 5.0f, 10.0f);
    default:
        return 1.0f;
    }
}

Particle makeParticle(constant ParticleSimulationUniforms& uniforms, uint particleID) {
    Particle particle;
    float lifetime = makeLifetime(uniforms, particleID);

    particle.position = makeSpawnPosition(uniforms, particleID);
    particle.velocity = makeVelocity(uniforms, particleID);
    particle.color = makeColor(uniforms, particleID);
    particle.size = makeSize(uniforms, particleID);
    particle.life = lifetime;
    particle.maxLife = lifetime;
    particle.pad = 0.0f;

    return particle;
}

bool isOutOfBounds(Particle particle, uint materialID) {
    switch (materialID) {
    case MATERIAL_FIRE:
        return particle.position.y > 1.12f || abs(particle.position.x) > 1.18f || particle.position.y < -1.18f;
    case MATERIAL_WATER:
        return particle.position.y < -1.12f || abs(particle.position.x) > 1.18f || particle.position.y > 1.18f;
    case MATERIAL_DUST:
        return particle.position.y > 1.18f || particle.position.y < -1.18f || abs(particle.position.x) > 1.22f;
    case MATERIAL_SMOKE:
        return particle.position.y > 1.18f || particle.position.y < -1.2f || abs(particle.position.x) > 1.24f;
    case MATERIAL_SPARKS:
        return particle.position.y > 1.18f || particle.position.y < -1.18f || abs(particle.position.x) > 1.22f;
    case MATERIAL_SNOW:
        return particle.position.y < -1.14f || particle.position.y > 1.18f || abs(particle.position.x) > 1.24f;
    default:
        return false;
    }
}

kernel void updateParticlesCompute(
    device Particle* particles [[buffer(0)]],
    constant ParticleSimulationUniforms& uniforms [[buffer(1)]],
    uint id [[thread_position_in_grid]]
) {
    if (id >= uniforms.particleCount) {
        return;
    }

    Particle particle = particles[id];
    particle.life -= uniforms.deltaTime;

    if (particle.life <= 0.0f) {
        particles[id] = makeParticle(uniforms, id);
        return;
    }

    particle.position += particle.velocity * uniforms.deltaTime;
    particle.velocity += uniforms.environmentAcceleration * uniforms.deltaTime;
    particle.velocity *= uniforms.dragFactor;

    float lifeRatio = max(particle.life / particle.maxLife, 0.0f);
    particle.color.w = max(uniforms.minimumAlpha, lifeRatio);
    particle.size = max(uniforms.minimumSize, particle.size * uniforms.sizeFactor);

    if (isOutOfBounds(particle, uniforms.materialID)) {
        particle = makeParticle(uniforms, id);
    }

    particles[id] = particle;
}

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
