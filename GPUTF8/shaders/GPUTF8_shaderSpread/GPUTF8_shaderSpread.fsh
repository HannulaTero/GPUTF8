//=============================================================
// 
#region INFORMATION.
/*
  
  This shader is used to spread thightly packed UTF-8 string
  into separate pixels, so decoding codepoint is easier.
  It does mean output only uses single component, 
  and rest of the components are just padding.
  
  The spread is done in row-major order.
  
  Input and output are expected to be rgba8unorm.
  Output texture should contain 4x more pixels than input.
  
  Input   : Single pixel stores 4 bytes of UTF-8.
  Output  : Single pixel stores 1 byte of UTF-8
  
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
uniform float FSH_maxCount;


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
float GetComponent(vec4 value, float idx);


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
  
  // Check whether outside the byte-range.
  // -> Mark by continuation byte "0b10xx_xxxx" 
  // -> here it's: "0b1000_0000", which is 128
  if (outputIdx >= FSH_maxCount)
  {
    gl_FragData[0] = BytesToUnorm(vec4(128.0));
    return;
  }
  
  // Get the input value from source.
  // -> The inputs are packed more tighly, 4 values in single pixel.
  // -> The source index will contain both pixel and component index.
  vec2 sourceIdx = IDivMod(outputIdx, 4.0);
  vec4 sourceSample = Sample(FSH_sourceSampler, FSH_sourceSize, sourceIdx.x);
  
  // Select single component and store it.
  // -> No need to decode it, as it is not modified.
  float extractedValue = GetComponent(sourceSample, sourceIdx.y);
  
  // Store the results. 
  // -> Single component is used, repeated to all components for padding.
  // 
  // vec4 debug = BytesToUnorm(vec4(sourceIdx.x, sourceIdx.y, outputIdx, 0.0));
  // gl_FragData[0] = vec4(extractedValue, debug.rgb);
  gl_FragData[0] = vec4(extractedValue); 
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


float GetComponent(vec4 value, float idx)
{
  // Handling HTML5 export (WebGL1).
  // -> WebGL1 doesn't like dynamic array indexing, so this is done WebGL1 friendly way.
  #ifdef _YY_GLSLES_
  
    if (idx == 0.0) return value.r;
    if (idx == 1.0) return value.g;
    if (idx == 2.0) return value.b;
    return value.a;
    
  // Everything else.
  #else 
  
    return value[int(idx)];
    
  #endif
}


#endregion
// 
//=============================================================