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

class ImageTexture : public Texture {
public:
    __device__ ImageTexture() {}
    __device__ ImageTexture(unsigned char *pixels, int A, int B) : data(pixels), nx(A), ny(B) {}
    __device__ virtual Vec3 value(float u, float v, const Vec3& p) const;
    
    unsigned char *data;
    int nx, ny;
};

__device__ Vec3 ImageTexture::value(float u, float v, const Vec3& p) const {
    int i = u * nx;
    int j = (1 - v) * ny - 0.001;
    if (i < 0) i = 0;
    if (j < 0) j = 0;
    if (i > nx-1) i = nx-1;
    if (j > ny-1) j = ny-1;
    float r = int(data[3 * i + 3 * nx * j ]) / 255.0;
    float g = int(data[3 * i + 3 * nx * j + 1]) / 255.0;
    float b = int(data[3 * i + 3 * nx * j + 2]) / 255.0;
    return Vec3(r, g, b);
}

#endif