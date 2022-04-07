// CONTROLS ----------------------------------------------------------------------------
final float fov = HALF_PI;
final int pixel_size = 2, noise_amt = 4;
final float max_ray_dist = 50, max_marching_steps = 400;
final float mouse_sens = 0.01, cam_spd = 2.0;
final color sky_color = color(100);
final int max_ray_bounce = 3;
// -------------------------------------------------------------------------------------

boolean reflections_enabled = true;
boolean occlusion_enabled = true;

final float d = 1 / tan(fov / 2);
PVector cam_pos;
PVector cam_angle;

ArrayList<Shape> shapes;
ArrayList<Light> lights;
int xpx_count, ypx_count;
int noise_step = noise_amt;
color[][] screen_pixels;
float aspect_ratio;
float delta = 0, prev_time = 0;
boolean cam_control = false; //whether the user can control the camera

boolean wpressed = false;
boolean spressed = false;
boolean apressed = false;
boolean dpressed = false;
boolean qpressed = false;
boolean epressed = false;


void setup() {
  size(800, 800);

  xpx_count = floor(width / pixel_size);
  ypx_count = floor(height / pixel_size);
  screen_pixels = new color[xpx_count][ypx_count];

  shapes = new ArrayList<Shape>();
  lights = new ArrayList<Light>();

  //box
  Box b = new Box(1, -0.5, 5, 1, 1, 1);
  b.col = color(50);
  b.metallic = 0.8;
  shapes.add( b );

  //sphere
  Sphere s = new Sphere(2, -0.5, 2.4, 1);
  s.col = color(220, 50, 0);
  s.metallic = 0.8;
  shapes.add( s );

  //wireframe box
  ShapeDiff df = new ShapeDiff(
    new Box(-5, -1.5, 4,  2, 2, 2), 
    new Sphere(-5, -1.5, 4,  2.5)
  );
  df.col = color(38, 123, 76);
  shapes.add(df);

  //ground
  shapes.add( new Plane(0, 1, 0, new PVector(0, -1, 0), color(110), 0.0) ); //ground

  //lights
  lights.add( new Light(0, -10, 0,  100, 0.7, color(255, 100, 0)) );
  lights.add( new Light(5, -2,  3,  4,   0.5, color(27, 179, 247)) );

  cam_pos = new PVector(0, 0, -2);
  cam_angle = new PVector();
  aspect_ratio = width / height;
}





void draw() {
  delta = ( millis() * 0.001 ) - prev_time;
  prev_time = millis() * 0.001;
  
  
  
  background(sky_color);

  calc_rays();
  display_pixels();
  
  noise_step -= 1;

  //moving cam
  PVector cam_vel = new PVector(0, 0, 0);
  if (wpressed) cam_vel.z += 1;
  if (spressed) cam_vel.z -= 1;
  if (apressed) cam_vel.x -= 1;
  if (dpressed) cam_vel.x += 1;
  if (qpressed) cam_vel.y -= 1;
  if (epressed) cam_vel.y += 1;
  if (cam_vel.mag() > 0) noise_step = noise_amt;

  cam_vel = cam_vel.mult(cam_spd * delta);
  cam_pos.add(rotY(cam_vel, cam_angle.y));

  // CAMERA ROTATION -----------------------------------------------------------------
  if (cam_control) {
    float dy = mouseX - pmouseX;

    cam_angle.y += dy * mouse_sens;
    noise_step = noise_amt;
  }

  noise_step = max(noise_step, pixel_size);
}





void keyPressed() {
  noise_step = noise_amt;
  if (key == 'w') wpressed = true;
  if (key == 's') spressed = true;
  if (key == 'a') apressed = true;
  if (key == 'd') dpressed = true;
  if (key == 'q') qpressed = true;
  if (key == 'e') epressed = true;
  
  //F1
  if (keyCode == 112)
    reflections_enabled = !reflections_enabled;
  if (keyCode == 113)
    occlusion_enabled = !occlusion_enabled;
}

void keyReleased() {
  if (key == 'w') wpressed = false;
  if (key == 's') spressed = false;
  if (key == 'a') apressed = false;
  if (key == 'd') dpressed = false;
  if (key == 'q') qpressed = false;
  if (key == 'e') epressed = false;
}


void mousePressed() {
  cam_control = !cam_control;
}


void display_pixels() {
  noStroke();
  for (int x = 0; x < xpx_count; x += noise_step) {
    for (int y = 0; y < ypx_count; y += noise_step) {
      fill(screen_pixels[x][y]);
      square(x*pixel_size, y*pixel_size, pixel_size * noise_step);
    }
  }
}
