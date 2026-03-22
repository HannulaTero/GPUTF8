

/**
* Updating global test success.
*/
function __GPUTF8_TestSuite(_name, _function)
{
  with(GPUTF8_objectTestSuite)
  {
    array_push(log, $"[{_name}]");
    array_push(log, $" - Starting test.");
    var _success = _function();
    var _message = _success ? "SUCCESS" : "FAILURE";
    array_push(log, $" - {(_message)}");
  }
}



/**
* Compares string and buffer codepoints to each other.
*/ 
function __GPUTF8_TestSuite_Compare(_string, _buffer)
{
  var _errors = 0;
  var _count = string_length(_string);
  for(var i = 0; i < _count; i++)
  {
    var _lhs = string_ord_at(_string, i + 1);
    var _rhs = buffer_peek(_buffer, i * 4, buffer_u32);
    if (_lhs != _rhs)
    {
      _errors += 1;
    }
  }
  
  with(GPUTF8_objectTestSuite)
  {
    array_push(log, $" - errors : {_errors} / {_count}");
  }
  return (_errors == 0);
}



/**
* For timing the how long execution took.
*/ 
function __GPUTF8_TestSuite_Timing(_function)
{
  var _timeSet = get_timer();
  _function();
  var _timeEnd = get_timer();
  return (_timeEnd - _timeSet) / 1000;
};