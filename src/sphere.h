#ifndef SPHEREH__
#define SPHEREH__

#include "entity.h"
#include "material.h"

class Sphere: public Entity {
public:
    //Sphere() {}
    Sphere(Vec3 cen, float r, Material* m): center(cen), radius(r), mat(m) {};
    virtual bool hit(const Ray& r, float tmin, float tmax, HitRecord& rec) const;
    Vec3 center;
    float radius;
    Material* mat;
};

bool Sphere::hit(const Ray& r, float tmin, float tmax, HitRecord& rec) const {
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
            rec.mat_ptr = mat;
            return true;
        }
        temp = (-b + sqrt(b*b - a*c)) / a;
        if (temp < tmax && temp > tmin) {
            rec.t = temp;
            rec.p = r.point(rec.t);
            rec.normal = (rec.p - center) / radius;
            rec.mat_ptr = mat;
            return true;
        }
    }
    return false;
}

#endif