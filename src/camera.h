#ifndef CAMERAH__
#define CAMERAH__

#include "ray.h"

Vec3 random_in_unit_disk() {
    Vec3 p;
    do {
        p = 2.0*Vec3(drand48(), drand48(), 0) - Vec3(1, 1, 0);
    } while (dot(p, p) >= 1.0);
    return p;
}

class Camera {
public:
    Camera(Vec3 lookfrom, Vec3 lookat, Vec3 vup, float vfov, float aspect,
               float aperture, float focus_dist) {
        lens_radius = aperture / 2;
        float theta = vfov * M_PI / 180;
        float half_height = tan(theta / 2);
        float half_width = aspect * half_height;
        origin = lookfrom;
        w = unitv(lookfrom - lookat);
        u = unitv(cross(vup, w));
        v = cross(w, u);
        lower_left_corner = origin
                            - half_width * focus_dist * u
                            - half_height * focus_dist * v
                            - focus_dist * w;
        horizontal = 2*half_width*focus_dist*u;
        vertical = 2*half_height*focus_dist*v;
    }
    Ray get_Ray(float s, float t) {
        Vec3 rd = lens_radius * random_in_unit_disk();
        Vec3 offset = u * rd.x() + v * rd.y();
        return Ray(origin + offset,
                    lower_left_corner + s*horizontal + t*vertical
                        - origin - offset);
    }

    Vec3 origin;
    Vec3 lower_left_corner;
    Vec3 horizontal;
    Vec3 vertical;
    Vec3 u, v, w;
    float lens_radius;
};

#endif