/// @desc INPUTS - PASTING TEXT etc.

if (keyboard_check(vk_control) == true)
{
  if (keyboard_check_pressed(ord("V")) == true)
  && (clipboard_has_text() == true)
  {
    source = clipboard_get_text();
  }
}


if (keyboard_check_pressed(vk_down) == true)
{
  room_goto(GPUTF8_roomTestSuite);
}


if (keyboard_check_pressed(vk_delete) == true)
{
  source = "";
  
  // Delete previous data.
  if (buffer_exists(buffer) == true)
  {
    buffer_delete(buffer);
  }
  if (surface_exists(surface) == true)
  {
    surface_free(surface);
  }
}