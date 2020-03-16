#ifndef TRANSPARENTH__
#define TRANSPARENTH__

#include "material.h"

class Transparent : public Material {
public:
    Transparent(float ri) : ref_idx(ri) {}
    virtual bool scatter(const Ray& r_in, const HitRecord& rec,
                            Vec3& attenuation, Ray& scattered) const {
        Vec3 outward_normal;
        Vec3 reflected = reflect(r_in.direction(), rec.normal);
        float ni_over_nt;
        attenuation = Vec3(1.0, 1.0, 1.0);
        Vec3 refracted;

        float reflect_prob;
        float cosine;

        if (dot(r_in.direction(), rec.normal) > 0) {
                outward_normal = -rec.normal;
                ni_over_nt = ref_idx;
                cosine = ref_idx * dot(r_in.direction(), rec.normal) / r_in.direction().l2();
        }
        else {
                outward_normal = rec.normal;
                ni_over_nt = 1.0 / ref_idx;
                cosine = -dot(r_in.direction(), rec.normal) / r_in.direction().l2();
        }

        if (refract(r_in.direction(), outward_normal, ni_over_nt, refracted)) {
            reflect_prob = schlick(cosine, ref_idx);
        }
        else {
            reflect_prob = 1.0;
        }

        if (drand48() < reflect_prob) {
            scattered = Ray(rec.p, reflected);
        }
        else {
            scattered = Ray(rec.p, refracted);
        }

        return true;
    }
    static float schlick(float cosine, float ref_idx) {
        float r0 = (1 - ref_idx) / (1 + ref_idx);
        r0 = r0 * r0;
        return r0 + (1 - r0) * pow((1 - cosine), 5);
    }
private:
    float ref_idx;
};

#endif