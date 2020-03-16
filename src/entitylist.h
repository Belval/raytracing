#ifndef ENTITYLISTH__
#define ENTITYLISTH__

#include "entity.h"

class Entity_list: public Entity {
public:
    Entity_list() {}
    Entity_list(Entity **e, int n) { list = e; list_size = n; } 
    virtual bool hit(const Ray& r, float tmin, float tmax, HitRecord& rec) const;
    Entity **list;
    int list_size;
};

bool Entity_list::hit(const Ray& r, float tmin, float tmax, HitRecord& rec) const {
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