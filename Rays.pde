//http://jamie-wong.com/2016/07/15/ray-marching-signed-distance-functions/


void calc_rays() {
  for (int x = 0; x < xpx_count; x += noise_step) {
    for (int y = 0; y < ypx_count; y += noise_step) {
      PVector ray_dir = get_ray_direction(x, y, d);
      
      CollisionData collision = calc_ray(cam_pos, ray_dir, max_ray_dist);
      
      //set the albedo
      screen_pixels[x][y] = collision.col;
      
      //if we didn't hit anything, continue
      if (collision.pos == null) continue;
      
      //REFLECTION -----------------------------------------------------------
      if (collision.collider.metallic > 0 && reflections_enabled) {
        CollisionData reflection = ray_reflection(x, y, collision, ray_dir);
        
        //calclate the reflected object's light too
        if (reflection.pos != null && occlusion_enabled) {
          float effect = collision.collider.metallic;
          ray_occlusion(x, y, reflection, reflection.col, effect);
        }
      }
      
      //OCCLUSION ------------------------------------------------------------
      if (occlusion_enabled)
        ray_occlusion(x, y, collision, screen_pixels[x][y], 1);
   
      
      
    }
  }
}



//CALC RAY -------------------------------------------------------------------------------------------------- 
CollisionData calc_ray(PVector origin, PVector ray_dir, float max_dist) {
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
    
    if (coll.dist >= max_dist) {
      coll.collider = null;
      coll.dist = max_ray_dist;
      coll.col = sky_color;
      coll.pos = null;
      return coll;
    }
    
  }
  coll.collider = null;
  coll.dist = max_dist;
  coll.col = sky_color;
  coll.pos = null;
  return coll;
  
}



CollisionData ray_reflection(int px, int py, CollisionData coll, PVector ray_dir) {
    //get reflection vector
    PVector Pc = coll.pos;
    //PVector reflect_dir = get_ray_reflection_vec(ray_dir, estimate_normal(Pc) );
    ray_dir.set ( get_ray_reflection_vec(ray_dir, estimate_normal(Pc)) );
    
    //calculate reflection
    CollisionData reflection = calc_ray(Pc, ray_dir, max_ray_dist/2);
    reflection.col = mix_color(screen_pixels[px][py], reflection.col, coll.collider.metallic * coll.collider.metallic);
    
    //mix the colors
    screen_pixels[px][py] = reflection.col;
    
    return reflection;
}



void ray_occlusion(int px, int py, CollisionData coll, color albedo, float light_effect) {
  color occ_color = albedo; //albedo
  
  for (Light light : lights) {
    float dist_to_light = PVector.dist(coll.pos, light.pos);
    PVector dir_to_light = dir_to(coll.pos, light.pos);
    
    if (dist_to_light > light.energy) continue; //too far away
    
    CollisionData occlusion;
    occlusion = calc_ray(coll.pos, dir_to_light, dist_to_light);
    
    if (occlusion.pos == null) { //if light is not obstructed
      
      float dot = constrain( PVector.dot( estimate_normal(coll.pos) , dir_to_light), 0, 1 ); //angle
      float mlt = constrain( map(dist_to_light, 0, light.energy, 1, 0), 0, 1 ); //distance
      
      occ_color = add_color(occ_color, light.col, dot * mlt * light_effect);
      
    }
    
  }
  screen_pixels[px][py] = occ_color;
}



float sceneSDF(float px, float py, float pz) {
  float dist = max_ray_dist;
  PVector point = new PVector(px, py, pz);
  
  for (Shape shape : shapes)
    dist = min(shape.get_SDF(point), dist);
    
  return dist;
}


PVector get_ray_direction(int pixel_x, int pixel_y, float d) {
  PVector v = new PVector(
    aspect_ratio * (2 * (pixel_x + 0.5) / xpx_count) - 1,
    (2 * (pixel_y + 0.5) / ypx_count) - 1,
    d).normalize();
  return rotY(v, cam_angle.y);
}



PVector get_ray_reflection_vec(PVector dir, PVector normal) {
  return PVector.sub( dir, PVector.mult( normal, PVector.dot(dir,normal)*2 ) );
}


PVector estimate_normal(PVector p) {
  return new PVector(
    sceneSDF(p.x + EPSILON, p.y, p.z) - sceneSDF(p.x - EPSILON, p.y, p.z),
    sceneSDF(p.x, p.y + EPSILON, p.z) - sceneSDF(p.x, p.y - EPSILON, p.z),
    sceneSDF(p.x, p.y, p.z + EPSILON) - sceneSDF(p.x, p.y, p.z - EPSILON)
  ).normalize();
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
