

/**
* 
* Accepts GML string, which can contain other than ASCII characters.
* 
* Utilizes GPU fragment shader for decoding into codepoints.
* -> This is required to be executed in Draw-event!
*
* Returns results in surface. 
* -> This is not trimmed, so it might contain padding.
* -> Last pixel (bottom-right) contains encoded U32 of total character count.
*
* The results are U32 encoded in rgba8unorm surface format.
* -> If read to buffer, they should be readable straight away with buffer_u32.
* -> Surface ownership is given to user - handle destruction yourself.
*
* @param {String} _sourceString
* @returns {Id.Surface}
*/ 
function GPUTF8_DecodeStringToSurface(_sourceString)
{
  // Get source information.
  // -> Calculates how many bytes surface would require.
  // -> So correct size can be applied directly.
  var _sourceStringLength = string_byte_length(_sourceString);
  var _sourceSurfaceCount = ceil(_sourceStringLength / 4);
  var _sourceSurfaceW = GPUTF8_GetWidth(_sourceSurfaceCount);
  var _sourceSurfaceH = GPUTF8_GetHeight(_sourceSurfaceCount);
  var _sourceSurfaceBytes = (_sourceSurfaceW * _sourceSurfaceH * 4);
  
  // Push source string into buffer.
  var _sourceBuffer = buffer_create(_sourceSurfaceBytes, buffer_grow, 1);
  buffer_seek(_sourceBuffer, buffer_seek_start, 0);
  buffer_write(_sourceBuffer, buffer_text, _sourceString);
  
  // Decode in GPU.
  var _outputSurface = GPUTF8_DecodeBufferToSurface(_sourceBuffer);
  buffer_delete(_sourceBuffer);
  return _outputSurface;
}









