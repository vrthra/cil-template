//@highlight \section{\texttt{test/tut3.c}}
//@highlight \hltscom{The result of the analysis in \ttt{tut3.ml} will be to
//@highlight    print a message to the console for each variable of integral
//@highlight    type wherever it is used indicating whether it is even or odd
//@highlight    at that program point. We consider the results of the analysis
//@highlight    on the code below:}
//@highlight \hlbegincode{}

#include <stdio.h>

int main()
{
  int a,b,c,d;
  a = 1; b = 2; c = 3; d = 4;
  a += b + c;
  c *= d - b;
  b -= d + a;
  if (a % 2) a++;
  printf("a = %d, b = %d, c = %d, d = %d\n", a, b, c, d);
  return 0;
}
//@highlight \hlendcode{}

