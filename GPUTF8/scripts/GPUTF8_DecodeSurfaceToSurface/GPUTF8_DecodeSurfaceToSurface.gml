

/**
* The main meat of the decoder.
* 
* Utilizes GPU fragment shader for decoding UTF8 encoded strings into UTF8 codepoints.
*
* This is required to be executed in Draw-event!
* 
* Accepts surface, which should contain UTF8 character bytes.
* -> Buffer where GML string is written, and moved directly to surface.
*
* Returns results in surface. 
* -> This is not trimmed, so it might contain padding.
* -> Last pixel (bottom-right) contains encoded U32 of total character count.
*
* The results are U32 encoded in rgba8unorm surface format.
* -> If read to buffer, they should be readable straight away with buffer_u32.
*
* @param {Id.Surface} _sourceSurface
* @param {Real} _itemCount
* @returns {Id.Surface}
*/ 
function GPUTF8_DecodeSurfaceToSurface(_sourceSurface, _itemCount=undefined)
{
  // Preparations.
  gpu_push_state();
  gpu_set_state(GPUTF8_GetGPUState());
  var _depthDisabled = surface_get_depth_disable();
  surface_depth_disable(false);
  
  
  // Get source information.
  var _sourceSurfaceW = surface_get_width(_sourceSurface);
  var _sourceSurfaceH = surface_get_height(_sourceSurface);
  _itemCount ??= (_sourceSurfaceW * _sourceSurfaceH * 4);
  
  
  // Spread the components, so each pixel only has single byte.
  // Afterwards the original bytes are not needed anymore, and can be freed.
  // The one pixel is added, so in the end there is room for count.
  var _spreadCount = (_itemCount + 1);
  var _spreadSurfW = GPUTF8_GetWidth(_spreadCount);
  var _spreadSurfH = GPUTF8_GetHeight(_spreadCount);
  var _spreadSurf = surface_create(_spreadSurfW, _spreadSurfH);
  {
    var _shader = GPUTF8_shaderSpread;
    shader_set(_shader);
    shader_set_uniform_f(shader_get_uniform(_shader, "FSH_outputSize"), _spreadSurfW, _spreadSurfH);
    shader_set_uniform_f(shader_get_uniform(_shader, "FSH_sourceSize"), _sourceSurfaceW, _sourceSurfaceH);
    shader_set_uniform_f(shader_get_uniform(_shader, "FSH_maxCount"), _itemCount);
    surface_set_target(_spreadSurf);
    draw_surface_stretched(_sourceSurface, 0, 0, _spreadSurfW, _spreadSurfH);
    surface_reset_target();
    shader_reset();
  }
  
  
  // Decode the UTF-8 characters into codepoints.
  // -> Each pixel is flagged whether it's codepoint or not, and contains information..
  // -> So there are empty spaces in-between, we need to be compactified.
  var _decodedSurfW = _spreadSurfW;
  var _decodedSurfH = _spreadSurfH;
  var _decodedSurf = surface_create(_decodedSurfW, _decodedSurfH);
  {
    var _shader = GPUTF8_shaderDecode;
    shader_set(_shader);
    shader_set_uniform_f(shader_get_uniform(_shader, "FSH_outputSize"), _decodedSurfW, _decodedSurfH);
    shader_set_uniform_f(shader_get_uniform(_shader, "FSH_sourceSize"), _spreadSurfW, _spreadSurfH);
    surface_set_target(_decodedSurf);
    draw_surface_stretched(_spreadSurf, 0, 0, _decodedSurfW, _decodedSurfH);
    surface_reset_target();
    shader_reset();
  }
  
  
  // Get seed values for prefix sum.
  // -> These are U32 values 0 or 1, which can be counted together.
  // -> Reuses spread-surface for other ping-pong target.
  var _scanSurfW = _spreadSurfW;
  var _scanSurfH = _spreadSurfH;
  var _scanPingSurf = _spreadSurf;
  var _scanPongSurf = surface_create(_scanSurfW, _scanSurfH);
  var _scanTempSurf = undefined;
  {
    var _shader = GPUTF8_shaderSeed;
    shader_set(_shader);
    shader_set_uniform_f(shader_get_uniform(_shader, "FSH_outputSize"), _scanSurfW, _scanSurfH);
    shader_set_uniform_f(shader_get_uniform(_shader, "FSH_sourceSize"), _decodedSurfW, _decodedSurfH);
    surface_set_target(_scanPingSurf);
    draw_surface_stretched(_decodedSurf, 0, 0, _scanSurfW, _scanSurfH);
    surface_reset_target();
    shader_reset();
  }
  
  
  // Now apply the Prefix scan to generate indexing.
  // -> Uses naive Hillis-Steel algorithm, which is work-inefficient.
  // -> This could be slighlty optimized, as everything don't need to be copied over.
  // -> But better would be Blelloch, which is harder (not impossible) to implement with fragment shaders.
  // -> Though Blelloch will require power-of-two size (padding atleast) which Hillis-Steel doesn't require.
  // -> This implementation doesn't use PoT, so that would need to be updated (thouhg not big problem).
  {
    var _shader = GPUTF8_shaderScan;
    shader_set(_shader);
    shader_set_uniform_f(shader_get_uniform(_shader, "FSH_outputSize"), _scanSurfW, _scanSurfH);
    shader_set_uniform_f(shader_get_uniform(_shader, "FSH_sourceSize"), _scanSurfW, _scanSurfH);
    var _FSH_jump = shader_get_uniform(_shader, "FSH_jump");
    var _scanItemCount = (_scanSurfW * _scanSurfH);
    for(var i = 1; i < _scanItemCount; i *= 2)
    {
      shader_set_uniform_f(_FSH_jump, i);
      surface_set_target(_scanPongSurf);
      draw_surface_stretched(_scanPingSurf, 0, 0, _scanSurfW, _scanSurfH);
      surface_reset_target();
    
      // Swap source and output.
      _scanTempSurf = _scanPingSurf;
      _scanPingSurf = _scanPongSurf;
      _scanPongSurf = _scanTempSurf;
    }
    shader_reset();
  }
  
  
  // Compactify the codepoints based on the prefix sum results (practically indexes).
  // -> Reuses scan ping-pong targets.
  var _compactSurfW = _scanSurfW;
  var _compactSurfH = _scanSurfH;
  var _compactItemCount = (_compactSurfW * _compactSurfH);
  var _compactSurf = _scanPongSurf;
  var _scanSurf = _scanPingSurf;
  {
    var _shader = GPUTF8_shaderCompact;
    shader_set(_shader);
    shader_set_uniform_f(shader_get_uniform(_shader, "FSH_outputSize"), _compactSurfW, _compactSurfH);
    shader_set_uniform_f(shader_get_uniform(_shader, "FSH_sourceSize"), _decodedSurfW, _decodedSurfH);
    shader_set_uniform_f(shader_get_uniform(_shader, "FSH_prefixSize"), _scanSurfW, _scanSurfH);
    shader_set_uniform_f(shader_get_uniform(_shader, "FSH_maxCount"), _compactItemCount);
    texture_set_stage(shader_get_sampler_index(_shader, "FSH_prefixSampler"), surface_get_texture(_scanSurf));
    surface_set_target(_compactSurf);
    draw_surface_stretched(_decodedSurf, 0, 0, _compactSurfW, _compactSurfH);
    surface_reset_target();
    shader_reset();
  }
  
  
  // Finalization.
  // -> Return back the settings.
  // -> Free the surfaces.
  surface_free(_decodedSurf);
  surface_free(_scanSurf);
  gpu_pop_state();
  surface_depth_disable(_depthDisabled);
  
  
  // Return the resulting surface.
  return _compactSurf;
}









