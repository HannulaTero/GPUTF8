//=============================================================
// 
#region INFORMATION.
/*
  
  Output of this shader are seed values for counting (0 or 1).
  
  Inputs are expected to be in row-major order within texture.
  
  Input and output size are expected to be powers of two.
  Input and output are expected to be rgba8unorm.
  
  Input   : Single pixel stores [ r: flag, gba: codepoint ].
  Output  : Single pixel stores [ rgba : U32 ].
  
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
vec4 BytesToUnorm(vec4 bytes);
vec4 EncodeU32(float value);


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
  float sourceIdx = outputIdx;
  vec4 sourceSample = Sample(FSH_sourceSampler, FSH_sourceSize, sourceIdx);
  
  // Seed value is 0 or 1 as U32, determined whether flagged or not.
  // -> Alpha 1 tells it's flagged as "non-codepoint"
  // -> Alpha 0 tells it contains codepoint.
  gl_FragData[0] = EncodeU32(float(sourceSample.a < 0.5));
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


#endregion
// 
//=============================================================