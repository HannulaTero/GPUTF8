

__GPUTF8_TestSuite("UTF8 3bytes", function()
{
  // Generate string of all UTF-8 characters with 3 bytes.
  // -> There is reserved gap, hwich is skipped.
  // -> Not every character is tested, so it wouldn't take too long.
  // -> Jumping with some prime number.
  var _source = "";
  for(var i = 0x0800 + irandom(7); i < 0xD800; i += 7)
  {
    _source += chr(i);
  }
  for(var i = 0xE000 + irandom(7); i < 0x10000; i += 7)
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


instance_destroy();