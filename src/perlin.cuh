#ifndef PERLINH__
#define PERLINH__

__device__ float* perlin_generate(curandState* local_rand_state) {
    float* p = new float[256];
    for (int i = 0; i < 256; ++i)
        p[i] = curand_uniform(local_rand_state);
    return p;
}

__device__ void permute(int *p, int n, curandState* local_rand_state) {
    for (int i = n-1; i > 0; i--) {
        int target = int(curand_uniform(local_rand_state)*(i+1));
        int tmp = p[i];
        p[i] = p[target];
        p[target] = tmp;
    }
    return;
}

__device__ int* perlin_generate_perm(curandState* local_rand_state) {
    int * p = new int[256];
    for (int i = 0; i < 256; i++)
        p[i] = i;
    permute(p, 256, local_rand_state);
    return p;
}

class Perlin {
public:
    __device__ Perlin(curandState* local_rand_state) {
        ranfloat = perlin_generate(local_rand_state);
        perm_x = perlin_generate_perm(local_rand_state);
        perm_y = perlin_generate_perm(local_rand_state);
        perm_z = perlin_generate_perm(local_rand_state);
    }
    __device__ float noise(int scale, const Vec3& p) const {
        int x = uint8_t(p.x() * scale) % 256;
        int y = uint8_t(p.y() * scale) % 256;
        int z = uint8_t(p.z() * scale) % 256;
        return ranfloat[perm_x[x] ^ perm_y[y] ^ perm_z[z]];
    }

    curandState* local_rand_state;
    float *ranfloat;
    int *perm_x;
    int *perm_y;
    int *perm_z;
};

#endif