#ifndef MOVINGSPHEREH__
#define MOVINGSPHEREH__

#include "aabb.cuh"
#include "entity.cuh"

class MovingSphere: public Entity {
public:
    __device__ MovingSphere() {}
    __device__ MovingSphere(Vec3 cen0, Vec3 cen1, float t0, float t1, float r, Material *m)
        : center0(cen0), center1(cen1), time0(t0), time1(t1), radius(r), mat_ptr(m) { };
    __device__ bool hit(const Ray& r, float tmin, float tmax, HitRecord& rec) const;
    __device__ bool bounding_box(float t0, float t1, AABB& box) const;
    __device__ Vec3 center(float time) const;

    Vec3 center0, center1;
    float time0, time1;
    float radius;
    Material *mat_ptr;
};

__device__ Vec3 MovingSphere::center(float time) const {
    return center0 + ((time - time0) / (time1 - time0)) * (center1 - center0);
}

__device__ bool MovingSphere::hit(const Ray& r, float tmin, float tmax, HitRecord& rec) const {
    Vec3 oc = r.origin() - center(r.time());
    float a = dot(r.direction(), r.direction());
    float b = dot(oc, r.direction());
    float c = dot(oc, oc) - radius * radius;
    float discriminant = b*b - a*c;
    if (discriminant > 0) {
        float temp = (-b - sqrt(b * b - a * c)) / a;
        if (temp < tmax && temp > tmin) {
            rec.t = temp;
            rec.p = r.point(rec.t);
            rec.normal = (rec.p - center(r.time())) / radius;
            rec.mat_ptr = mat_ptr;
            return true;
        }
        temp = (-b + sqrt(b*b - a*c)) / a;
        if (temp < tmax && temp > tmin) {
            rec.t = temp;
            rec.p = r.point(rec.t);
            rec.normal = (rec.p - center(r.time())) / radius;
            rec.mat_ptr = mat_ptr;
            return true;
        }
    }
    return false;
}

__device__ bool MovingSphere::bounding_box(float t0, float t1, AABB& box) const {
    AABB box0(center(t0) - Vec3(radius, radius, radius), center(t0) + Vec3(radius, radius, radius));
    AABB box1(center(t1) - Vec3(radius, radius, radius), center(t1) + Vec3(radius, radius, radius));
    box = surrounding_box(box0, box1);
    return true;
}

#endif