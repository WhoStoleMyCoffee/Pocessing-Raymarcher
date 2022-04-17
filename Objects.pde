//https://iquilezles.org/www/articles/distfunctions/distfunctions.htm

class CollisionData {
  Shape collider = null;
  PVector pos = null;
  float dist;
  color col;
}


class Shape {
  PVector pos = new PVector();
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
  float get_SDF(PVector gp) {
    PVector p = this.to_local(gp);
    PVector q = PVector.sub(new PVector(abs(p.x), abs(p.y), abs(p.z)), bounds);
    return new PVector(max(q.x, 0), max(q.y, 0), max(q.z, 0)).mag() + min(max(q.x, max(q.y, q.z)), 0.0);
  }
}



class Fractal extends Shape {
  Shape s;
  float c;
  float o; //offset
  
  Fractal(Shape _s, float repeat_rate) {
    s = _s;
    c = repeat_rate;
    o = c*0.5;
  }
  
  float get_SDF(PVector gp) {
    return s.get_SDF(
      this.to_local( new PVector(abs(gp.x) % c - o, abs(gp.y) % c - o, abs(gp.z) % c - o) )
    );
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






class ShapeIntersect extends Shape {
  Shape a, b;
  ShapeIntersect(float x, float y, float z, Shape _a, Shape _b) {
    pos = new PVector(x, y, z);
    a = _a;
    b = _b;
  }
  
  float get_SDF(PVector gp) {
    PVector p = this.to_local(gp);
    return max(a.get_SDF(p), b.get_SDF(p));
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
    return max(  a.get_SDF(p), -b.get_SDF(p)  );
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
