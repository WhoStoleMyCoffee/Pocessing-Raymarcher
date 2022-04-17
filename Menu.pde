void start_button()
{
  int i = (int)cp5.get(ScrollableList.class, "levels").getValue();
  current_scene = i;
  setup_scene(i);
  
  cp5.hide();
  is_in_menu = false;
}



void clear_scene()
{
  shapes = new ArrayList<Shape>();
  lights = new ArrayList<Light>();
  cam_pos = new PVector(0, 0, 0);
  cam_angle = new PVector();
  rotation_q = new Quat();
  
  sky_col1 = color(64, 185, 277);
  sky_col2 = color(166, 233, 245);
  sunlight_col = color(254, 255, 224);
  sun_energy = 0.5;
  sun_dir = new PVector(0, 1, 0).normalize();
  
  reflections_enabled = true;
  occlusion_enabled = true;
  is_rendering = false;
}


void setup_scene(int index)
{
  println("Setting up scene " + str(index));
  
  clear_scene();
  rotation_q = new Quat(AXIS_Y, 0);

  switch(index)
  {
    //TEST SCENE
    case 0:
      sun_dir = new PVector(-0.2, 1, 0.1).normalize();
    
      //box
      shapes.add( new Box(1, 0.5, 5, 1, 1, 1)
        .set_col(color(50))
        .set_metallic(0.7)
        .set_rot(0, 1, 0)
        );
    
      //sphere
      shapes.add( new Sphere(2, 0.5, 2.4, 1)
        .set_col(color(220, 50, 0))
        .set_metallic(0.7)
        );
    
      //wireframe box
      shapes.add(new ShapeDiff( -5, 1, 4,
        new Box(0, 0, 0, 2, 2, 2),
        new Sphere(0, 0, 0, 2.5)
        ).set_col(color(38, 123, 76))
        );
    
      //ground
      shapes.add( new Plane(0, -0.5, 0, new PVector(0, 1, 0))
        .set_col(color(82, 113, 89))
        );
    
      //roof thing
      shapes.add( new Box(3, 5, 6, 4, 0.1, 4)
        .set_rot(0, 0, 0.5)
        );
    break;
    case 1:
      sky_col1 = color(57, 55, 62);
      sky_col2 = color(76, 82, 95);
      sunlight_col = color(0);
      sun_energy = 0;
      sun_dir = new PVector(0, 1, 0).normalize();
      
      //tunnel
      shapes.add(new ShapeDiff(0, 0, 0, 
        new ShapeDiff( 0, 0, 0,
          new Box(0, 0, 0, 4, 4, 8),
          new Box(0, 0, 0, 3.5, 3.5, 9)),
        new Box(0, 4, 0, 2, 2, 2)
        ).set_col(color(51, 51, 83))
      );
      
      //ground
      shapes.add( new Plane(0, -0.5, 0, new PVector(0, 1, 0))
        .set_col(color(62, 103, 69))
      );
      
      lights.add( new Light(0, 0, 0,   10, 0.2, color(147, 129, 27)) );
    break;
    default:
      //ground
      shapes.add( new Plane(0, -0.5, 0, new PVector(0, 1, 0))
        .set_col(color(82, 113, 89))
        );
    break;
  }
}
