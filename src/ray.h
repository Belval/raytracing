#ifndef RAYH__
#define RAYH__

#include "vec3.h"

class Ray
{
public:
    Ray() {}
    Ray(const Vec3& a, const Vec3 &b) { A = a, B = b; }
    Vec3 origin() const { return A; }
    Vec3 direction() const { return B; }
    Vec3 point(float t) const { return A + t * B; }

    Vec3 A, B;
};

#endif