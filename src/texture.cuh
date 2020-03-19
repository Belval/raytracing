#ifndef TEXTUREH__
#define TEXTUREH__

#include "perlin.cuh"

class Texture {
public:
    __device__ virtual Vec3 value(float u, float v, const Vec3& p) const = 0;
};

class ConstantTexture : public Texture {
public:
    __device__ ConstantTexture() {}
    __device__ ConstantTexture(Vec3 c) : color(c) {}
    __device__ virtual Vec3 value(float u, float v, const Vec3& p) const {
        return color;
    }

    Vec3 color;
};

class CheckerTexture : public Texture {
public:
    __device__ CheckerTexture() {}
    __device__ CheckerTexture(Texture *t0, Texture *t1) : even(t0), odd(t1) {}
    __device__ virtual Vec3 value(float u, float v, const Vec3& p) const {
        float sines = sin(10 * p.x()) * sin(10 * p.y()) * sin(10 * p.z());
        if (sines < 0) {
            return odd->value(u, v, p);
        } else {
            return even->value(u, v, p);
        }
    }

    Texture *odd;
    Texture *even;
};

class NoiseTexture : public Texture {
public:
    __device__ NoiseTexture(int scale, curandState* local_rand_state) : scale(scale), noise(Perlin(local_rand_state)) { }
    __device__ virtual Vec3 value(float u, float v, const Vec3& p) const {
        return Vec3(1, 1, 1) * noise.noise(scale, p);
    }

    Perlin noise;
    int scale;
};

#endif