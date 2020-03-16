#include <iostream>
#include <string>

#include "camera.h"
#include "entitylist.h"
#include "float.h"
#include "sphere.h"
#include "lambertian.h"
#include "metal.h"
#include "transparent.h"
#define STB_IMAGE_WRITE_IMPLEMENTATION
#include "stb_image_write.h"

Vec3 color(const Ray& r, Entity *world, int depth) {
    HitRecord rec;
    if (world->hit(r, 0.001, MAXFLOAT, rec)) {
        Ray scattered;
        Vec3 attenuation;
        if (depth < 50 && rec.mat_ptr->scatter(r, rec, attenuation, scattered)) {
            return attenuation * color(scattered, world, depth+1);
        } else {
            return Vec3(0, 0, 0);
        }
    } else {
        Vec3 udir = unitv(r.direction());
        float t = 0.5 * (udir.y() + 1.0);
        return (1.0 - t) * Vec3(1.0, 1.0, 1.0) + t * Vec3(0.5, 0.7, 1.0);
    }
}

Entity *random_scene() {
    int n = 200;
    Entity **list = new Entity*[n+1];
    list[0] =  new Sphere(Vec3(0,-1000,0), 1000, new Lambertian(Vec3(0.5, 0.5, 0.5)));
    int i = 1;
    for (int a = -5; a < 5; a++) {
        for (int b = -5; b < 5; b++) {
            float choose_mat = drand48();
            Vec3 center(a+0.9*drand48(),0.2,b+0.9*drand48());
            if ((center-Vec3(4,0.2,0)).l2() > 0.9) {
                if (choose_mat < 0.8) {  // diffuse
                    list[i++] = new Sphere(center, 0.2,
                        new Lambertian(Vec3(drand48()*drand48(),
                                            drand48()*drand48(),
                                            drand48()*drand48())
                        )
                    );
                }
                else if (choose_mat < 0.95) { // Metal
                    list[i++] = new Sphere(center, 0.2,
                            new Metal(Vec3(0.5*(1 + drand48()),
                                           0.5*(1 + drand48()),
                                           0.5*(1 + drand48())),
                                      0.5*drand48()));
                }
                else {  // glass
                    list[i++] = new Sphere(center, 0.2, new Transparent(1.5));
                }
            }
        }
    }

    list[i++] = new Sphere(Vec3(0, 1, 0), 1.0, new Transparent(1.5));
    list[i++] = new Sphere(Vec3(-4, 1, 0), 1.0, new Lambertian(Vec3(0.4, 0.2, 0.1)));
    list[i++] = new Sphere(Vec3(4, 1, 0), 1.0, new Metal(Vec3(0.7, 0.6, 0.5), 0.0));

    return new Entity_list(list, i);
}

int main(int argc, char* argv[]) {
    if (argc < 5) {
        std::cerr << "Usage: " << argv[0] << " [WIDTH] [HEIGHT] [BOUNCES] [OUTPUT FILENAME]" << std::endl;
    }
    int nx = std::stoi(std::string(argv[1]));
    int ny = std::stoi(std::string(argv[2]));
    int ns = std::stoi(std::string(argv[3]));
    Vec3 lower_left_corner(-2.0, -1.0, -1.0);
    Vec3 horizontal(4.0, 0.0, 0.0);
    Vec3 vertical(0.0, 2.0, 0.0);
    Vec3 origin(0.0, 0.0, 0.0);
    Entity* list[6];
    list[0] = new Sphere(Vec3(0, 0, -1), 0.5, new Lambertian(Vec3(0.8, 0.3, 0.3)));
    list[1] = new Sphere(Vec3(0, -100.5, -1), 100, new Lambertian(Vec3(0.0, 0.8, 0.0)));
    list[2] = new Sphere(Vec3(1, 0, -1), 0.5, new Metal(Vec3(0.8, 0.6, 0.2), 0.3));
    list[3] = new Sphere(Vec3(-1, 0, -1), 0.5, new Transparent(1.5));
    list[4] = new Sphere(Vec3(0, 1.5, -1), 1, new Metal(Vec3(0.2, 0.2, 0.2), 0.0));
    list[5] = new Sphere(Vec3(-1,0,-1), -0.45, new Transparent(1.5));
    Entity* world = random_scene();//new Entity_list(list, 6);
    Vec3 lookfrom(3, 3, 2);
    Vec3 lookat(0, 0, -1);
    float dist_to_focus = (lookfrom - lookat).l2();
    float aperture = 0.001;
    Camera cam(lookfrom, lookat, Vec3(0, 1, 0), 20, float(nx) / float(ny), aperture, dist_to_focus);
    uint8_t* image = new uint8_t[nx * ny * 3];
    #pragma omp parallel for collapse(2)
    for (int j = ny - 1; j >= 0; j--) {
        for (int i = 0; i < nx; i++) {
            Vec3 col(0, 0, 0);
            for (int s = 0; s < ns; s++) {
                float u = float(i + drand48()) / float(nx);
                float v = float(j + drand48()) / float(ny);
                Ray r = cam.get_Ray(u, v);
                Vec3 p = r.point(2.0);
                col += color(r, world, 0);
            }
            col /= float(ns);
            col = Vec3(sqrt(col[0]), sqrt(col[1]), sqrt(col[2]));
            Vec3 out = 255.99 * col;

            image[(ny - j - 1) * nx * 3 + i * 3] = out[0];
            image[(ny - j - 1) * nx * 3 + i * 3 + 1] = out[1];
            image[(ny - j - 1) * nx * 3 + i * 3 + 2] = out[2];
        }
    }
    stbi_write_png(argv[4], nx, ny, 3, image, nx * 3);
}