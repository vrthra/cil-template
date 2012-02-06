#include <stdio.h>
#include <ciltut.h>

struct bar {
  int r, g, b;
  int ExactRGB(r,g,b) c;
};

void foo(int LowerRGB(r,g,b) c, int r, int g, int b)
{
  return;
}

int main()
{
  struct bar B;

  B.r = 50;
  B.g = 50;
  B.b = 50;
  B.c = AddRGB(50,50,50,50);

  foo(B.c, B.r, B.g, B.b);

  return 0;
}


