#ifndef AABBH__
#define AABBH__

#include "ray.cuh"

__device__ inline float ffmin(float a, float b) { return a < b ? a : b; }
__device__ inline float ffmax(float a, float b) { return a > b ? a : b; }

class AABB {
public:
    __device__ AABB() {}
    __device__ AABB(const Vec3& a, const Vec3& b) : _min(a), _max(b) { }

    __device__ Vec3 min() const { return _min; }
    __device__ Vec3 max() const { return _max; }

    __device__ bool hit(const Ray& r, float tmin, float tmax) const {
        // Pixar magic?
        for (int a = 0; a < 3; a++) {
            float invD = 1.0f / r.direction()[a];
            float t0 = (min()[a] - r.origin()[a]) * invD;
            float t1 = (max()[a] - r.origin()[a]) * invD;
            float tt = t0;
            if (invD < 0.0f)
                t0 = t1;
                t1 = tt;
            tmin = t0 > tmin ? t0 : tmin;
            tmax = t1 < tmax ? t1 : tmax;
            if (tmax <= tmin)
                return false;
        }
        return true;
    }

    Vec3 _min;
    Vec3 _max;
};

__device__ AABB surrounding_box(AABB box0, AABB box1) {
    Vec3 small(ffmin(box0.min().x(), box1.min().x()),
               ffmin(box0.min().y(), box1.min().y()),
               ffmin(box0.min().z(), box1.min().z()));
    Vec3 big(ffmax(box0.max().x(), box1.max().x()),
             ffmax(box0.max().y(), box1.max().y()),
             ffmax(box0.max().z(), box1.max().z()));
    return AABB(small, big);
}

#endif