#ifndef TRANSFORMH__
#define TRANSFORMH__

#define DEGREES_TO_RADIANS(degrees)((M_PI * degrees)/180)

class Translate : public Entity {
public:
    __device__ Translate(Entity* p, const Vec3& displacement) : ptr(p), offset(displacement) {}

    __device__ virtual bool hit(const Ray& r, float t_min, float t_max, HitRecord& rec) const;
    __device__ virtual bool bounding_box(float t0, float t1, AABB& output_box) const;

    Entity* ptr;
    Vec3 offset;
};

__device__ bool Translate::hit(const Ray& r, float t_min, float t_max, HitRecord& rec) const {
    Ray moved_r(r.origin() - offset, r.direction(), r.time());
    if (!ptr->hit(moved_r, t_min, t_max, rec))
        return false;

    rec.p += offset;
    rec.set_face_normal(moved_r, rec.normal);

    return true;
}

__device__ bool Translate::bounding_box(float t0, float t1, AABB& output_box) const {
    if (!ptr->bounding_box(t0, t1, output_box))
        return false;

    output_box = AABB(
        output_box.min() + offset,
        output_box.max() + offset);

    return true;
}

class RotateY : public Entity {
public:
    __device__ RotateY(Entity* p, float angle);

    __device__ virtual bool hit(const Ray& r, float t_min, float t_max, HitRecord& rec) const;
    __device__ virtual bool bounding_box(float t0, float t1, AABB& output_box) const {
        output_box = bbox;
        return hasbox;
    }

    Entity* ptr;
    float sin_theta;
    float cos_theta;
    bool hasbox;
    AABB bbox;
};

__device__ RotateY::RotateY(Entity *p, float angle) : ptr(p) {
    auto radians = DEGREES_TO_RADIANS(angle);
    sin_theta = sin(radians);
    cos_theta = cos(radians);
    hasbox = ptr->bounding_box(0, 1, bbox);

    Vec3 min(FLT_MAX, FLT_MAX, FLT_MAX);
    Vec3 max(-FLT_MAX, -FLT_MAX, -FLT_MAX);

    for (int i = 0; i < 2; i++) {
        for (int j = 0; j < 2; j++) {
            for (int k = 0; k < 2; k++) {
                auto x = i*bbox.max().x() + (1-i)*bbox.min().x();
                auto y = j*bbox.max().y() + (1-j)*bbox.min().y();
                auto z = k*bbox.max().z() + (1-k)*bbox.min().z();

                auto newx =  cos_theta*x + sin_theta*z;
                auto newz = -sin_theta*x + cos_theta*z;

                Vec3 tester(newx, y, newz);

                for (int c = 0; c < 3; c++) {
                    min[c] = ffmin(min[c], tester[c]);
                    max[c] = ffmax(max[c], tester[c]);
                }
            }
        }
    }

    bbox = AABB(min, max);
}

__device__ bool RotateY::hit(const Ray& r, float t_min, float t_max, HitRecord& rec) const {
    Vec3 origin = r.origin();
    Vec3 direction = r.direction();

    origin[0] = cos_theta*r.origin()[0] - sin_theta*r.origin()[2];
    origin[2] = sin_theta*r.origin()[0] + cos_theta*r.origin()[2];

    direction[0] = cos_theta*r.direction()[0] - sin_theta*r.direction()[2];
    direction[2] = sin_theta*r.direction()[0] + cos_theta*r.direction()[2];

    Ray rotated_r(origin, direction, r.time());

    if (!ptr->hit(rotated_r, t_min, t_max, rec))
        return false;

    Vec3 p = rec.p;
    Vec3 normal = rec.normal;

    p[0] =  cos_theta*rec.p[0] + sin_theta*rec.p[2];
    p[2] = -sin_theta*rec.p[0] + cos_theta*rec.p[2];

    normal[0] =  cos_theta*rec.normal[0] + sin_theta*rec.normal[2];
    normal[2] = -sin_theta*rec.normal[0] + cos_theta*rec.normal[2];

    rec.p = p;
    rec.set_face_normal(rotated_r, normal);

    return true;
}

#endif