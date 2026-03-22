

__GPUTF8_TestSuite("ASCII", function()
{
  // Generate string of all ASCII characters.
  var _source = "";
  for(var i = 0x0000; i < 0x0080; i++)
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