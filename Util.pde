
PVector vec_reflect(PVector dir, PVector normal) {
  return PVector.sub( dir, PVector.mult( normal, PVector.dot(dir,normal)*2 ) );
}


PVector estimate_normal(PVector p) {
  return new PVector(
    sceneSDF(p.x + EPSILON, p.y, p.z) - sceneSDF(p.x - EPSILON, p.y, p.z),
    sceneSDF(p.x, p.y + EPSILON, p.z) - sceneSDF(p.x, p.y - EPSILON, p.z),
    sceneSDF(p.x, p.y, p.z + EPSILON) - sceneSDF(p.x, p.y, p.z - EPSILON)
  ).normalize();
}


PVector rotY(PVector v, float a) {
  return new PVector(
    v.x * cos(a) + v.z * sin(a),
    v.y,
    -v.x * sin(a) + v.z * cos(a));
}


PVector rotAxis(PVector v, PVector n, float a) {
  //return v * cos(a) + (v.dot(n)*n*(1-cos(a)) + (n.cross(v)*sin(a));
  return PVector.mult(v, cos(a)).add( PVector.mult(n, v.dot(n)).mult(1-cos(a)) ).add(n.cross(v).mult(sin(a)));
}



//col1 : main sky color
//col2 : sky color at the horizon
//sunlight_col : color of the sunlight
//sun_energy : energy of the sun
//sun_dir : sun direction
void set_sky(color col1, color col2, color sun_col, float energy, PVector dir) {
  sky_col1 = col1;
  sky_col2 = col2;
  sunlight_col = sun_col;
  sun_energy = energy;
  sun_dir.set(dir);
}



//COLOR --------------------------------------------------------------------------------------------------
color add_color(color a, color b, float amt) {
  return color(
    red(a) + red(b)*amt,
    green(a) + green(b)*amt,
    blue(a) + blue(b)*amt
  );
}


color lerp_color(color a, color b, float amt) {
  return color(
    lerp(red(a), red(b), amt),
    lerp(green(a), green(b), amt),
    lerp(blue(a), blue(b), amt)
  );
}
