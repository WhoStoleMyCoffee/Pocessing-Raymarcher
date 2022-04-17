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
  Quat rot = new Quat();
  
  //gp : global point/pos
  float get_SDF(PVector gp) { return 0; }
  
  Shape set_col(color c) {
    this.col = c;
    return this;
  }
  Shape set_metallic(float v) {
    this.metallic = v;
    return this;
  }
  Shape set_rot(float rotx, float roty, float rotz) {
    rot = new Quat(rotx, roty, rotz);
    return this;
  }
  
  PVector to_local(PVector gp) {
    return rot.mult(PVector.sub(gp, pos));
  }
}


class Sphere extends Shape {
  float r;
  
  Sphere(float x, float y, float z, float _r) {
    pos = new PVector(x, y, z);
    r = _r;
  }
  
  float get_SDF(PVector gp) {
    return this.to_local(gp).mag() - r;
  }
  
}


class Box extends Shape {
  PVector bounds;
  Box (float x, float y, float z, float xs, float ys, float zs) {
    pos = new PVector(x, y, z);
    bounds = new PVector(xs, ys, zs);
  }
  
  //for whacky shit:
  //float get_SDF(PVector pos) {
  //  PVector p = new PVector(pos.x % 5 - 2.5, pos.y % 5 - 2.5, pos.z % 5 - 2.5);
  float get_SDF(PVector gp) {
    PVector p = this.to_local(gp);
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
  
  float get_SDF(PVector gp) {
    return PVector.dot(this.to_local(gp), n) - pos.y;
  }
}


class Ground extends Shape {
  PVector n = new PVector(0, 1, 0);
  
  Ground(float x, float y, float z) {
    pos = new PVector(x, y, z);
  }
  
  float get_SDF(PVector gp) {
    float h = pos.y + noise(gp.x * 0.1, gp.z * 0.1)*15;
    return PVector.dot(this.to_local(gp), n) - h;
  }
}






class ShapeIntersect extends Shape {
  Shape a, b;
  ShapeIntersect(float x, float y, float z, Shape _a, Shape _b) {
    pos = new PVector(x, y, z);
    a = _a;
    b = _b;
  }
  
  float get_SDF(PVector gp) {
    PVector p = this.to_local(gp);
    return max(a.get_SDF(PVector.sub(p, a.pos)), b.get_SDF(PVector.sub(p, b.pos)));
  }
}


//subtract b from a
class ShapeDiff extends Shape {
  Shape a, b;
  ShapeDiff(float x, float y, float z, Shape _a, Shape _b) {
    pos = new PVector(x, y, z);
    a = _a;
    b = _b;
  }
  
  float get_SDF(PVector gp) {
    PVector p = this.to_local(gp);
    return max(a.get_SDF(PVector.sub(p, a.pos)), -b.get_SDF(PVector.sub(p, b.pos)));
  }
}


class ShapeUnion extends Shape {
  Shape a, b;
  ShapeUnion(float x, float y, float z, Shape _a, Shape _b) {
    pos = new PVector(x, y, z);
    a = _a;
    b = _b;
  }
  
  float get_SDF(PVector gp) {
    PVector p = this.to_local(gp);
    return min(a.get_SDF(PVector.sub(p, a.pos)), b.get_SDF(PVector.sub(p, b.pos)));
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
