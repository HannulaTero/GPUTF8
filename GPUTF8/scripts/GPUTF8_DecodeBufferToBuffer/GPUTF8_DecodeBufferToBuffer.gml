

/**
* Accepts buffer which contents are UTF8 encoded string.
* -> A GML string which has been written to buffer with buffer_string or _text.
* 
* Utilizes GPU fragment shader for decoding into codepoints.
* -> This is required to be executed in Draw-event!
* 
* Returns results in a buffer, where each UTF8 Codepoint is single buffer_u32 value.
* -> Buffer ownership is given to user - handle destruction yourself.
*
* @param {Id.Buffer} _sourceBuffer
* @returns {Id.Buffer}
*/ 
function GPUTF8_DecodeBufferToBuffer(_sourceBuffer)
{
  var _outputSurface = GPUTF8_DecodeBufferToSurface(_sourceBuffer);
  var _outputBuffer = GPUTF8_ReadToBuffer(_outputSurface);
  surface_free(_outputSurface);
  return _outputBuffer;
}









