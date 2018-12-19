#include <stdio.h>
#include <math.h>

int main(int argc, char **argv) {
  int a = 1, b = 0, c = 0, d = 0, f = 0, limit;

  d = d + 2;
  d = d * d;
  d = d * 19;
  d = d * 11;
  c = c + 4;
  c = c * 22;
  c = c + 6;
  d = d + c;

  if (a == 1) {
    c = 27;
    c = c * 28;
    c = c + 29;
    c = c * 30;
    c = c * 14;
    c = c * 32;
    d = d + c;
    a = 0;
  }

  for( f = 1; f <= d; ++f ) {
    if( d % f == 0 ) { a += f; }
  }
  printf("%d\n", a);

  return 0;
}

