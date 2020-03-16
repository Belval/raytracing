#ifndef MATERIALH__
#define MATERIALH__

#include "entity.h"

class material {
public:
    virtual bool scatter(const ray& r_in, const hit_record& rec, vec3& attenuation, ray& scattered) const = 0;
};

#endif MATERIALH__