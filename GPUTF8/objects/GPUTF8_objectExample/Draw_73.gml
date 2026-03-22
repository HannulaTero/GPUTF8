/// @desc DO THE DECODING. 

if (keyboard_check_pressed(vk_up) == true)
|| (keyboard_check(vk_right) == true)
{
  // Delete previous data.
  if (buffer_exists(buffer) == true)
  {
    buffer_delete(buffer);
  }
  if (surface_exists(surface) == true)
  {
    surface_free(surface);
  }
  
  // Check whether empty string.
  if (source == "")
  {
    exit;
  }
  
  // Decode and read to GML buffer.
  // Calculate the time taken.
  var _timeSet = get_timer();
  surface = GPUTF8_DecodeStringToSurface(source);
  buffer = GPUTF8_ReadToBuffer(surface);
  var _timeEnd = get_timer();
  time = (_timeEnd - _timeSet) / 1000;
}