

__GPUTF8_TestSuite("UTF8 4bytes", function()
{
  // Generate string of all UTF-8 characters with 4 bytes.
  // -> Test don't take every character, as it would take too long.
  // -> Jumping with some prime number.
  var _source = "";
  for(var i = 0x010000 + irandom(61); i < 0x110000; i += 61)
  {
    _source += chr(i);
  }
  
  // Decode into codepoints.
  var _buffer = GPUTF8_DecodeStringToBuffer(_source);
  
  // Compare to ground truth.
  var _success = __GPUTF8_TestSuite_Compare(_source, _buffer)
  
  // Finalize.
  buffer_delete(_buffer);
  return _success;
});

if (os_browser != browser_not_a_browser)
{
  with(GPUTF8_objectTestSuite)
  {
    array_push(log, " - HOX! HTML5 export has bug, so this is assumed to not work there.");
  }
}

instance_destroy();



