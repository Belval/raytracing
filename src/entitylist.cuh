#ifndef ENTITYLISTH__
#define ENTITYLISTH__

#include "entity.cuh"

class EntityList: public Entity {
public:
    __device__ EntityList() {}
    __device__ EntityList(Entity **e, int n) { list = e; list_size = n; } 
    __device__ virtual bool hit(const Ray& r, float tmin, float tmax, HitRecord& rec) const;
    Entity **list;
    int list_size;
};

__device__ bool EntityList::hit(const Ray& r, float tmin, float tmax, HitRecord& rec) const {
    HitRecord temp_rec;
    bool hit_anything = false;
    double closest_so_far = tmax;

    for (int i = 0; i < list_size; i++) {
        if (list[i]->hit(r, tmin, closest_so_far, temp_rec)) {
            hit_anything = true;
            closest_so_far = temp_rec.t;
            rec = temp_rec;
        }
    }
    return hit_anything;
}

#endif