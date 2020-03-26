#ifndef BOXH__
#define BOXH__

class Box : public Entity {
public:
    __device__ Box() {}
    __device__ Box(const Vec3& p0, const Vec3& p1, Material* ptr);

    __device__ virtual bool hit(const Ray& r, float t0, float t1, HitRecord& rec) const;

    __device__ virtual bool bounding_box(float t0, float t1, AABB& output_box) const {
        output_box = AABB(box_min, box_max);
        return true;
    }

    Vec3 box_min;
    Vec3 box_max;
    EntityList sides;
};

__device__ Box::Box(const Vec3& p0, const Vec3& p1, Material* ptr) {
    box_min = p0;
    box_max = p1;

    sides.add(new XYRect(p0.x(), p1.x(), p0.y(), p1.y(), p1.z(), ptr));
    sides.add(new FlipFace(new XYRect(p0.x(), p1.x(), p0.y(), p1.y(), p0.z(), ptr)));
    sides.add(new XZRect(p0.x(), p1.x(), p0.z(), p1.z(), p1.y(), ptr));
    sides.add(new FlipFace(new XZRect(p0.x(), p1.x(), p0.z(), p1.z(), p0.y(), ptr)));
    sides.add(new YZRect(p0.y(), p1.y(), p0.z(), p1.z(), p1.x(), ptr));
    sides.add(new FlipFace(new YZRect(p0.y(), p1.y(), p0.z(), p1.z(), p0.x(), ptr)));
}

__device__ bool Box::hit(const Ray& r, float t0, float t1, HitRecord& rec) const {
    return sides.hit(r, t0, t1, rec);
}

#endif