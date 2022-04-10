class Quat
{
  PVector v;
  float w;

  Quat(PVector axis, float a) {
    this.v = PVector.mult(axis, sin(a * 0.5));
    this.w = cos(a * 0.5);
  }
  
  void from_axis_angle(PVector axis, float a) {
    this.v = PVector.mult(axis, sin(a * 0.5));
    this.w = cos(a * 0.5);
  }
  
  //vec' = vec + 2 * this.v x (this.w * vec + this.v x vec) / m
  PVector mult(PVector vec) {
    float m = this.v.magSq() + this.w*this.w;
    
    return PVector.add(
      vec,
      this.v.cross(  PVector.mult(vec, this.w)  .add(this.v.cross(vec))  ).mult(2).div(m) //mult(2 / m)?
    );
  }
  
  //a.w * b.w - a.x * b.x - a.y * b.y - a.z * b.z,  // w
  //a.w * b.x + a.x * b.w + a.y * b.z - a.z * b.y,  // x
  //a.w * b.y - a.x * b.z + a.y * b.w + a.z * b.x,  // y
  //a.w * b.z + a.x * b.y - a.y * b.x + a.z * b.w   // z
  //TODO remove z from the equation since they're never gonna have a z component
  void mult(Quat q) {
    this.w = this.w * q.w - this.v.x * q.v.x - this.v.y * q.v.y - this.v.z * q.v.z;
    this.v.set(
      this.w * q.v.x + this.v.x * q.w + this.v.y * q.v.z - this.v.z * q.v.y,
      this.w * q.v.y - this.v.x * q.v.z + this.v.y * q.w + this.v.z * q.v.x,
      this.w * q.v.z + this.v.x * q.v.y - this.v.y * q.v.x + this.v.z * q.w
    );
  }
}



/*
AXIS-ANGLE QUAT CONSTRUCTOR
qx = ax * sin(angle/2)
qy = ay * sin(angle/2)
qz = az * sin(angle/2)
qw = cos(angle/2)


QUAT-QUAT MULTIPLICATION
a.w * b.w - a.x * b.x - a.y * b.y - a.z * b.z,  // w
a.w * b.x + a.x * b.w + a.y * b.z - a.z * b.y,  // x
a.w * b.y - a.x * b.z + a.y * b.w + a.z * b.x,  // y
a.w * b.z + a.x * b.y - a.y * b.x + a.z * b.w   // z


QUAT-VEC MULTIPLICATION
v' = v + 2 * r x (s * v + r x v) / m

x = cross product
s and r are the scalar and vector parts of the quaternion
m is the sum of the squares of the components of the quaternion
*/
