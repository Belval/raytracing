#ifndef BVHNODEH__
#define BVHNODEH__

#include "ray.cuh"
#include "entitylist.cuh"

enum Axis { X, Y, Z };

__device__ void swap(Entity*& p1, Entity*& p2) {
    Entity* temp = p1;
    *p1 = *p2;
    p2 = temp;
}

template<Axis axis>
__device__ void bubble_sort(Entity** e, int n) {
    for (int i = 0; i < n - 1; i++) {
        for (int j = 0; j < n - i - 1; j++) {
            AABB box_left, box_right;
            Entity *ah = e[j];
            Entity *bh = e[j+1];
            
            ah->bounding_box(0, 0, box_left);
            bh->bounding_box(0, 0, box_right);

            if ((axis == X && (box_left.min().x() - box_right.min().x()) < 0.0)
             || (axis == Y && (box_left.min().y() - box_right.min().y()) < 0.0)
             || (axis == Z && (box_left.min().z() - box_right.min().z()) < 0.0)) {
                swap(e[j], e[j+1]);
            }
        }
    }
}

class BVHNode: public Entity {
public:
    __device__ BVHNode() {}
    __device__ BVHNode(Entity **e, int n, float time0, float time1, curandState& local_rand_state);

    __device__ virtual bool hit(const Ray& r, float tmin, float tmax, HitRecord& rec) const;
    __device__ virtual bool bounding_box(float t0, float t1, AABB& box) const;

    Entity *left;
    Entity *right;
    AABB box;
};

__device__ bool BVHNode::bounding_box(float t0, float t1, AABB& b) const {
    b = box;
    return true;
}

__device__ bool BVHNode::hit(const Ray& r, float tmin, float tmax, HitRecord& rec) const {
    if (box.hit(r, tmin, tmax)) {
        HitRecord left_rec, right_rec;
        bool hit_left = left->hit(r, tmin, tmax, left_rec);
        bool hit_right = right->hit(r, tmin, tmax, right_rec);
        if (hit_left && hit_right) {
            if (left_rec.t < right_rec.t) {
                rec = left_rec;
            } else {
                rec = right_rec;
            }
            return true;
        } else if (hit_left) {
            rec = left_rec;
            return true;
        } else if (hit_right) {
            rec = right_rec;
            return true;
        } else {
            return false;
        }
    } else {
        return false;
    }
}

__device__ BVHNode::BVHNode(Entity **e, int n, float time0, float time1, curandState& local_rand_state) {
    int axis = int(3 * curand_uniform(&local_rand_state));

    if (axis == 0)
        bubble_sort<X>(e, n);
    else if (axis == 1)
        bubble_sort<Y>(e, n);
    else
        bubble_sort<Z>(e, n);

    if (n == 1) {
        left = right = e[0];
    }
    else if (n == 2) {
        left = e[0];
        right = e[1];
    }
    else {
        left = new BVHNode(e, n/2, time0, time1, local_rand_state);
        right = new BVHNode(e + n/2, n - n/2, time0, time1, local_rand_state);
    }

    AABB box_left, box_right;

    box = surrounding_box(box_left, box_right);
}

#endif