

/**
* Only reads the surface into buffer, assumes its results from decoder.
* Returns results in a new buffer, where each UTF8 Codepoint is single buffer_u32 value.
* Buffer ownership is given to user - handle destruction yourself.
*
* @param {Id.Surface} _surface
* @returns {Id.Buffer}
*/ 
function GPUTF8_ReadToBuffer(_surface)
{
  // Decode with GPU.
  var _surfaceW = surface_get_width(_surface);
  var _surfaceH = surface_get_height(_surface);
  var _surfaceCount = (_surfaceW * _surfaceH);
  
  
  // Read the results.
  var _bytes = _surfaceCount * 4;
  var _buffer = buffer_create(_bytes, buffer_grow, 1);
  buffer_get_surface(_buffer, _surface, 0);
  buffer_seek(_buffer, buffer_seek_start, 0);
  
  
  // Trim out the excess.
  // -> The last item in the buffer contains the count of characters.
  var _dtype = buffer_u32;
  var _dsize = buffer_sizeof(_dtype);
  var _offset = (_bytes - _dsize);
  var _count = buffer_peek(_buffer, _offset, _dtype);
  buffer_resize(_buffer, _count * _dsize);
  
  
  // Return the resulting buffer.
  return _buffer;
}









