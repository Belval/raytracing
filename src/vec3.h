#ifndef VEC3H__
#define VEC3H__

#include <math.h>
#include <stdlib.h>
#include <iostream>

class vec3 {
public:
    vec3() {}
    vec3(float e0, float e1, float e2) { e[0] = e0, e[1] = e1, e[2] = e2; }
    inline float x() const { return e[0]; }
    inline float y() const { return e[1]; }
    inline float z() const { return e[2]; }
    inline float r() const { return e[0]; }
    inline float g() const { return e[1]; }
    inline float b() const { return e[2]; }

    inline const vec3& operator+() const { return *this; }
    inline vec3 operator-() const { return vec3(-e[0], -e[1], -e[2]); }
    inline float operator[](int i) const { return e[i]; }
    inline float& operator[](int i) { return e[i]; }

    inline vec3& operator+=(const vec3 &v2);
    inline vec3& operator-=(const vec3 &v2);
    inline vec3& operator*=(const vec3 &v2);
    inline vec3& operator/=(const vec3 &v2);
    inline vec3& operator*=(const float t);
    inline vec3& operator/=(const float t);

    inline float l2() const {
        return sqrt(e[0]*e[0] + e[1]*e[1] + e[2]*e[2]);
    }

    inline float l1() const {
        return e[0]*e[0] + e[1]*e[1] + e[2]*e[2];
    }

    inline void unitv();

private:
    float e[3];
};

inline std::istream& operator>>(std::istream &is, vec3 &t) {
    is >> t[0] >> t[1] >> t[2];
    return is;
}

inline std::ostream& operator<<(std::ostream &os, vec3 &t) {
    os << t[0] << " " << t[1] << " " << t[2];
    return os;
}

inline void vec3::unitv() {
    float k = 1.0 / (*this).l2();
    e[0] *= k; e[1] *= k; e[2] *= k;
}

inline vec3 operator+(const vec3 &v1, const vec3 &v2) {
    return vec3(v1[0] + v2[0], v1[1] + v2[1], v1[2] + v2[2]);
}

inline vec3 operator-(const vec3 &v1, const vec3 &v2) {
    return vec3(v1[0] - v2[0], v1[1] - v2[1], v1[2] - v2[2]);
}

inline vec3 operator*(const vec3 &v1, const vec3 &v2) {
    return vec3(v1[0] * v2[0], v1[1] * v2[1], v1[2] * v2[2]);
}

inline vec3 operator/(const vec3 &v1, const vec3 &v2) {
    return vec3(v1[0] / v2[0], v1[1] / v2[1], v1[2] / v2[2]);
}

inline vec3 operator*(float t, const vec3 &v) {
    return vec3(t * v[0], t * v[1], t * v[2]);
}

inline vec3 operator/(vec3 v, float t) {
    return vec3(v[0] / t, v[1] / t, v[2] / t);
}

inline vec3 operator*(const vec3 &v, float t) {
    return vec3(t * v[0], t * v[1], t * v[2]);
}

inline float dot(const vec3 &v1, const vec3 &v2) {
    return v1[0] * v2[0] + v1[1] * v2[1] + v1[2] * v2[2];
}

inline vec3 cross(const vec3 &v1, const vec3 &v2) {
    return vec3(
        (v1[1] * v2[2] - v1[2] * v2[1]),
        -(v1[0] * v2[2] - v1[2] * v2[0]),
        (v1[0] * v2[1] - v1[1] * v2[0])
    );
}

inline vec3& vec3::operator+=(const vec3 &v) {
    e[0] += v[0];
    e[1] += v[1];
    e[2] += v[2];
    return *this;
}

inline vec3& vec3::operator*=(const vec3 &v) {
    e[0] *= v[0];
    e[1] *= v[1];
    e[2] *= v[2];
    return *this;
}

inline vec3& vec3::operator/=(const vec3 &v) {
    e[0] /= v[0];
    e[1] /= v[1];
    e[2] /= v[2];
    return *this;
}

inline vec3& vec3::operator*=(const float t) {
    e[0] *= t;
    e[1] *= t;
    e[2] *= t;
    return *this;
}

inline vec3& vec3::operator/=(const float t) {
    float k = 1.0/t;
    e[0] *= k;
    e[1] *= k;
    e[2] *= k;
    return *this;
}

inline vec3 unitv(vec3 v) {
    return v / v.l2();
}

inline vec3 reflect(const vec3& v, const vec3& n) {
    return v - 2 * dot(v, n) * n;
}

inline vec3 random_in_unit_sphere() {
    vec3 p;
    do {
        p = 2.0 * vec3(drand48(), drand48(), drand48()) - vec3(1, 1, 1);
    } while (p.l1() >= 1.0);
    return p;
}

#endif VEC3H__