class RadarObject
{
  /* global variables to store the angle limits */
  protected final float min_angle;
  protected final float max_angle;
  protected final float step_angle;
  protected final int number_of_steps;
  
  /* global variables to store the display limits */
  protected final int center_x;
  protected final int center_y;
  protected final int max_width;
  protected final int max_height;
  
  /* global variables to store the drawing needle's attributes */
  protected final int needle_min_length;
  protected final int needle_max_length;
  protected final int needle_x_origin;
  protected final int needle_y_origin;
  protected float needle_angle;
  protected float prev_needle_angle;
  
  /* global variables to store detection range */
  protected final int max_detectable_distance;
  protected final int min_detectable_distance;
  
  /* global variables to store the display color */
  
  /* generic global variables */
  public int distance_threshold;
  public int data[];
  protected int data_index;
  
  RadarObject(int min_detectable_distance, int max_detectable_distance, int distance_threshold, int max_width, int max_height, int center_x, int center_y, float min_angle, float max_angle, float step_angle) throws Exception
  {
    /* initialize angle limits */
    this.min_angle = constrain(min_angle, -360, 360);
    this.max_angle = constrain(max_angle, -360, 360);
    this.step_angle = constrain(abs(step_angle), 0, 360);
    this.number_of_steps = int((this.max_angle - this.min_angle) / this.step_angle);
    
    /* max_angle must be greater than min_angle */
    if (this.max_angle < this.min_angle)
    {
      throw new IOException("invalid input variables: max_angle must be greater than min_angle");
    }
    
    /* initialize detection range */
    this.min_detectable_distance = min_detectable_distance;
    this.max_detectable_distance = max_detectable_distance;
    
    /* max_detectable_distance must be greater than min_detectable_distance */
    if (this.max_detectable_distance < this.min_detectable_distance)
    {
      throw new IOException("invalid input variables: max_detectable_distance must be greater than min_detectable_distance");
    }
    
    /* initialize display limits */
    this.center_x = center_x;
    this.center_y = center_y;
    this.max_width = max_width;
    this.max_height = max_height;
    
    /* initialize drawing needle attributes */
    this.needle_max_length = int(min(max_width/2.0, max_height/2.0));
    this.needle_min_length = int(((float)this.min_detectable_distance * this.needle_max_length)/((float)this.max_detectable_distance));
    this.needle_x_origin = center_x;
    this.needle_y_origin = center_y;//int(center_y + (max_height/2.0));
    this.needle_angle = this.min_angle;
    this.prev_needle_angle = this.min_angle;
    
    this.distance_threshold = distance_threshold;
  }
  
  protected void onNeedleStart()
  {
  }
  
  protected void onNeedleEnd()
  {
  }
  
  public void updateData(int data[])
  {
    /* ensure there is enough data */
    if (data.length < this.number_of_steps) { return; }
    this.data = data;
    
    //noFill(); strokeWeight(2); stroke(0, 255, 0);
    //ellipse(this.needle_x_origin, this.needle_y_origin, this.needle_max_length*2+6, this.needle_max_length*2+6);
  }
  
  protected void update()
  {
    if (this.data_index >= this.number_of_steps)
    {
      this.onNeedleEnd(); this.onNeedleStart();
      this.needle_angle = this.min_angle;
      this.data_index = 0;
    }
    
    int distance;
    color stroke_color;
    
    try
    {
       distance = this.data[this.data_index];
    }
    catch (NullPointerException e)
    {
      distance = this.min_detectable_distance;
      //e.printStackTrace();
    }
    
    if ( distance < this.min_detectable_distance)
    {
      stroke_color = color(0);
    }
    else if ( distance < this.distance_threshold)
    {
      stroke_color = color(255, 0, 0);
    }
    else
    {
      stroke_color = color(0, 255, 0);
    }
    
    this.drawData( distance, stroke_color, 2 );
    
    /* update needle angle */
    this.prev_needle_angle = this.needle_angle; 
    this.needle_angle += this.step_angle;
    this.data_index += 1;
  }
  
  private void drawData(int var, color stroke_color, int stroke_weight)
  {
    final int needle_length = int(map(var, this.min_detectable_distance, this.max_detectable_distance, this.needle_min_length, this.needle_max_length));
    
    this.drawNeedle();
    
    strokeWeight(stroke_weight);
    stroke(stroke_color);
    
    pushMatrix();
    translate(this.needle_x_origin, this.needle_y_origin);
    rotate(radians(this.needle_angle));
    line(0,0, 0, -needle_length);
    popMatrix();
  }
  
  private void drawNeedle()
  {
    strokeWeight(1);
    stroke(0);
    
    pushMatrix();
    translate(this.needle_x_origin, this.needle_y_origin);
    rotate(radians(this.prev_needle_angle+(this.step_angle*4)));
    line(0,0, 0, -needle_max_length);
    popMatrix();
    
    stroke(0, 255, 0);
    pushMatrix();
    translate(this.needle_x_origin, this.needle_y_origin);
    rotate(radians(this.needle_angle+(this.step_angle*4)));
    line(0,0, 0, -needle_max_length);
    popMatrix();
  }
};