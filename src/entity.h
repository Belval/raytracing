#ifndef ENTITYH__
#define ENTITYH__

#include "ray.h"

class Material;

struct HitRecord {
    float t;
    Vec3 p;
    Vec3 normal;
    Material *mat_ptr;
};

class Entity {
public:
    virtual bool hit(const Ray& r, float tmin, float tmax, HitRecord& rec) const = 0;
};

#endif