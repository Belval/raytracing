#ifndef RECTH__
#define RECTH__

class XYRect : public Entity {
public:
    __device__ XYRect() {}
    __device__ XYRect(float _x0, float _x1, float _y0, float _y1, float _k, Material *mat)
                : x0(_x0), x1(_x1), y0(_y0), y1(_y1), k(_k), mp(mat) {};
    
    __device__ virtual bool hit(const Ray& r, float t0, float t1, HitRecord& rec) const;

    __device__ virtual bool bounding_box(float t0, float t1, AABB& output_box) const {
        output_box = AABB(Vec3(x0, y0, k - 0.0001), Vec3(x1, y1, k + 0.0001));
        return true;
    }

    Material* mp;
    float x0, x1, y0, y1, k;
};

__device__ bool XYRect::hit(const Ray& r, float t0, float t1, HitRecord& rec) const {
    float t = (k - r.origin().z()) / r.direction().z();
    if (t < t0 || t > t1)
        return false;
    float x = r.origin().x() + t*r.direction().x();
    float y = r.origin().y() + t*r.direction().y();
    if (x < x0 || x > x1 || y < y0 || y > y1)
        return false;
    rec.u = (x - x0) / (x1 - x0);
    rec.v = (y - y0) / (y1 - y0);
    rec.t = t;
    Vec3 outward_normal = Vec3(0, 0, 1);
    rec.set_face_normal(r, outward_normal);
    rec.mat_ptr = mp;
    rec.p = r.point(t);

    return true;
}

class XZRect : public Entity {
public:
    __device__ XZRect() {}
    __device__ XZRect(float _x0, float _x1, float _z0, float _z1, float _k, Material *mat)
                : x0(_x0), x1(_x1), z0(_z0), z1(_z1), k(_k), mp(mat) {};
    
    __device__ virtual bool hit(const Ray& r, float t0, float t1, HitRecord& rec) const;

    __device__ virtual bool bounding_box(float t0, float t1, AABB& output_box) const {
        output_box = AABB(Vec3(x0, k - 0.0001, z0), Vec3(x1, k + 0.0001, z1));
        return true;
    }

    Material* mp;
    float x0, x1, z0, z1, k;
};

__device__ bool XZRect::hit(const Ray& r, float t0, float t1, HitRecord& rec) const {
    float t = (k - r.origin().y()) / r.direction().y();
    if (t < t0 || t > t1)
        return false;
    float x = r.origin().x() + t*r.direction().x();
    float z = r.origin().z() + t*r.direction().z();
    if (x < x0 || x > x1 || z < z0 || z > z1)
        return false;
    rec.u = (x - x0) / (x1 - x0);
    rec.v = (z - z0) / (z1 - z0);
    rec.t = t;
    Vec3 outward_normal = Vec3(0, 1, 0);
    rec.set_face_normal(r, outward_normal);
    rec.mat_ptr = mp;
    rec.p = r.point(t);

    return true;
}

class YZRect : public Entity {
public:
    __device__ YZRect() {}
    __device__ YZRect(float _y0, float _y1, float _z0, float _z1, float _k, Material *mat)
                : y0(_y0), y1(_y1), z0(_z0), z1(_z1), k(_k), mp(mat) {};
    
    __device__ virtual bool hit(const Ray& r, float t0, float t1, HitRecord& rec) const;

    __device__ virtual bool bounding_box(float t0, float t1, AABB& output_box) const {
        output_box = AABB(Vec3(k - 0.0001, y0, z0), Vec3(k + 0.0001, y1, z1));
        return true;
    }

    Material* mp;
    float y0, y1, z0, z1, k;
};

__device__ bool YZRect::hit(const Ray& r, float t0, float t1, HitRecord& rec) const {
    float t = (k - r.origin().x()) / r.direction().x();
    if (t < t0 || t > t1)
        return false;
    float y = r.origin().y() + t*r.direction().y();
    float z = r.origin().z() + t*r.direction().z();
    if (y < y0 || y > y1 || z < z0 || z > z1)
        return false;
    rec.u = (y - y0) / (y1 - y0);
    rec.v = (z - z0) / (z1 - z0);
    rec.t = t;
    Vec3 outward_normal = Vec3(1, 0, 0);
    rec.set_face_normal(r, outward_normal);
    rec.mat_ptr = mp;
    rec.p = r.point(t);

    return true;
}

class FlipFace : public Entity {
public:
    __device__ FlipFace(Entity* e) : ptr(e) {}

    __device__ virtual bool hit(const Ray& r, float t_min, float t_max, HitRecord& rec) const {
        if (!ptr->hit(r, t_min, t_max, rec))
            return false;

        rec.front_face = !rec.front_face;
        return true;
    }

    __device__ virtual bool bounding_box(float t0, float t1, AABB& output_box) const {
        return ptr->bounding_box(t0, t1, output_box);
    }

    Entity* ptr;
};

#endif