#ifndef SPHEREH__
#define SPHEREH__

#include "entity.cuh"
#include "material.cuh"

class Sphere: public Entity {
public:
    //Sphere() {}
    __device__ Sphere(Vec3 cen, float r, Material* m): center(cen), radius(r), mat_ptr(m) {};
    __device__ virtual bool hit(const Ray& r, float tmin, float tmax, HitRecord& rec) const;
    __device__ virtual bool bounding_box(float t0, float t1, AABB& box) const;
    Vec3 center;
    float radius;
    Material* mat_ptr;
};

__device__ bool Sphere::hit(const Ray& r, float tmin, float tmax, HitRecord& rec) const {
    Vec3 oc = r.origin() - center;
    float a = dot(r.direction(), r.direction());
    float b = dot(oc, r.direction());
    float c = dot(oc, oc) - radius * radius;
    float discriminant = b*b - a*c;
    if (discriminant > 0) {
        float temp = (-b - sqrt(b * b - a * c)) / a;
        if (temp < tmax && temp > tmin) {
            rec.t = temp;
            rec.p = r.point(rec.t);
            rec.normal = (rec.p - center) / radius;
            rec.mat_ptr = mat_ptr;
            return true;
        }
        temp = (-b + sqrt(b*b - a*c)) / a;
        if (temp < tmax && temp > tmin) {
            rec.t = temp;
            rec.p = r.point(rec.t);
            rec.normal = (rec.p - center) / radius;
            rec.mat_ptr = mat_ptr;
            return true;
        }
    }
    return false;
}

__device__ bool Sphere::bounding_box(float t0, float t1, AABB& box) const {
    box = AABB(center - Vec3(radius, radius, radius),
               center + Vec3(radius, radius, radius));
    return true;
}

#endif