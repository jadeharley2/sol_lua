

const double scaleFactor = 65530.0;
const double cp = 256.0 * 256.0;

/* packs given two floats into one float */
float pack_float(float x, float y) 
{
    int x1 = (int) (x * scaleFactor);
    int y1 = (int) (y * scaleFactor); 
    return (y1 * cp) + x1;
}

/* unpacks given float to two floats */
int unpack_float(float f, out float x, out float y)
{
  double dy = floor(f / cp);
  double dx = f - (dy * cp);
  *y = (float) (dy / scaleFactor);
  *x = (float) (dx / scaleFactor);
  return 0;
}


float pack_mask(float4 abcd, float4 efgh) 
{
    int x1 = (int) (x * scaleFactor);
    int y1 = (int) (y * scaleFactor); 
    return (y1 * cp) + x1;
}