


__GPUTF8_TestSuite("Compiled", function()
{
  var _functor = function(_prev, _shader)
  {
    var _compiled = shader_is_compiled(_shader);
    show_debug_message($"[{_compiled}] {_shader}");
    return _prev && _compiled;
  };
  
  return array_reduce([
    __GPUTF8_shaderFunctions,
    GPUTF8_shaderCompact,
    GPUTF8_shaderDecode,
    GPUTF8_shaderScan,
    GPUTF8_shaderSeed,
    GPUTF8_shaderSpread
  ], _functor, true);
});


instance_destroy();