#ifndef LAMBERTIANH__
#define LAMBERTIANH__

#include "material.cuh"
#include "vec3.cuh"
#include "entity.cuh"
#include "texture.cuh"

class Lambertian : public Material {
public:
    __device__ Lambertian(Texture* a) : albedo(a) {}
    __device__ virtual bool scatter(const Ray& r_in, const HitRecord& rec, Vec3& attenuation, Ray& scattered, curandState *local_rand_state) const {
        Vec3 target = rec.p + rec.normal + random_in_unit_sphere(local_rand_state);
        scattered = Ray(rec.p, target - rec.p, r_in.time());
        attenuation = albedo->value(0, 0, rec.p);
        return true;
    }

    Texture* albedo;
};

#endif