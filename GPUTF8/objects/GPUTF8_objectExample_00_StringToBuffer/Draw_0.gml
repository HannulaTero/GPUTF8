/// @desc DECODING.
/*
  As decoder uses shaders, it should always use Draw-event.
*/ 


// Have some UTF8 string.
var _string = @'
  ABCD%&()*+,-./01234
  ȝȞȟȠȡȢȣȤȥȦഅആഇ
  ഈሚማමේምሞሟ፦
  引领耀੯ੰੱੲੳੴੵ
';


// Decode the UTF8 characters into codepoints.
var _buffer = GPUTF8_DecodeStringToBuffer(_string);


// Now you may read codepoints anywhere in constant time.
// -> Remember it is 0 indexed.
var _offset = 30 * buffer_sizeof(buffer_u32);
var _codepoint = buffer_peek(_buffer, _offset, buffer_u32);
show_debug_message($"31th codepoint was : {_codepoint}");


// Of course you could use "string_ord_at(...)"
// -> BUT this is O(N) time, non-constant time.
// -> So longer the string, and further you look up,
//    slower it will be.
// -> With small string this is not a problem,
//    But when iterating through long string, it will get slow.
var _codepointB = string_ord_at(_string, 31);


// Cleanup
buffer_delete(_buffer);



