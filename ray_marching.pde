// CONTROLS ----------------------------------------------------------------------------
final float fov = HALF_PI;
final int noise_amt = 8;
final float max_ray_dist = 50, max_marching_steps = 400;
final float mouse_sens = 0.01, cam_spd = 4.0;
final int max_ray_bounce = 4;
final float ray_hit_dist = 0.0004; //at what distance to the scene will a ray be considered to have hit an object
final float shadows_k = 8;

final color sky_col1 = color(64, 185, 277);
final color sky_col2 = color(166, 233, 245);
final color sunlight_col = color(254, 255, 224);
final float sun_energy = 0.5;
PVector sun_dir = new PVector(0.2, -1, 0.1).normalize(); //Must be normalized
// -------------------------------------------------------------------------------------

boolean reflections_enabled = true;
boolean occlusion_enabled = true;
boolean is_lowres = true;

final float d = 1 / tan(fov / 2);
PVector cam_pos;
PVector cam_angle;

ArrayList<Shape> shapes;
ArrayList<Light> lights;
int noise_step = noise_amt;
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

  shapes = new ArrayList<Shape>();
  lights = new ArrayList<Light>();

  //box
  shapes.add( new Box(1, -0.5, 5, 1, 1, 1)
    .set_col(color(50))
    .set_metallic(0.7)
  );

  //sphere
  shapes.add( new Sphere(2, -0.5, 2.4, 1)
    .set_col(color(220, 50, 0))
    .set_metallic(0.7)
  );

  //wireframe box
  shapes.add(new ShapeDiff(
      new Box(-5, -1, 4,  2, 2, 2), 
      new Sphere(-5, -1, 4,  2.5)
    ).set_col(color(38, 123, 76))
  );

  //ground
  shapes.add( new Plane(1, new PVector(0, -1, 0))
    .set_col(color(110)));
  
  //other box
  //shapes.add( new Box(5, -4, 3, 4, 1, 4)
  //  .set_col(color(51)) );
  

  //lights
  //lights.add( new Light(5, -2,  3,   6,   0.5, color(27, 179, 247)) );

  cam_pos = new PVector(0, 0, 0);
  cam_angle = new PVector();
  aspect_ratio = width / height;
}





void draw() {
  delta = ( millis() * 0.001 ) - prev_time;
  prev_time = millis() * 0.001;

  if (noise_step > 0) {
    loadPixels();
    calc_rays();
    updatePixels();
    
    noise_step -= 1;
  }

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
  
  if (is_lowres)
    noise_step = noise_amt;

  //noise_step = max(noise_step, 1);
  println(frameRate);
}





void keyPressed() {
  noise_step = noise_amt;
  if (key == 'w') wpressed = true;
  if (key == 's') spressed = true;
  if (key == 'a') apressed = true;
  if (key == 'd') dpressed = true;
  if (key == 'q') qpressed = true;
  if (key == 'e') epressed = true;
  
  if (keyCode == 112) //F1
    is_lowres = !is_lowres;
  if (keyCode == 113) //F2
    reflections_enabled = !reflections_enabled;
  if (keyCode == 114) //F3
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
  if (cam_control) cursor(MOVE);
  else cursor(ARROW);
}
