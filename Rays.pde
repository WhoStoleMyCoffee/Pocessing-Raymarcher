//http://jamie-wong.com/2016/07/15/ray-marching-signed-distance-functions/
//pixels[y*pixel_size * xpx_count + x*pixel_size] = col;


void calc_rays() {
  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++) {

      //noise
      if (x % noise_step != 0 || y % noise_step != 0) {
        pixels[y * width + x] = pixels[floor(y / noise_step)*noise_step * width + floor(x / noise_step)*noise_step];
        continue;
      }


      PVector ray_dir = get_ray_direction(x, y, d);

      CollisionData collision = march_ray(cam_pos, ray_dir, max_ray_dist);
      color c = collision.col;

      if (collision.collider == null) {
        pixels[y * width + x] = c;
        continue;
      }

      if (reflections_enabled && collision.collider.metallic > 0)
        c = ray_reflection(ray_dir, collision, max_ray_bounce).col;

      pixels[y * width + x] = ray_occlusion(collision.pos, c);
    }
  }
}





CollisionData march_ray(PVector origin, PVector ray_dir, float max_dist) {
  CollisionData coll = new CollisionData();
  coll.dist = 0.1;

  for (int i = 0; i < max_marching_steps; i++) {
    PVector ray_pos = PVector.add(origin, PVector.mult(ray_dir, coll.dist));

    //get smallest distance
    float dist = max_dist;
    Shape closest_shape = null;
    for (Shape shape : shapes) {
      float dist_to_shape = shape.get_SDF(ray_pos);
      if (dist_to_shape > dist) continue;
      dist = dist_to_shape;
      closest_shape = shape;
    }

    if (dist < ray_hit_dist) { //inside the surface
      coll.collider = closest_shape;
      coll.col = closest_shape.col;
      coll.pos = ray_pos;
      return coll;
    }


    //move along the view ray
    coll.dist += dist;
    if (coll.dist >= max_dist)  break;
  }
  coll.collider = null;
  coll.dist = max_dist;
  coll.col = sky_color;
  coll.pos = null;
  return coll;
}



//  ray_dir : the incoming ray's direction
CollisionData ray_reflection(PVector ray_dir, CollisionData coll, int N)
{
  PVector reflect_vec = vec_reflect(ray_dir, estimate_normal(coll.pos));

  CollisionData reflection = march_ray(coll.pos, reflect_vec, max_ray_dist * 0.5);

  if (reflection.collider != null) {
    reflection.col = ray_occlusion(reflection.pos, reflection.col);
    if (N > 1)  reflection.col = ray_reflection(reflect_vec, reflection, N-1).col; //recursively calculate reflections
  }

  reflection.col = mix_color(coll.col, reflection.col, pow(coll.collider.metallic, 2));
  return reflection;
}



// TODO soft shadows
//  pos : the contact point on an object
//  albedo : the original color of that object at that position
color ray_occlusion(PVector pos, color albedo)
{
  if (!occlusion_enabled) return albedo;
  color c = albedo;

  for (Light light : lights)
  {
    float dist_to_light = PVector.dist(pos, light.pos);
    if (dist_to_light > light.r) continue; //too far away, skip

    PVector dir_to_light = dir_to(pos, light.pos);

    //CollisionData occlusion = march_ray(pos, dir_to_light, dist_to_light);
    //if (occlusion.collider != null) continue; //ray obstructed
    float res = soft_shadow(pos, dir_to_light, dist_to_light);
    if (res == 0.0) continue; //ray obstructed

    float dot = constrain( PVector.dot(estimate_normal(pos), dir_to_light), 0, 1 ); //angle
    float dist = constrain( map(dist_to_light, 0, light.r, light.energy, 0), 0, 1 ); //distance

    c = add_color(c, light.col, dot * dist * res);
    //c = add_color(c, light.col, res);
  }
  return c;
}



//https://www.iquilezles.org/www/articles/rmshadows/rmshadows.htm
float soft_shadow(PVector origin, PVector ray_dir, float max_dist) {
  float t = 0.1;
  float res = 1.0;

  for (int i = 0; i < max_marching_steps; i++) {
    PVector rp = PVector.add(origin, PVector.mult(ray_dir, t));

    float h = sceneSDF(rp.x, rp.y, rp.z);

    if (h < ray_hit_dist) //inside the surface
      return 0;

    //move along the view ray
    res = min(res, shadows_k * h/t);
    t += h;
    if (t >= max_dist)  break;
  }
  return res;
}


float sceneSDF(float px, float py, float pz) {
  float dist = max_ray_dist;
  PVector point = new PVector(px, py, pz);

  for (Shape shape : shapes)
    dist = min(shape.get_SDF(point), dist);

  return dist;
}


PVector get_ray_direction(int pixel_x, int pixel_y, float d) {
  return rotY(
    new PVector(
    aspect_ratio * (2 * (pixel_x + 0.5) / width) - 1,
    (2 * (pixel_y + 0.5) / height) - 1,
    d).normalize(),
    cam_angle.y);
}
