class Quat
{
  PVector v;
  float w;
  
  Quat() {
    v = new PVector();
    w = 1;
  }
  
  Quat(PVector axis, float a) {
    this.v = PVector.mult(axis, sin(a * 0.5));
    this.w = cos(a * 0.5);
  }
  
  Quat(PVector rot) {
    //set y axis
    this.v = PVector.mult(AXIS_Y, sin(rot.y * 0.5));
    this.w = cos(rot.y * 0.5);
    
    //mult x axis
    this.mult( new Quat(AXIS_X, rot.x) );
    //mult z axis
    this.mult( new Quat(AXIS_Z, rot.z) );
  }
  
  Quat(float rotx, float roty, float rotz) {
    //set y axis
    this.v = PVector.mult(AXIS_Y, sin(roty * 0.5));
    this.w = cos(roty * 0.5);
    
    //mult x axis
    this.mult( new Quat(AXIS_X, rotx) );
    //mult z axis
    this.mult( new Quat(AXIS_Z, rotz) );
  }
  
  //v' = v + 2 * r x (s * v + r x v) / m
  //x = cross product
  //s and r are the scalar and vector parts of the quaternion
  //m is the sum of the squares of the components of the quaternion
  PVector mult(PVector vec) {
    
    return PVector.add(
      vec,
      //   r   x               (s * v             +      r  x  v)           *   2 /    m
      this.v.cross(  PVector.mult(vec, this.w)  .add(this.v.cross(vec))  ).mult(2 / (this.v.magSq() + this.w*this.w))
    );
  }
  
  //a.w * b.w - a.x * b.x - a.y * b.y - a.z * b.z,  // w
  //a.w * b.x + a.x * b.w + a.y * b.z - a.z * b.y,  // x
  //a.w * b.y - a.x * b.z + a.y * b.w + a.z * b.x,  // y
  //a.w * b.z + a.x * b.y - a.y * b.x + a.z * b.w   // z
  Quat mult(Quat q) {
    this.w = this.w * q.w - this.v.x * q.v.x - this.v.y * q.v.y - this.v.z * q.v.z;
    this.v.set(
      this.w * q.v.x + this.v.x * q.w + this.v.y * q.v.z - this.v.z * q.v.y,
      this.w * q.v.y - this.v.x * q.v.z + this.v.y * q.w + this.v.z * q.v.x,
      this.w * q.v.z + this.v.x * q.v.y - this.v.y * q.v.x + this.v.z * q.w
    );
    return this;
  }
}
