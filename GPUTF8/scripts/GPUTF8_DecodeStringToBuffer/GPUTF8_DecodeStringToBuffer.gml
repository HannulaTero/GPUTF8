

/**
* Accepts GML string, which can contain other than ASCII characters.
* 
* Utilizes GPU fragment shader for decoding into codepoints.
* -> This is required to be executed in Draw-event!
* 
* Returns results in a buffer, where each UTF8 Codepoint is single buffer_u32 value.
* -> Buffer ownership is given to user - handle destruction yourself.
*
* @param {String} _sourceString
* @returns {Id.Buffer}
*/ 
function GPUTF8_DecodeStringToBuffer(_sourceString)
{
  var _outputSurface = GPUTF8_DecodeStringToSurface(_sourceString);
  var _outputBuffer = GPUTF8_ReadToBuffer(_outputSurface);
  surface_free(_outputSurface);
  return _outputBuffer;
}









