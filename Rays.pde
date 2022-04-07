//http://jamie-wong.com/2016/07/15/ray-marching-signed-distance-functions/


void calc_rays() {
  for (int x = 0; x < xpx_count; x += noise_step) {
    for (int y = 0; y < ypx_count; y += noise_step) {
      PVector ray_dir = get_ray_direction(x, y, d);
      
      
      CollisionData collision = march_ray(cam_pos, ray_dir, max_ray_dist);
      screen_pixels[x][y] = collision.col;
      
      if (collision.collider == null)  continue;
      
      if (reflections_enabled && collision.collider.metallic > 0)
        screen_pixels[x][y] = ray_reflection(ray_dir, collision, max_ray_bounce).col;
      
      screen_pixels[x][y] = ray_occlusion(collision.pos, screen_pixels[x][y]);
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
      if (dist_to_shape < dist) {
        dist = dist_to_shape;
        closest_shape = shape;
      }
    }
    
    if (dist < EPSILON) { //inside the surface
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
    
    CollisionData occlusion = march_ray(pos, dir_to_light, dist_to_light);
    if (occlusion.collider != null) continue; //ray obstructed
    
    float dot = constrain( PVector.dot(estimate_normal(pos), dir_to_light), 0, 1 ); //angle
    float mlt = constrain( map(dist_to_light, 0, light.r, light.energy, 0), 0, 1 ); //distance
    c = add_color(c, light.col, dot * mlt);
  }
  return c;
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
      aspect_ratio * (2 * (pixel_x + 0.5) / xpx_count) - 1,
      (2 * (pixel_y + 0.5) / ypx_count) - 1,
      d).normalize(),
    cam_angle.y);
}
