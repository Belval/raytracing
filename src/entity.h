#ifndef ENTITYH__
#define ENTITYH__

#include "ray.h"

class material;

struct hit_record {
    float t;
    vec3 p;
    vec3 normal;
    material *mat_ptr;
};

class entity {
public:
    virtual bool hit(const ray& r, float tmin, float tmax, hit_record& rec) const = 0;
};

#endif ENTITYH__