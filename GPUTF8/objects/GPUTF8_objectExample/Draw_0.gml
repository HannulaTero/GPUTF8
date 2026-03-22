/// @desc PRINTING THE INFORMATION 

draw_set_font(GPUTF8_font);
draw_set_halign(fa_left);


// General information.
draw_text(32, 16, "Uses shaders for decoding variable-length UTF-8 encoding into codepoints.");
draw_text(32, 40, "Press UP to decode string to UTF-8 codepoints once (RIGHT to repeatly).");
draw_text(32, 64, "Press DOWN to run Test Suite.");
draw_text(32, 88, "Ctrl+V to pase text for testing. Press DELETE to remove it.");
draw_text(32, 112, (os_browser != browser_not_a_browser)
  ? "  (in HTML5 there is engine-bug with 4 byte UTF8 characters)"
  : ""
);

draw_text(32, 160, $"Last decoding took : {time} ms");
draw_text(32, 184, $" -> Only times the generating of fixed-length codepoint buffer.");


// Current source text.
draw_text(32, 240, $"TEXT :");
draw_text_transformed(48, 264, source, 0.66, 0.66, 0.0);


// Visualize moving something on corner.
{
  var _x = room_width - 32;
  var _y = 32;
  _x += lengthdir_x(8, current_time / 3);
  _y += lengthdir_y(8, current_time / 3);
  draw_circle(_x, _y, 16, false);
}


// Print buffer contents.
if (buffer_exists(buffer) == true)
{
  buffer_seek(buffer, buffer_seek_start, 0);
  var _bytes = buffer_get_size(buffer);
  var _x = 800;
  var _y = 64;
  draw_set_halign(fa_left);
  draw_text(_x, _y - 32, "CODEPOINTS");
  draw_set_halign(fa_right);
  while(buffer_tell(buffer) < _bytes)
  {
    draw_text(_x, _y, buffer_read(buffer, buffer_u32));
    _y += 16;
    if (_y > room_height - 64)
    {
      _x += 48;
      _y = 64;
      if (_x > room_width - 64)
      {
        break;
      }
    }
  }
}


// Print surface contents.
if (surface_exists(surface) == true)
{
  var _surfW = surface_get_width(surface);
  var _surfH = surface_get_height(surface);
  var _w = 256;
  var _h = 256 * (_surfH / _surfW);
  var _x = 16;
  var _y = room_height - 16 - _h;
  gpu_push_state();
  gpu_set_blendmode_ext_sepalpha(bm_one, bm_zero, bm_zero, bm_one);
  draw_surface_stretched(surface, _x, _y, _w, _h);
  gpu_pop_state();
}



