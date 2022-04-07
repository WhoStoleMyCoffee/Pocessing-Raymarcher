
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


PVector dir_to(PVector a, PVector b) {
  return PVector.sub(b, a).normalize();
}


PVector rotY(PVector vec, float a) {
  return new PVector(vec.x * cos(a) + vec.z * sin(a), vec.y, -vec.x * sin(a) + vec.z * cos(a));
}


//COLOR --------------------------------------------------------------------------------------------------
color add_color(color a, color b, float amt) {
  return color(
    red(a) + red(b)*amt,
    green(a) + green(b)*amt,
    blue(a) + blue(b)*amt
  );
}


color mix_color(color a, color b, float amt) {
  return color(
    red(a) + (red(b) - red(a))*amt,
    green(a) + (green(b) - green(a))*amt,
    blue(a) + (blue(b) - blue(a))*amt
  );
}
