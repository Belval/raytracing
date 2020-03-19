#ifndef ENTITYH__
#define ENTITYH__

#include "aabb.cuh"
#include "ray.cuh"

class Material;

struct HitRecord {
    float t;
    Vec3 p;
    Vec3 normal;
    Material *mat_ptr;
};

class Entity {
public:
    __device__ virtual bool hit(const Ray& r, float tmin, float tmax, HitRecord& rec) const = 0;
    __device__ virtual bool bounding_box(float t0, float t1, AABB& box) const = 0;
};

#endif