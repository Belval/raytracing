#ifndef Vec3H__
#define Vec3H__

#include <math.h>
#include <stdlib.h>
#include <iostream>

class Vec3 {
public:
    Vec3() {}
    Vec3(float e0, float e1, float e2) { e[0] = e0, e[1] = e1, e[2] = e2; }
    inline float x() const { return e[0]; }
    inline float y() const { return e[1]; }
    inline float z() const { return e[2]; }
    inline float r() const { return e[0]; }
    inline float g() const { return e[1]; }
    inline float b() const { return e[2]; }

    inline const Vec3& operator+() const { return *this; }
    inline Vec3 operator-() const { return Vec3(-e[0], -e[1], -e[2]); }
    inline float operator[](int i) const { return e[i]; }
    inline float& operator[](int i) { return e[i]; }

    inline Vec3& operator+=(const Vec3 &v2);
    inline Vec3& operator-=(const Vec3 &v2);
    inline Vec3& operator*=(const Vec3 &v2);
    inline Vec3& operator/=(const Vec3 &v2);
    inline Vec3& operator*=(const float t);
    inline Vec3& operator/=(const float t);

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

inline std::istream& operator>>(std::istream &is, Vec3 &t) {
    is >> t[0] >> t[1] >> t[2];
    return is;
}

inline std::ostream& operator<<(std::ostream &os, Vec3 &t) {
    os << t[0] << " " << t[1] << " " << t[2];
    return os;
}

inline void Vec3::unitv() {
    float k = 1.0 / (*this).l2();
    e[0] *= k; e[1] *= k; e[2] *= k;
}

inline Vec3 operator+(const Vec3 &v1, const Vec3 &v2) {
    return Vec3(v1[0] + v2[0], v1[1] + v2[1], v1[2] + v2[2]);
}

inline Vec3 operator-(const Vec3 &v1, const Vec3 &v2) {
    return Vec3(v1[0] - v2[0], v1[1] - v2[1], v1[2] - v2[2]);
}

inline Vec3 operator*(const Vec3 &v1, const Vec3 &v2) {
    return Vec3(v1[0] * v2[0], v1[1] * v2[1], v1[2] * v2[2]);
}

inline Vec3 operator/(const Vec3 &v1, const Vec3 &v2) {
    return Vec3(v1[0] / v2[0], v1[1] / v2[1], v1[2] / v2[2]);
}

inline Vec3 operator*(float t, const Vec3 &v) {
    return Vec3(t * v[0], t * v[1], t * v[2]);
}

inline Vec3 operator/(Vec3 v, float t) {
    return Vec3(v[0] / t, v[1] / t, v[2] / t);
}

inline Vec3 operator*(const Vec3 &v, float t) {
    return Vec3(t * v[0], t * v[1], t * v[2]);
}

inline float dot(const Vec3 &v1, const Vec3 &v2) {
    return v1[0] * v2[0] + v1[1] * v2[1] + v1[2] * v2[2];
}

inline Vec3 cross(const Vec3 &v1, const Vec3 &v2) {
    return Vec3(
        (v1[1] * v2[2] - v1[2] * v2[1]),
        -(v1[0] * v2[2] - v1[2] * v2[0]),
        (v1[0] * v2[1] - v1[1] * v2[0])
    );
}

inline Vec3& Vec3::operator+=(const Vec3 &v) {
    e[0] += v[0];
    e[1] += v[1];
    e[2] += v[2];
    return *this;
}

inline Vec3& Vec3::operator*=(const Vec3 &v) {
    e[0] *= v[0];
    e[1] *= v[1];
    e[2] *= v[2];
    return *this;
}

inline Vec3& Vec3::operator/=(const Vec3 &v) {
    e[0] /= v[0];
    e[1] /= v[1];
    e[2] /= v[2];
    return *this;
}

inline Vec3& Vec3::operator*=(const float t) {
    e[0] *= t;
    e[1] *= t;
    e[2] *= t;
    return *this;
}

inline Vec3& Vec3::operator/=(const float t) {
    float k = 1.0/t;
    e[0] *= k;
    e[1] *= k;
    e[2] *= k;
    return *this;
}

inline Vec3 unitv(Vec3 v) {
    return v / v.l2();
}

inline Vec3 reflect(const Vec3& v, const Vec3& n) {
    return v - 2 * dot(v, n) * n;
}

inline Vec3 random_in_unit_Sphere() {
    Vec3 p;
    do {
        p = 2.0 * Vec3(drand48(), drand48(), drand48()) - Vec3(1, 1, 1);
    } while (p.l1() >= 1.0);
    return p;
}

bool refract(const Vec3& v, const Vec3& n, float ni_over_nt, Vec3& refracted) {
    Vec3 uv = unitv(v);
    float dt = dot(uv, n);
    float discriminant = 1.0 - ni_over_nt*ni_over_nt*(1-dt*dt);
    if (discriminant > 0) {
        refracted = ni_over_nt*(uv - n*dt) - n*sqrt(discriminant);
        return true;
    }
    else
        return false;
}

#endif