//https://iquilezles.org/www/articles/distfunctions/distfunctions.htm

class CollisionData {
  Shape collider = null;
  PVector pos = null;
  float dist;
  color col;
}


class Shape {
  PVector pos;
  color col = color(0);
  float metallic = 0;
  
  float get_SDF(PVector point) { return 0; }
  
  Shape set_col(color c) {
    this.col = c;
    return this;
  }
  Shape set_metallic(float v) {
    this.metallic = v;
    return this;
  }
}


class Sphere extends Shape {
  float r;
  
  Sphere(float x, float y, float z, float _r) {
    pos = new PVector(x, y, z);
    r = _r;
  }
  
  float get_SDF(PVector p) {
    return p.mag() - r;
  }
  
}


class Box extends Shape {
  PVector bounds;
  Box (float x, float y, float z, float xs, float ys, float zs) {
    pos = new PVector(x, y, z);
    bounds = new PVector(xs, ys, zs);
  }
  
  float get_SDF(PVector p) {
    PVector q = PVector.sub(new PVector(abs(p.x), abs(p.y), abs(p.z)), bounds);
    return new PVector(max(q.x, 0), max(q.y, 0), max(q.z, 0)).mag() + min(max(q.x, max(q.y, q.z)), 0.0);
  }
}


class Plane extends Shape {
  PVector n;
  
  Plane(float x, float y, float z, PVector normal) {
    pos = new PVector(x, y, z);
    n = normal;
  }
  
  float get_SDF(PVector p) {
    return PVector.dot(p, n) + pos.y;
  }
}




class ShapeIntersect extends Shape {
  Shape a, b;
  ShapeIntersect(float x, float y, float z, Shape _a, Shape _b) {
    pos = new PVector(x, y, z);
    a = _a;
    b = _b;
  }
  
  float get_SDF(PVector p) {
    return max(a.get_SDF(p), b.get_SDF(p));
  }
}


class ShapeDiff extends Shape {
  Shape a, b;
  ShapeDiff(float x, float y, float z, Shape _a, Shape _b) {
    pos = new PVector(x, y, z);
    a = _a;
    b = _b;
  }
  
  float get_SDF(PVector p) {
    return max(a.get_SDF(p), -b.get_SDF(p));
  }
}


class ShapeUnion extends Shape {
  Shape a, b;
  ShapeUnion(float x, float y, float z, Shape _a, Shape _b) {
    pos = new PVector(x, y, z);
    a = _a;
    b = _b;
  }
  
  float get_SDF(PVector p) {
    return min(a.get_SDF(p), b.get_SDF(p));
  }
}




class Light {
  PVector pos;
  float r; //radius
  float energy; //0 = none, 1 = full energy
  color col;
  Light(float x, float y, float z, float _radius, float _energy, color _col) {
    pos = new PVector(x, y, z);
    r = _radius;
    energy = _energy;
    col = _col;
  }
}
