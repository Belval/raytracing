#ifndef ISOTROPICH__
#define ISOTROPICH__

class Isotropic : public Material {
public:
    __device__ Isotropic(Texture* a) : albedo(a) {}

    __device__ virtual bool scatter(const Ray& r_in, const HitRecord& rec, Vec3& attenuation, Ray& scattered, curandState* local_rand_state) const {
        scattered = Ray(rec.p, random_in_unit_sphere(local_rand_state), r_in.time());
        attenuation = albedo->value(rec.u, rec.v, rec.p);
        return true;
    }

Texture* albedo;
};

#endif