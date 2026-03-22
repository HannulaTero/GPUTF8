//=============================================================
// 
#region INFORMATION.
/*
  
  Output of this inclusive prefix sum of values.
  Inputs are encoded U32 values from previous passes.
  
  This implements naive Hillis-Steele Prefix Scan algorithm.
  As the rendering pipeline can't do "in-place" updates,
  results are "ping-ponged". This does mean previous results 
  need to be copied over, even though they are not changing.
  
  Inputs are expected to be in row-major order within texture.
  
  Input and output are expected to be rgba8unorm.
  
  Input   : Single pixel stores [ rgba : U32 ].
  Output  : Single pixel stores [ r: flag, gba: codepoint ].
  
*/
#endregion
// 
//=============================================================
// 
#region QUALIFIERS & UNIFORMS.


// Qualifiers.
precision highp sampler2D;
precision highp float;
precision highp int;

// Uniforms.
#define FSH_sourceSampler gm_BaseTexture
uniform vec2 FSH_outputSize;
uniform vec2 FSH_sourceSize;
uniform float FSH_jump;


#endregion
// 
//=============================================================
// 
#region FUNCTION DECLARATIONS.


float IDiv(float lhs, float rhs);
vec2 IDivMod(float lhs, float rhs);
float Permute(vec2 size, vec2 pos);
vec2 Permute(vec2 size, float idx);
vec4 Sample(sampler2D tex, vec2 size, float idx);
vec4 UnormToBytes(vec4 unorm);
vec4 BytesToUnorm(vec4 bytes);
vec4 EncodeU32(float value);
float DecodeU32(vec4 unorm);


#endregion
// 
//=============================================================
// 
#region MAIN LOOP.


void main()
{
  // Get the current output index.
  vec2 outputPos = floor(gl_FragCoord.xy);
  float outputIdx = Permute(FSH_outputSize, outputPos);
  
  // Get the input value from source.
  float rhsIdx = outputIdx;
  vec4 rhsSample = Sample(FSH_sourceSampler, FSH_sourceSize, rhsIdx);

  // Check whether value is just "copy-over".
  // -> No need to decode etc.
  if (rhsIdx < FSH_jump)
  {
    gl_FragData[0] = rhsSample;
    return;
  }
  
  // Get the input value from source.
  float lhsIdx = (rhsIdx - FSH_jump);
  vec4 lhsSample = Sample(FSH_sourceSampler, FSH_sourceSize, lhsIdx);
  
  // Decode both and sum together.
  float lhsValue = DecodeU32(lhsSample);
  float rhsValue = DecodeU32(rhsSample);
  float summation = (lhsValue + rhsValue);
  
  // Encode the resulting U32 value and store it.
  gl_FragData[0] = EncodeU32(summation);
}


#endregion
// 
//=============================================================
// 
#region FUNCTION DEFINITIONS.


float IDiv(float lhs, float rhs)
{
  return floor((lhs + 0.5) / rhs);
}


vec2 IDivMod(float lhs, float rhs)
{
  vec2 dst;
  dst.x = IDiv(lhs, rhs);
  dst.y = (lhs - dst.x * rhs);
  return dst;
}


float Permute(vec2 size, vec2 pos)
{
  return (pos.x + pos.y * size.x);
}


vec2 Permute(vec2 size, float idx)
{
  vec2 pos;
  pos.y = IDiv(idx, size.x);
  pos.x = (idx - pos.y * size.x);
  return pos;
}


vec4 Sample(sampler2D tex, vec2 size, float idx)
{
  vec2 pos = Permute(size, idx);
  return texture2D(tex, (pos + 0.5) / size);
}


vec4 UnormToBytes(vec4 unorm)
{
  return floor(unorm * 255.0 + 0.5);
}


vec4 BytesToUnorm(vec4 bytes)
{
  return (bytes / 255.0);
}


vec4 EncodeU32(float value)
{
  vec4 pack; 
  vec2 divmod;
  divmod = IDivMod(value, 256.0);     pack.r = divmod.y;
  divmod = IDivMod(divmod.x, 256.0);  pack.g = divmod.y;
  divmod = IDivMod(divmod.x, 256.0);  pack.ba = divmod.yx;
  return BytesToUnorm(pack);
}


float DecodeU32(vec4 unorm)
{
  return dot(UnormToBytes(unorm), vec4(1.0, 256.0, 65536.0, 16777216.0));
}


#endregion
// 
//=============================================================