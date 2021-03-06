//http://jamie-wong.com/2016/07/15/ray-marching-signed-distance-functions/


void calc_rays() {
  for (int x = 0; x < width; x++) {
    for (int y = 0; y < height; y++) {

      //noise
      if (x % noise_step != 0 || y % noise_step != 0) {
        pixels[y * width + x] = pixels[floor(y / noise_step)*noise_step * width + floor(x / noise_step)*noise_step];
        continue;
      }

      PVector ray_dir = get_ray_direction(x, height - y, d);

      CollisionData collision = march_ray(cam_pos, ray_dir, max_ray_dist);
      color c = collision.col;
      
      if (collision.collider == null) {
        pixels[y * width + x] = is_rendering ? c : sky_col2;
        continue;
      }
      
      //if not rendering, just set the color based on the normal
      if (!is_rendering) {
        pixels[y * width + x] = color( map(estimate_normal(collision.pos).dot(ray_dir), -1, 1, 220, 0) );
        continue;
      }
      
      if (reflections_enabled && collision.collider.metallic > 0)
        c = ray_reflection(ray_dir, collision, max_ray_bounce).col;

      c = ray_occlusion(collision.pos, c);
      pixels[y * width + x] = apply_fog(c, collision.dist);
    }
  }
  
  
}





CollisionData march_ray(PVector origin, PVector ray_dir, float max_dist) {
  CollisionData coll = new CollisionData();
  coll.dist = init_ray_step;

  while (coll.dist < max_dist) {
    PVector ray_pos = PVector.add(origin, PVector.mult(ray_dir, coll.dist));

    //GET SCENE DISTANCE
    float dist = max_dist;
    Shape closest_shape = null;
    for (Shape shape : shapes)
    {
      float dist_to_shape = shape.get_SDF( ray_pos );
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
  }
  coll.collider = null;
  coll.dist = max_dist;
  coll.col = lerp_color(sky_col2, sky_col1, map(max(ray_dir.y, 0), 0, 1, 0, 1)); //sky
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

  reflection.col = lerp_color(coll.col, reflection.col, pow(coll.collider.metallic, 2));
  return reflection;
}



//  pos : the contact point on an object
//  albedo : the original color of that object at that position
color ray_occlusion(PVector pos, color albedo)
{
  if (!occlusion_enabled) return albedo;
  color c = albedo;

  //SUNLIGHT
  {
    float res = soft_shadow(pos, sun_dir, 999);
    if (res >= 0.1) {
      c = add_color(c, sunlight_col,
        constrain( PVector.dot(estimate_normal(pos), sun_dir), 0, 1 ) //angle
        * res * sun_energy);
    }
  }
  


  //LIGHTS IN THE SCENE
  for (Light light : lights)
  {
    float dist_to_light = PVector.dist(pos, light.pos);
    if (dist_to_light > light.r) continue; //too far away, skip

    PVector dir_to_light = PVector.sub(light.pos, pos).normalize();

    float res = soft_shadow(pos, dir_to_light, dist_to_light);
    if (res < 0.1) continue; //ray obstructed

    c = add_color(c, light.col,
      constrain( PVector.dot(estimate_normal(pos), dir_to_light), 0, 1 ) //angle
      * constrain( map(dist_to_light, 0, light.r, light.energy, 0), 0, 1 ) //distance
      * res
      );
  }
  return c;
}



//https://www.iquilezles.org/www/articles/rmshadows/rmshadows.htm
float soft_shadow(PVector origin, PVector ray_dir, float max_dist) {
  float t = init_ray_step;
  float res = 1.0;

  while (t < max_dist) {
    PVector rp = PVector.add(origin, PVector.mult(ray_dir, t));

    float h = sceneSDF(rp.x, rp.y, rp.z);

    if (h < ray_hit_dist) //inside the surface
      return 0;

    //move along the view ray
    res = min(res, shadows_k * h/t);
    t += h;
  }
  return max(res, 0);
}


//c : original color
//d : distance (between 0 and 1)
color apply_fog(color c, float d)
{
  return color(
    lerp(red(fog_col),   red(c),   exp(-fog_thickness * d)),
    lerp(green(fog_col), green(c), exp(-fog_thickness * d * 2)),
    lerp(blue(fog_col),  blue(c),  exp(-fog_thickness * d  * 4))
  );
}






float sceneSDF(float px, float py, float pz)
{
  float dist = max_ray_dist;
  PVector point = new PVector(px, py, pz);

  for (Shape shape : shapes)
    dist = min(shape.get_SDF( point ), dist);

  return dist;
}


PVector get_ray_direction(int pixel_x, int pixel_y, float d) {
  PVector v = new PVector(
    aspect_ratio * (2 * (pixel_x + 0.5) / width) - 1,
    (2 * (pixel_y + 0.5) / height) - 1,
    d).normalize();
  
  return rotation_q.mult(v);
}
