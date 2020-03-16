#ifndef METALH__
#define METALH__

#include "material.h"
#include "ray.h"

class Metal : public Material {
public:
    Metal(const Vec3& a, float f) : albedo(a) { if (f < 1) fuzz = f; else fuzz = 1; }
    virtual bool scatter(const Ray& r_in, const HitRecord& rec, Vec3& attenuation, Ray& scattered) const {
        Vec3 reflected = reflect(unitv(r_in.direction()), rec.normal);
        scattered = Ray(rec.p, reflected + fuzz * random_in_unit_Sphere());
        attenuation = albedo;
        return (dot(scattered.direction(), rec.normal) > 0);
    }

    Vec3 albedo;
    float fuzz;
};

#endif