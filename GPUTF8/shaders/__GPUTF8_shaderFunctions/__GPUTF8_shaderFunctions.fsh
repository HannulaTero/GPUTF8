//=============================================================
// 
#region INFORMATION.
/*
  
  This asset is only used to store the different functions,
  so they are more easily copied over.
  
  
*/
#endregion
// 
//=============================================================
// 
#region FUNCTION DECLARATIONS.


float IDiv(float lhs, float rhs);
float IMod(float lhs, float rhs);
vec2 IDivMod(float lhs, float rhs);
float Permute(vec2 size, vec2 pos);
vec2 Permute(vec2 size, float idx);
vec4 Sample(sampler2D tex, vec2 size, float idx);
float UnormToBytes(float unorm);
float BytesToUnorm(float byte);
vec4 UnormToBytes(vec4 unorm);
vec4 BytesToUnorm(vec4 bytes);
vec4 EncodeU32(float value);
float DecodeU32(vec4 unorm);
float GetComponent(vec4 value, float idx);


#endregion
// 
//=============================================================
// 
#region MAIN LOOP.


void main() { }


#endregion
// 
//=============================================================
// 
#region FUNCTION DEFINITIONS.


float IDiv(float lhs, float rhs)
{
  return floor((lhs + 0.5) / rhs);
}


float IMod(float lhs, float rhs)
{
  return (lhs - IDiv(lhs, rhs) * rhs);
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


float BytesToUnorm(float bytes)
{
  return (bytes / 255.0);
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