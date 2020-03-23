#ifndef RAYH__
#define RAYH__

#include "vec3.cuh"

class Ray
{
public:
    __device__ Ray() {}
    __device__ Ray(const Vec3& a, const Vec3 &b, float ti = 0.0) { A = a, B = b; _time = ti; }
    __device__ Vec3 origin() const { return A; }
    __device__ Vec3 direction() const { return B; }
    __device__ Vec3 point(float t) const { return A + t * B; }
    __device__ float time() const { return _time; }

    Vec3 A, B;
    float _time;
};

#endif