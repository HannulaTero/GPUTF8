# **GPUTF8**
### [GameMaker] Shader-based UTF8 character string decoder.
This asset decodes given UTF8 character string (variable-length encoding) into UTF8 codepoints (fixed-length integer), which allows constant-time access to characters.


#### Using
There are few different Decoder for different input and outputs - but they behave the same.
As this uses shaders for decoding, you need to call the functions within Draw-event.
```gml
// Decode the UTF8 characters into codepoints.
// Then you may read codepoints anywhere in constant time.
var _buffer = GPUTF8_DecodeStringToBuffer(_string);
repeat(128)
{
  var _index = irandom(string_length(_string) - 1);
  var _offset = _index * buffer_sizeof(buffer_u32);
  var _codepoint = buffer_peek(_buffer, _offset, buffer_u32);
  show_debug_message($"{_index}th codepoint was: {_codepoint}");
}

// GameMaker allows accessing codepoints directly by using string_ord_at(...)
// -> But this is O(N) time; longer the string, longer it takes to look it up.
// -> Therefore accessing codepoints with large strings it can be slow with builtin function.
repeat(128)
{
  var _index = irandom(string_length(_string) - 1);
  var _codepointB = string_ord_at(_string, _index + 1);
  show_debug_message($"{_index}th codepoint was: {_codepoint}");
}
```

#### About implementation
This doesn't use floating-point textures, which would have made implementation easier and more efficent - but should allow broader support.
As this uses rgba8unorm-surfaces instead, each pass in practice require encoding/decoding pixel information in some way or another.

After decoding UTF8 characters into codepoints, there are empty spaces between characters (if they required more than 1 byte). 
Surfaces are compactified by doing prefix scan to generate indexes, and then binary search to find correct value for output position. 
Instead of binary search, point-vertices and VTF could have been used to do in constant time, but Windows export doesn't support VTF without GMD3D11 or similary extensions. 
To keep this asset dependency-free, I decided to use binary search instead. 

Also, Shady would have been great asset to use here, which allows importing functions to shaders. Now the functions between shaders are manually copy-pasted, which is prone to errors. 

Internally GPUTF8 creates surfaces and buffers whenever required, and destroys them when not needed. So it might not be great idea to spam it constantly. 
I could have made smarter solution, but eh.


#### Here are links for testing the asset in browser:

GX/WASM export : https://gx.games/games/k1k5iv/gputf8/tracks/25c6ac58-f899-4c62-96f2-110103afca03/

HTML5 export : https://terohannula.itch.io/gputf8


### Known bugs
By time of writing, GameMaker's HTML5 export has it's unique problems, and during writing this asset I found couple of them related to buffers.
* In HTML5 buffer_write doesn't write 4-byte UTF8 characters properly - garbling those characters.
* In HTML5 buffer_poke misses some bytes with UTF8 characters, which use more than 1 byte (non-ASCII).

In practice, when using HTML5 avoid using buffer_poke with non-ASCII string, and assume emojis etc. 4-byte UTF8 characters don't work.
