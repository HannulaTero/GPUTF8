/// @desc CLEANUP.

if (buffer_exists(buffer) == true)
{
  buffer_delete(buffer);
}
if (surface_exists(surface) == true)
{
  surface_free(surface);
}