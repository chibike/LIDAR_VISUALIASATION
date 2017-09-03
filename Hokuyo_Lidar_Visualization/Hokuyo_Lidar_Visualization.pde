MyRadarObject my_radar;

void setup()
{
  //fullScreen();
  size(1500, 1000);
  background(0);
  frameRate(120);
  
  try
  {
    my_radar = new MyRadarObject(20, 4095, 1000, width - 50, height - 50, int(width/2.0), int(height/2.0), -135, 135, 0.3515625);
  }
  catch (Exception e)
  {
    handleError(e, "setup", "could not get radar_object", true);
  }
}

void draw()
{
  my_radar.update();
}

int[] fetchLidarData()
{
  try
  {
    JSONObject jsonObject = loadJSONObject("http://localhost:9999/api/v1/getlidardata");
    JSONArray data = jsonObject.getJSONArray("data");
    //println("DataSize: "+data.size());
    return data.getIntArray();
  }
  catch (NullPointerException e)
  {
    handleError(e, "fetchLidarData", "LIDAR Server Down!", true);
    return new int[768];
  }
}

void handleError(Exception e, String context, String msg, boolean should_show_msg)
{
  if ( msg.length() <= 0)
  {
    msg = e.toString();
  }
  
  String message = context + ": " + msg;
  if (should_show_msg)
  {
    println(message);
  }
  
  e.printStackTrace();
}

class MyRadarObject extends QuickRadarObject
{
  MyRadarObject(int min_detectable_distance, int max_detectable_distance, int distance_threshold, int max_width, int max_height, int center_x, int center_y, float min_angle, float max_angle, float step_angle) throws Exception
  {
    super(min_detectable_distance, max_detectable_distance, distance_threshold, max_width, max_height, center_x, center_y, min_angle, max_angle, step_angle);
  }
  
  @Override
  protected void onNeedleStart()
  {
    super.onNeedleStart();
    super.updateData( fetchLidarData() );
  }
};