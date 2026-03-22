
draw_set_font(GPUTF8_font);
draw_set_halign(fa_left);
draw_set_valign(fa_top);

draw_text(32, 32, $"test : {activeName}");


array_foreach(log, function(_log, _index)
{
  draw_text_transformed(64, 64 + _index * 12, _log, 0.75, 0.75 ,0.0); 
});