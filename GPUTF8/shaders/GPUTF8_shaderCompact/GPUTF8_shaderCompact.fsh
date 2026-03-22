//=============================================================
// 
#region INFORMATION.
/*
  
  Shader uses results of prefix sum to find correct position from the source.
  -> The last item stores the total amount of codepoints.
  -> Assumes results as inclusive prefix sum.
  
  With prefix sum of 0|1 seed values will generate compactified indexing for 1-seed positions.
  -> This is utilized for finding the correct value.
  -> As it is inclusive, the search index need to include extra 1.
  -> For example [ 1, 0, 0, 1, 0, 1, 1, 0 ] has inclusive prefix sum [ 1, 1, 1, 2, 2, 3, 4, 4 ]
  -> By reducing by one, we get indexes for each item: [ 0, 0, 0, 1, 1, 2, 3, 3 ]
  -> But only 1-seed items use the indexes, so there are no overlapping.
  -> In practice, adding 1 to search value is same as subtracting 1 from prefix value. 
  
  This uses binary search for finding the position, so its O(log(N)) per pixel.
  -> If Vertex shader (points) and VTF could be used, then this could be done in O(1).
  
  Inputs are expected to be in row-major order within texture.
  Inputs and output are expected to be rgba8unorm.
  
  Source  : Single pixel stores [ rgba : codepoint ].
  prefix  : Single pixel stores [ rgba : prefix sum ].
  Output  : Single pixel stores [ rgba : codepoint ]. 
  Output  : EXPECTION last item [ rgba : count of codepoints ].
  
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
uniform sampler2D FSH_prefixSampler;
uniform vec2 FSH_outputSize;
uniform vec2 FSH_sourceSize;
uniform vec2 FSH_prefixSize;
uniform float FSH_maxCount;


#endregion
// 
//=============================================================
// 
#region FUNCTION DECLARATIONS.


float IDiv(float lhs, float rhs);
float Permute(vec2 size, vec2 pos);
vec2 Permute(vec2 size, float idx);
vec4 Sample(sampler2D tex, vec2 size, float idx);
vec4 UnormToBytes(vec4 unorm);
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
  float upper = FSH_maxCount;
  float lower = 0.0;
  
  
  // Whether it is last item, it stores the count of codepoints.
  // -> The last item of prefix sum contains sum of all seed values
  // -> which is the sum of sum of codepoints.
  if (outputIdx == FSH_maxCount - 1.0)
  {
    vec4 unormCount = Sample(FSH_prefixSampler, FSH_prefixSize, FSH_maxCount - 1.0);
    gl_FragData[0] = unormCount;
    return;
  }
  
  
  // Do the binary search.
  // -> Tries to find output-index from prefix sums.
  // -> The condition is separated for WebGL1 (can't use dynamic iterator).
  // -> Added 1 to search value is same as subtracting 1 from prefix value. 
  float searchValue = outputIdx + 1.0;
  for(float i = 0.0; i <= 24.0; i++)
  {
    if (lower >= upper) break;
    
    // Find the middle point. 
    // Calculated in a way to avoid index overflow.
    float middle = lower + IDiv(upper - lower, 2.0);
    
    // Get the comparison value.
    // -> Prefix sum is assumed inclusive (all seed values were 0 or 1).
    // -> Normally you would remove 1 to get exclusive, which would be the index.
    // -> But as first spot is reserved codepoint-count, the prefix scan result can be directly used
    vec4 unorm = Sample(FSH_prefixSampler, FSH_prefixSize, middle);
    float prefixValue = DecodeU32(unorm);
    
    // Update the limits.
    if (prefixValue < searchValue)
    {
      lower = middle + 1.0;
    }
    else
    {
      upper = middle;
    }
  }
  
  
  // Get the item from the lower bound.
  // -> Binary search lower bound should contain left-most item (if repeating same index).
  // -> The prefix is one-to-one mapping with source, so index can be used directly.
  gl_FragData[0] = Sample(FSH_sourceSampler, FSH_sourceSize, lower);
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


float DecodeU32(vec4 unorm)
{
  return dot(UnormToBytes(unorm), vec4(1.0, 256.0, 65536.0, 16777216.0));
}


#endregion
// 
//=============================================================