

__GPUTF8_TestSuite("CPU vs GPU", function()
{
  // Generate string of UTF-8 characters.
  var _source = "";
  repeat(256)
  {
    var _codepoint = choose(true, false)
      ? irandom_range(0x0000, 0xD7FF)
      : irandom_range(0xE000, 0x10FFFF);
    _source += chr(_codepoint);
  }
  
  
  // Check CPU decode time.
  var _timeCPU = __GPUTF8_TestSuite_Timing(method({ source : _source }, function()
  {
    var _source = source;
    var _length = string_length(_source);
    var _dummy = 0;
    repeat(_length)
    {
      _dummy = string_ord_at(_source, 1);
      _source = string_delete(_source, 1, 1); // Faster to iterate this way
    }
  }));
  
  
  // Check GPU decode time.
  var _timeGPU = __GPUTF8_TestSuite_Timing(method({ source : _source }, function()
  {
    buffer_delete(GPUTF8_DecodeStringToBuffer(source));
  }));
  
  
  // Print out the times.
  with(GPUTF8_objectTestSuite)
  {
    array_push(log, $" - Decoding 256 characters:");
    array_push(log, $" - CPU time : {_timeCPU} ms");
    array_push(log, $" - GPU time : {_timeGPU} ms");
  }
  
  // Finalize.
  return true;
});


instance_destroy();