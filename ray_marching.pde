import controlP5.*;

/*
WASD to move
Q : Go up
E : Go down

F1 Toggle render mode
F2 : Take screenshot

Click : Toggle mouse controls
*/


// CONTROLS ----------------------------------------------------------------------------
final float fov = HALF_PI;
final int noise_amt = 10; //how un-detailed it is when not rendering
final float max_ray_dist = 50;
final float mouse_sens = 0.01,  cam_spd = 4.0; //camera controls
final int max_ray_bounce = 3; //for reflections
final float ray_hit_dist = 0.002; //at what distance to the scene will a ray be considered to have hit an object
final float init_ray_step = 0.01; //initial ray step when marching
final float shadows_k = 8; //shadow blur amount. higher = less blur

//scene params
color sky_col1 = color(64, 185, 277); //main sky color
color sky_col2 = color(166, 233, 245); //sky color at the horizon
color sunlight_col = color(254, 255, 224);
float sun_energy = 0.5;
PVector sun_dir = new PVector(-0.2, 1, 0.1).normalize(); //Must be normalized

color fog_col = color(128);
float fog_thickness = 0.02;
// -------------------------------------------------------------------------------------

//RENDERER VARIABLES
boolean reflections_enabled = true;
boolean occlusion_enabled = true;
boolean is_rendering = false;

final PVector AXIS_X = new PVector(1, 0, 0);
final PVector AXIS_Y = new PVector(0, 1, 0);
final PVector AXIS_Z = new PVector(0, 0, 1);
final float d = 1 / tan(fov / 2);
PVector cam_pos;
PVector cam_angle;
Quat rotation_q;

ArrayList<Shape> shapes;
ArrayList<Light> lights;
int noise_step = noise_amt;
float aspect_ratio;
float delta = 0;
boolean cam_control = false; //whether the user can control the camera

boolean wpressed = false;
boolean spressed = false;
boolean apressed = false;
boolean dpressed = false;
boolean qpressed = false;
boolean epressed = false;


//MENU
ControlP5 cp5;
boolean is_in_menu = true;




void setup() {
  size(800, 800);
  surface.setTitle("Ray Marcher | Menu");

  aspect_ratio = width / height;
  
  //setup the menu
  cp5 = new ControlP5(this);
  
  cp5.addTextlabel("title")
    .setText("Scuffed Ray Marcher")
    .setPosition(20, 20)
    .setColor(color(0))
    .setFont(createFont("arial", 30));
  
  cp5.addTextlabel("author")
    .setText("created by WhoStoleMyCoffee")
    .setPosition(20, 60)
    .setColor(color(0))
    .setFont(createFont("arial", 14));
  
  
  String[] levels = {"test", "world"};
  cp5.addScrollableList("levels")
    .setPosition(20, 120)
    .setSize(200, 100)
    .setBarHeight(40)
    .setItems(levels)
    .setValue(0);
  
  Button b = cp5.addButton("start_button")
    .setPosition(250, 120)
    .setCaptionLabel("open scene");
}





void draw() {
  if (is_in_menu)
  {
    background(220);
    return;
  }
  
  
  delta = 1 / frameRate;

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
  if (qpressed) cam_vel.y += 1;
  if (epressed) cam_vel.y -= 1;
  if (cam_vel.mag() > 0) noise_step = noise_amt;

  cam_vel = cam_vel.mult(cam_spd * delta);
  cam_pos.add(rotY(cam_vel, cam_angle.y));

  // CAMERA ROTATION -----------------------------------------------------------------------------------------------------------
  if (cam_control) {
    cam_angle.y += (mouseX - pmouseX) * mouse_sens;
    cam_angle.x += (mouseY - pmouseY) * mouse_sens;
    rotation_q = new Quat(cam_angle);
    noise_step = noise_amt;
  }
  
  if (!is_rendering)
    noise_step = noise_amt;

  surface.setTitle("Ray Marcher | " + str(floor(frameRate)) + "fps");
}





void keyPressed() {
  if (is_in_menu) return;
  
  noise_step = noise_amt;
  if (key == 'w') wpressed = true;
  if (key == 's') spressed = true;
  if (key == 'a') apressed = true;
  if (key == 'd') dpressed = true;
  if (key == 'q') qpressed = true;
  if (key == 'e') epressed = true;
  
  //ESC go back to menu
  if (key == 27) {
    key = 0;
    
    is_in_menu = true;
    clear_scene();
    cp5.show();
    surface.setTitle("Ray Marcher | Menu");
  }
  
  
  if (keyCode == 112) //F1
    is_rendering = !is_rendering;
    reflections_enabled = is_rendering;
    occlusion_enabled = is_rendering;
  
  if (keyCode == 113) {//F2
    println("Took screenshot (:");
    save("screenshot_" + str(year()) + "-" + str(month()) + "-" + str(day()) + "_" + str(hour()) + "." + str(minute()) + "." + str(second()) + ".png");
  }
}

void keyReleased() {
  if (is_in_menu) return;
  
  if (key == 'w') wpressed = false;
  if (key == 's') spressed = false;
  if (key == 'a') apressed = false;
  if (key == 'd') dpressed = false;
  if (key == 'q') qpressed = false;
  if (key == 'e') epressed = false;
}


void mousePressed() {
  if (is_in_menu) return;
  
  cam_control = !cam_control;
  if (cam_control) cursor(MOVE);
  else cursor(ARROW);
}
