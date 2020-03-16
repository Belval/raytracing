#ifndef MATERIALH__
#define MATERIALH__

#include "entity.h"

class Material {
public:
    virtual bool scatter(const Ray& r_in, const HitRecord& rec, Vec3& attenuation, Ray& scattered) const = 0;
};

#endif