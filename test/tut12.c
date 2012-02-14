//@highlight \section{\texttt{test/tut12.c}}
//@highlight \hlbegincode{}

/* With this test, we'll see if CIL's parser successfully captures comments */

int main ()
{
  int x = 1; // line comment x
  int y = 4; // line comment y
  int z;

  /* so far so good */
  z = x + y;

  /* after the instr */
  return z;
}
//@highlight \hlendcode{}
