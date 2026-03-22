
depth = 1;
tests = tag_get_assets("GPUTF8_TestSuite");
log = [ ];
active = noone;
activeName = "";

array_sort(tests, function(_lhs, _rhs)
{
  return (_lhs < _rhs) ? +1 : -1;
});