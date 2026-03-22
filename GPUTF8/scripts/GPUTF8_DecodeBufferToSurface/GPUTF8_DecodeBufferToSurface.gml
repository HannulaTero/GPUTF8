

/**
* 
* Utilizes GPU fragment shader for decoding codepoints.
* This is required to be executed in Draw-event!
* 
* Returns results in surface. 
* -> This is not trimmed, so it might contain padding.
* -> Last pixel (bottom-right) contains encoded U32 of total character count.
*
* The results are U32 encoded in rgba8unorm surface format.
* -> If read to buffer, they should be readable straight away with buffer_u32.
* -> Surface ownership is given to user - handle destruction yourself.
*
* @param {Id.Buffer} _sourceBuffer
* @returns {Id.Surface}
*/ 
function GPUTF8_DecodeBufferToSurface(_sourceBuffer)
{
  // Preparations.
  var _depthDisabled = surface_get_depth_disable();
  var _sourceLength = buffer_get_size(_sourceBuffer);
  surface_depth_disable(false);
  
  
  // Get source information.
  var _sourceSurfaceCount = ceil(_sourceLength / 4);
  var _sourceSurfaceW = GPUTF8_GetWidth(_sourceSurfaceCount);
  var _sourceSurfaceH = GPUTF8_GetHeight(_sourceSurfaceCount);
  var _sourceSurfaceBytes = (_sourceSurfaceW *_sourceSurfaceH * 4);
  var _sourceSurface = surface_create(_sourceSurfaceW, _sourceSurfaceH);
  
  
  // Buffer needs to be as large or larger than surface.
  // -> Otherwise buffer_set_surface would fail.
  // -> So buffer is resized temporarily if it is smaller.
  if (_sourceLength < _sourceSurfaceBytes)
  {
    buffer_resize(_sourceBuffer, _sourceSurfaceBytes);
    buffer_set_surface(_sourceBuffer, _sourceSurface, 0);
    buffer_resize(_sourceBuffer, _sourceLength);
  }
  else
  {
    buffer_set_surface(_sourceBuffer, _sourceSurface, 0);
  }
  
  
  // Get the results and finalization.
  var _outputSurface = GPUTF8_DecodeSurfaceToSurface(_sourceSurface, _sourceLength);
  surface_depth_disable(_depthDisabled);
  surface_free(_sourceSurface);
  return _outputSurface;
}









