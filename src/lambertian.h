#ifndef LAMBERTIANH__
#define LAMBERTIANH__

#include "material.h"
#include "vec3.h"
#include "entity.h"

class Lambertian : public Material {
public:
    Lambertian(const Vec3& a) : albedo(a) {}
    virtual bool scatter(const Ray& r_in, const HitRecord& rec, Vec3& attenuation, Ray& scattered) const {
        Vec3 target = rec.p + rec.normal + random_in_unit_Sphere();
        scattered = Ray(rec.p, target - rec.p);
        attenuation = albedo;
        return true;
    }

    Vec3 albedo;
};

#endif