

/**
* 
* Accepts surface, which should contain UTF8 character bytes.
* -> Buffer where GML string is written, and moved directly to surface.
* 
* Utilizes GPU fragment shader for decoding into codepoints.
* -> This is required to be executed in Draw-event!
* 
* Returns results in a buffer, where each UTF8 Codepoint is single buffer_u32 value.
* -> Buffer ownership is given to user - handle destruction yourself.
*
* @param {Id.Surface} _sourceSurface
* @param {Real} _itemCount
* @returns {Id.Surface}
*/ 
function GPUTF8_DecodeSurfaceToBuffer(_sourceSurface, _itemCount=undefined)
{
  var _outputSurface = GPUTF8_DecodeSurfaceToSurface(_sourceSurface, _itemCount);
  var _outputBuffer = GPUTF8_ReadToBuffer(_outputSurface);
  surface_free(_outputSurface);
  return _outputBuffer;
}









