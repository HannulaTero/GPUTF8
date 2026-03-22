//=============================================================
// 
#region INFORMATION.
/*
  
  Output of this shader are flagged UTF-8 codepoints.
  This shader determines whether given byte is start of encoded UTF-8 character, or just a continuation byte.
  
  Single codepoint requires 21bits, so three color components is enough (24bits).
  Fourth color component is used to flag whether it contains codepoint or not.
    Flag 0 : Contains codepoint
    Flag 1 : Doesn't contain codepoint.
  Basically how U32 is encoded, Alpha-channel contains the flag.
  -> If read as U32, values 16777216 or larger are not codepoints.
  
  Inputs are expected to be in row-major order within texture.
  
  Input and output are expected to be rgba8unorm.
  
  Input   : Single pixel stores [ r : UTF-8 byte, gba : padding ].
  Output  : Single pixel stores [ rgba : U32 codepoint ]
  
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
float UnormToBytes(float unorm);
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
  vec4 bytes = vec4(0.0);
  
  // Get the input value from source.
  float sourceIdx = outputIdx;
  vec4 sourceSample = Sample(FSH_sourceSampler, FSH_sourceSize, sourceIdx);
  bytes[0] = UnormToBytes(sourceSample.r);

  // Resolve whether is starting byte for UTF8.
  // -> Done by check wether it is NOT continuation byte "0b10xx_xxxx"
  float flag = float(
    (bytes[0] <= 127.0) || 
    (bytes[0] >= 192.0)
  );
  
  // If continuation byte, flag as such, no need to read more bytes.
  // -> Doesn't store codepoint, only flag.
  if (flag == 0.0)
  {
    gl_FragData[0] = vec4(0.0, 0.0, 0.0, 1.0);
    return;
  }
  
  // Read the required bytes.
  // -> The UTF8 uses variable-length encoding.
  // -> Read required bytes.
  if (bytes[0] >= 192.0) 
  {
    sourceSample = Sample(FSH_sourceSampler, FSH_sourceSize, sourceIdx + 1.0);
    bytes[1] = UnormToBytes(sourceSample.r);
  }
  
  if (bytes[0] >= 224.0)
  {
    sourceSample = Sample(FSH_sourceSampler, FSH_sourceSize, sourceIdx + 2.0);
    bytes[2] = UnormToBytes(sourceSample.r);
  }
  
  if (bytes[0] >= 240.0)
  {
    sourceSample = Sample(FSH_sourceSampler, FSH_sourceSize, sourceIdx + 3.0);
    bytes[3] = UnormToBytes(sourceSample.r);
  }
  
  
  // Decode the UTF-8 codepoint.
  // -> This would be easier with bit-operations.
  // -> Assumes valid codepoint.
  float codepoint;
  if (bytes[0] < 128.0)
  {
    codepoint = bytes[0];
  }
  else if (bytes[0] < 224.0)
  {
    codepoint = (
      (bytes[0] - 192.0) * 64.0 + 
      (bytes[1] - 128.0)
    );
  }
  else if (bytes[0] < 240.0)
  {
    codepoint = (
      (bytes[0] - 224.0) * 4096.0 + 
      (bytes[1] - 128.0) * 64.0 + 
      (bytes[2] - 128.0)
    );
  }
  else
  {
    codepoint = (
      (bytes[0] - 240.0) * 262144.0 + 
      (bytes[1] - 128.0) * 4096.0 + 
      (bytes[2] - 128.0) * 64.0 + 
      (bytes[3] - 128.0)
    );
  }
  
  
  // Store the flag and UTF-8 code-point value.
  // -> U32 encoded codepoint values shouldn't ever touch Alpha-component, so it should be 0.
  gl_FragData[0] = EncodeU32(codepoint);
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


float UnormToBytes(float unorm)
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


#endregion
// 
//=============================================================