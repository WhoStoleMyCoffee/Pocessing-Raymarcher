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
  
}


class Sphere extends Shape {
  float r;
  
  Sphere(float x, float y, float z, float _r) {
    pos = new PVector(x, y, z);
    r = _r;
  }
  
  float get_SDF(PVector point) {
    return PVector.dist(point, pos) - r;
  }
  
}


class Box extends Shape {
  PVector bounds;
  Box (float x, float y, float z, float xs, float ys, float zs) {
    pos = new PVector(x, y, z);
    bounds = new PVector(xs, ys, zs);
  }
  
  float get_SDF(PVector point) {
    PVector p = PVector.sub(point, pos);
    PVector q = PVector.sub(new PVector(abs(p.x), abs(p.y), abs(p.z)), bounds);
    return new PVector(max(q.x, 0), max(q.y, 0), max(q.z, 0)).mag() + min(max(q.x, max(q.y, q.z)), 0.0);
  }
}


class Plane extends Shape {
  PVector n;
  
  Plane(float x, float y, float z, PVector normal, color _col, float _metallic) {
    pos = new PVector(x, y, z);
    n = normal;
    col = _col;
    metallic = _metallic;
  }
  
  float get_SDF(PVector point) {
    return PVector.dot(point, n) + pos.y;
  }
}


class TorusX extends Shape {
  float size, thickness;
  TorusX(float x, float y, float z, float _size, float _thickness) {
    pos = new PVector(x, y, z);
    size = _size;
    thickness = _thickness;
  }
  
  float get_SDF(PVector point) {
    PVector p = PVector.sub(point, pos);
    float l = new PVector(p.y, p.z).mag();
    PVector q = new PVector(l - size, p.x);
    
    return q.mag() - thickness;
  }
}




class ShapeIntersect extends Shape {
  Shape a, b;
  ShapeIntersect(Shape _a, Shape _b) {
    a = _a;
    b = _b;
  }
  
  float get_SDF(PVector point) {
    float da = a.get_SDF(point);
    float db = b.get_SDF(point);
    return max(da, db);
  }
}


class ShapeDiff extends Shape {
  Shape a, b;
  ShapeDiff(Shape _a, Shape _b) {
    a = _a;
    b = _b;
  }
  
  float get_SDF(PVector point) {
    return max(a.get_SDF(point), -b.get_SDF(point));
  }
}


class ShapeUnion extends Shape {
  Shape a, b;
  ShapeUnion(Shape _a, Shape _b) {
    a = _a;
    b = _b;
  }
  
  float get_SDF(PVector point) {
    return min(a.get_SDF(point), b.get_SDF(point));
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
