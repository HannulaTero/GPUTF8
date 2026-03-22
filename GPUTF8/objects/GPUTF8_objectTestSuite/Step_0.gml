

if (instance_exists(active) == false)
&& (array_length(tests) > 0)
{
  activeName = array_pop(tests);
  var _testObject = asset_get_index(activeName);
  active = instance_create_depth(0, 0, 0, _testObject);
}

if (instance_exists(active) == false)
&& (array_length(tests) == 0)
{
  activeName = "Press ENTER to return examples."
  if (keyboard_check_pressed(vk_enter) == true)
  {
    instance_destroy();
    room_goto(GPUTF8_roomExample);
  }
}