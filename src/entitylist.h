#ifndef ENTITYLISTH__
#define ENTITYLISTH__

#include "entity.h"

class entity_list: public entity {
public:
    entity_list() {}
    entity_list(entity **e, int n) { list = e; list_size = n; } 
    virtual bool hit(const ray& r, float tmin, float tmax, hit_record& rec) const;
    entity **list;
    int list_size;
};

bool entity_list::hit(const ray& r, float tmin, float tmax, hit_record& rec) const {
    hit_record temp_rec;
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