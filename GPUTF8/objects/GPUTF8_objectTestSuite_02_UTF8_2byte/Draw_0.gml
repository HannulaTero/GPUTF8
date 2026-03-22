

__GPUTF8_TestSuite("UTF8 2bytes", function()
{
  // Generate string of all UTF-8 characters with 2 bytes.
  var _source = "";
  for(var i = 0x0080; i < 0x0800; i++)
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