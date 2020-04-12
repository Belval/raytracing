#include <iostream>
#include <string>
#include <curand_kernel.h>

#include "bvh_node.cuh"
#include "camera.cuh"
#include "entitylist.cuh"
#include "float.h"
#include "sphere.cuh"
#include "rect.cuh"
#include "diffuse_light.cuh"
#include "moving_sphere.cuh"
#include "lambertian.cuh"
#include "metal.cuh"
#include "transparent.cuh"
#include "texture.cuh"
#include "box.cuh"
#include "transform.cuh"
#include "isotropic.cuh"
#include "constant_medium.cuh"
#define STB_IMAGE_IMPLEMENTATION
#define STB_IMAGE_WRITE_IMPLEMENTATION
#include "stb_image.h"
#include "stb_image_write.h"

#define checkCudaErrors(val) check_cuda( (val), #val, __FILE__, __LINE__ )
void check_cuda(cudaError_t result, char const *const func, const char *const file, int const line) {
    if (result) {
        std::cerr << "CUDA error = " << static_cast<unsigned int>(result) << " at " <<
        file << ":" << line << " '" << func << "' \n";
        // Make sure we call CUDA Device Reset before exiting
        cudaDeviceReset();
        exit(99);
    }
}

__device__ Vec3 color(const Ray& r, const Vec3& background, Entity **world, curandState *local_rand_state) {
    Ray cur_ray = r;
    Vec3 cur_attenuation = Vec3(1.0, 1.0, 1.0);
    Vec3 cur_emitted = Vec3(0.0, 0.0, 0.0);
    for(int i = 0; i < 100; i++) {
        HitRecord rec;
        if ((*world)->hit(cur_ray, 0.001f, FLT_MAX, rec)) {
            Ray scattered;
            Vec3 attenuation;
            Vec3 emitted = rec.mat_ptr->emitted(rec.u, rec.v, rec.p);
            if(rec.mat_ptr->scatter(cur_ray, rec, attenuation, scattered, local_rand_state)) {
                cur_attenuation *= attenuation;
                cur_emitted += emitted * cur_attenuation;
                cur_ray = scattered;
            }
            else {
                return cur_emitted + emitted * cur_attenuation;
            }
        }
        else {
            return cur_emitted;
        }
    }
    return cur_emitted; // exceeded recursion
}

#define RND (curand_uniform(&local_rand_state))

__global__ void create_cornell_box(Entity **elist, Entity **eworld, Camera **camera, int nx, int ny, ImageTexture** texture, curandState *rand_state) {
    if (threadIdx.x == 0 && blockIdx.x == 0) {
        curandState local_rand_state = *rand_state;
        int i = 0;
        elist[i++] = new FlipFace(new YZRect(0, 555, 0, 555, 555, new Lambertian(new ConstantTexture(Vec3(0.12, 0.45, 0.15)))));
        elist[i++] = new YZRect(0, 555, 0, 555, 0, new Lambertian(new ConstantTexture(Vec3(0.65, 0.05, 0.05))));
        elist[i++] = new XZRect(113, 443, 127, 432, 554, new DiffuseLight(new ConstantTexture(Vec3(1.0, 1.0, 1.0))));
        elist[i++] = new XZRect(0, 555, 0, 555, 0, new Lambertian(new ConstantTexture(Vec3(0.73, 0.73, 0.73))));
        elist[i++] = new FlipFace(new XZRect(0, 555, 0, 555, 555, new Lambertian(new CheckerTexture(
            new ConstantTexture(Vec3(1, 1, 1)),
            new ConstantTexture(Vec3(0, 1, 0))
        ))));
        elist[i++] = new FlipFace(new XZRect(0, 555, 0, 555, 555, new Lambertian(new CheckerTexture(
            new ConstantTexture(Vec3(1, 1, 1)),
            new ConstantTexture(Vec3(0, 1, 0))
        ))));
        elist[i++] = new FlipFace(new XYRect(0, 555, 0, 555, 555, new Lambertian(new ConstantTexture(Vec3(0.73, 0.73, 0.73)))));
        elist[i++] = new ConstantMedium(
            new Translate(
                new RotateY(
                    new Box(Vec3(0, 0, 0), Vec3(165, 330, 165), new Lambertian(new ConstantTexture(Vec3(0.73, 0.73, 0.73)))),
                    15
                ),
                Vec3(265, 0, 295)
            ),
            0.05,
            new ConstantTexture(Vec3(0, 0, 0)),
            &local_rand_state
        );
        elist[i++] = new ConstantMedium(
            new Translate(
                new RotateY(
                    new Box(Vec3(0, 0, 0), Vec3(165, 165, 165), new Lambertian(new ConstantTexture(Vec3(0.73, 0.73, 0.73)))),
                    -18
                ),
                Vec3(130, 0, 65)
            ),
            0.01,
            new ConstantTexture(Vec3(0.8, 0.8, 0.8)),
            &local_rand_state
        );
        *eworld = new EntityList(elist, i);

        Vec3 lookfrom(278, 278, -800);
        Vec3 lookat(278, 278, 0);
        float dist_to_focus = 10.0;
        float aperture = 0.0;
        *camera = new Camera(
            lookfrom,
            lookat,
            Vec3(0,1,0),
            40.0,
            float(nx) / float(ny),
            aperture,
            dist_to_focus,
            0.0,
            1.0
        );
    }
}

__global__ void rand_init(curandState *rand_state) {
    if (threadIdx.x == 0 && blockIdx.x == 0) {
        curand_init(1984, 0, 0, rand_state);
    }
}

__global__ void render_init(int maxx, int maxy, curandState *rand_state) {
    int i = threadIdx.x + blockIdx.x * blockDim.x;
    int j = threadIdx.y + blockIdx.y * blockDim.y;
    if((i >= maxx) || (j >= maxy)) return;
    int pixel_index = j*maxx + i;
    curand_init(1984, pixel_index, 0, &rand_state[pixel_index]);
}

__global__ void texture_init(unsigned char* tex_data, int nx, int ny, ImageTexture** tex) {
    if (threadIdx.x == 0 && blockIdx.x == 0) {
        *tex = new ImageTexture(tex_data, nx, ny);
    }
}

__global__ void render(Vec3* fb, int max_x, int max_y, int ns, Camera **cam, Entity **world, curandState *randState) {
    int i = threadIdx.x + blockIdx.x * blockDim.x;
    int j = threadIdx.y + blockIdx.y * blockDim.y;
    if((i >= max_x) || (j >= max_y)) return;
    int pixel_index = j*max_x + i;
    curandState local_rand_state = randState[pixel_index];
    Vec3 col(0,0,0);
    Vec3 background(0, 0, 0);
    for(int s=0; s < ns; s++) {
        float u = float(i + curand_uniform(&local_rand_state)) / float(max_x);
        float v = float(j + curand_uniform(&local_rand_state)) / float(max_y);
        Ray r = (*cam)->get_ray(u, v, &local_rand_state);
        col += color(r, background, world, &local_rand_state);
    }
    randState[pixel_index] = local_rand_state;
    col /= float(ns);
    col[0] = sqrt(col[0]);
    col[1] = sqrt(col[1]);
    col[2] = sqrt(col[2]);
    fb[pixel_index] = col;
}

int main(int argc, char* argv[]) {
    if (argc < 5) {
        std::cerr << "Usage: " << argv[0] << " [WIDTH] [HEIGHT] [BOUNCES] [OUTPUT FILENAME]" << std::endl;
    }
    int nx = std::stoi(std::string(argv[1]));
    int ny = std::stoi(std::string(argv[2]));
    int ns = std::stoi(std::string(argv[3]));
    int tx = 16;
    int ty = 16;
    
    // Values
    int num_pixels = nx * ny;

    int tex_x, tex_y, tex_n;
    unsigned char *tex_data_host = stbi_load("assets/earthmap.jpg", &tex_x, &tex_y, &tex_n, 0);

    unsigned char *tex_data;
    checkCudaErrors(cudaMallocManaged(&tex_data, tex_x * tex_y * tex_n * sizeof(unsigned char)));
    checkCudaErrors(cudaMemcpy(tex_data, tex_data_host, tex_x * tex_y * tex_n * sizeof(unsigned char), cudaMemcpyHostToDevice));

    ImageTexture **texture;
    checkCudaErrors(cudaMalloc((void **)&texture, sizeof(ImageTexture*)));
    texture_init<<<1, 1>>>(tex_data, tex_x, tex_y, texture);

    // Allocating CUDA memory
    Vec3* image;
    checkCudaErrors(cudaMallocManaged((void**)&image, nx * ny * sizeof(Vec3)));

    // Allocate random state
    curandState *d_rand_state;
    checkCudaErrors(cudaMalloc((void **)&d_rand_state, num_pixels * sizeof(curandState)));
    curandState *d_rand_state2;
    checkCudaErrors(cudaMalloc((void **)&d_rand_state2, 1 * sizeof(curandState)));

    // Allocate 2nd random state to be initialized for the world creation
    rand_init<<<1,1>>>(d_rand_state2);
    checkCudaErrors(cudaGetLastError());
    checkCudaErrors(cudaDeviceSynchronize());

    // Building the world
    Entity **elist;
    int num_entity = 22 * 22 + 1 + 3;
    checkCudaErrors(cudaMalloc((void **)&elist, num_entity * sizeof(Entity*)));
    Entity **eworld;
    checkCudaErrors(cudaMalloc((void **)&eworld, sizeof(Entity*)));
    Camera **camera;
    checkCudaErrors(cudaMalloc((void **)&camera, sizeof(Camera*)));
    create_cornell_box<<<1, 1>>>(elist, eworld, camera, nx, ny, texture, d_rand_state2);
    checkCudaErrors(cudaGetLastError());
    checkCudaErrors(cudaDeviceSynchronize());

    dim3 blocks(nx/tx+1,ny/ty+1);
    dim3 threads(tx,ty);
    render_init<<<blocks, threads>>>(nx, ny, d_rand_state);
    checkCudaErrors(cudaGetLastError());
    checkCudaErrors(cudaDeviceSynchronize());
    render<<<blocks, threads>>>(image, nx, ny,  ns, camera, eworld, d_rand_state);
    checkCudaErrors(cudaGetLastError());
    checkCudaErrors(cudaDeviceSynchronize());

    uint8_t* imageHost = new uint8_t[nx * ny * 3 * sizeof(uint8_t)];
    for (int j = ny - 1; j >= 0; j--) {
        for (int i = 0; i < nx; i++) {
            size_t pixel_index = j * nx + i;
            imageHost[(ny - j - 1) * nx * 3 + i * 3] = 255.99 * image[pixel_index].r();
            imageHost[(ny - j - 1) * nx * 3 + i * 3 + 1] = 255.99 * image[pixel_index].g();
            imageHost[(ny - j - 1) * nx * 3 + i * 3 + 2] = 255.99 * image[pixel_index].b();
        }
    }
    stbi_write_png(argv[4], nx, ny, 3, imageHost, nx * 3);

    // Clean up
    checkCudaErrors(cudaDeviceSynchronize());
    checkCudaErrors(cudaGetLastError());
    checkCudaErrors(cudaFree(camera));
    checkCudaErrors(cudaFree(eworld));
    checkCudaErrors(cudaFree(elist));
    checkCudaErrors(cudaFree(d_rand_state));
    checkCudaErrors(cudaFree(image));
}